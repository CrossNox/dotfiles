#!/usr/bin/env python3
import base64
import json
import logging
import os
import pathlib
import threading
import urllib
import webbrowser
from functools import wraps
from queue import Queue

import dbus
import requests
import toml
import typer
from flask import Flask
from flask import cli as flask_cli
from flask import redirect, request
from werkzeug.serving import make_server

app = typer.Typer()

DEFAULT_CONFIG = {
    "spotify-status": {
        "format": "{artist}: {song}",
        "notliked": "",
        "liked": "",
        "paused": "",
        "playing": "",
        "spotify_client_id": "env:SPOTIFY_CLIENT_ID",
        "spotify_client_secret": "env:SPOTIFY_CLIENT_SECRET",
    }
}


def read_config():
    cfg = DEFAULT_CONFIG

    cfg_file = pathlib.Path.home() / ".config" / "spotify-status.toml"
    if cfg_file.exists():
        with open(cfg_file.resolve()) as f:
            cfg = toml.load(f)

    cfg = cfg["spotify-status"]
    cfg["spotify_client_id"] = override_env(cfg["spotify_client_id"])
    cfg["spotify_client_secret"] = override_env(cfg["spotify_client_secret"])
    return cfg


def handle_spotify_not_running(function):
    @wraps(function)
    def _handle(*args, **kwargs):
        try:
            return function(*args, **kwargs)
        except dbus.DBusException:
            print("Spotify is not running")

    return _handle


def handle_refresh_token(function):
    @wraps(function)
    def _handle(*args, **kwargs):
        try:
            return function(*args, **kwargs)
        except requests.HTTPError as e:
            if e.response.status_code != 401:
                raise
            print(e)
            refresh_auth()
            return function(*args, **kwargs)

    return _handle


def read_creds():
    path = pathlib.Path.home() / ".cache" / "spotify_status.json"
    with open(path) as f:
        data = json.load(f)
        return data


def authorize():
    return read_creds()["access_token"]


def override_env(s):
    if s.startswith("env:"):
        _, envvar = s.split(":")
        return os.getenv(envvar)
    return s


def build_b64_secret():
    cfg = read_config()
    client_id = cfg["spotify_client_id"]
    client_secret = cfg["spotify_client_secret"]

    return base64.b64encode(f"{client_id}:{client_secret}".encode()).decode()


def refresh_auth():
    b64_secret = build_b64_secret()
    refresh_token = read_creds()["refresh_token"]

    headers = {
        "Authorization": f"Basic {b64_secret}",
        "Content-Type": "application/x-www-form-urlencoded",
    }
    data = {
        "grant_type": "refresh_token",
        "refresh_token": refresh_token,
    }
    r = requests.post(
        "https://accounts.spotify.com/api/token", data=data, headers=headers
    )
    r.raise_for_status()
    path = pathlib.Path.home() / ".cache" / "spotify_status.json"
    with open(path, "w") as f:
        data = json.load(f)
        data.update(r.json())

    with open(path, "w") as f:
        json.dump(data, f, indent=4)


@app.command()
def auth():
    b64_secret = build_b64_secret()
    client_id = read_config()["spotify_client_id"]

    flask_cli.show_server_banner = lambda *x: None
    server = Flask(__name__)
    log = logging.getLogger("werkzeug")
    log.disabled = True

    @server.route("/login", methods=["GET"])
    def login():
        qs = urllib.parse.urlencode(
            {
                "response_type": "code",
                "client_id": client_id,
                "scope": "user-library-modify user-library-read",
                "redirect_uri": "http://localhost:58888/callback",
            }
        )
        return redirect(f"https://accounts.spotify.com/authorize?{qs}")

    @server.route("/callback", methods=["GET"])
    def callback():
        code = request.args.get("code")
        # state = request.args.get("state")
        headers = {
            "Authorization": f"Basic {b64_secret}",
            "Content-Type": "application/x-www-form-urlencoded",
        }
        data = {
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": "http://localhost:58888/callback",
        }
        r = requests.post(
            "https://accounts.spotify.com/api/token", data=data, headers=headers
        )
        r.raise_for_status()
        path = pathlib.Path.home() / ".cache" / "spotify_status.json"
        with open(path, "w") as f:
            json.dump(r.json(), f, indent=4)
        q.put(r.json())
        return """
<p id="time"></p>

<script>
let timeLeft = 5

let intervalId = setInterval(function() {
    --timeLeft;
    if (timeLeft === 0) {
        window.open('', '_self').close();
    }

    let $time = document.getElementById('time');
    $time.innerText = `Closing in ${timeLeft}...`;
}, 1000);
</script>
"""

    q = Queue()
    s = make_server("127.0.0.1", 58888, server)
    t = threading.Thread(target=s.serve_forever)
    t.start()
    webbrowser.open("http://localhost:58888/login")
    _ = q.get(block=True)
    s.shutdown()
    t.join()


def get_metadata():
    session_bus = dbus.SessionBus()
    spotify_bus = session_bus.get_object(
        "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2"
    )
    spotify_properties = dbus.Interface(spotify_bus, "org.freedesktop.DBus.Properties")
    metadata = spotify_properties.Get("org.mpris.MediaPlayer2.Player", "Metadata")
    return metadata


def get_playback_status():
    session_bus = dbus.SessionBus()
    spotify_bus = session_bus.get_object(
        "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2"
    )
    spotify_properties = dbus.Interface(spotify_bus, "org.freedesktop.DBus.Properties")
    playback_status = spotify_properties.Get(
        "org.mpris.MediaPlayer2.Player", "PlaybackStatus"
    )
    return playback_status


def get_current_trackid():
    _, _, track_id = get_metadata()["mpris:trackid"].split(":")
    return track_id


@app.command()
@handle_spotify_not_running
@handle_refresh_token
def switch_like():
    track_id = get_current_trackid()
    token = authorize()
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}",
    }
    params = {"ids": track_id}

    _status = get_like_status()
    method = {True: requests.delete, False: requests.put}[_status]

    r = method("https://api.spotify.com/v1/me/tracks", headers=headers, params=params)
    r.raise_for_status()

    metadata = get_metadata()

    artist = metadata["xesam:artist"][0]
    song = metadata["xesam:title"]

    bus_name = "org.freedesktop.Notifications"
    object_path = "/org/freedesktop/Notifications"
    interface = bus_name

    notify = dbus.Interface(
        dbus.SessionBus().get_object(bus_name, object_path), interface
    )

    notify.Notify(
        "spotify-status",
        0,
        "",
        "Removed from your liked songs" if _status else "Added to your liked songs",
        f"{song}\n{artist}",
        [],
        {"urgency": 1},
        15000,
    )


@handle_refresh_token
def get_like_status():
    track_id = get_current_trackid()
    token = authorize()
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}",
    }
    params = {"ids": track_id}
    r = requests.get(
        "https://api.spotify.com/v1/me/tracks/contains", headers=headers, params=params
    )
    r.raise_for_status()

    return r.json()[0]


def get_player():
    session_bus = dbus.SessionBus()
    spotify_bus = session_bus.get_object(
        "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2"
    )
    return dbus.Interface(spotify_bus, "org.mpris.MediaPlayer2.Player")


@app.command()
@handle_spotify_not_running
def like_status():
    cfg = read_config()
    liked = get_like_status()
    if liked is True:
        print(cfg["liked"])
    elif liked is False:
        print(cfg["notliked"])
    else:
        raise ValueError(f"Unknown liked status {liked}")
    return liked


@app.command()
@handle_spotify_not_running
def status():
    metadata = get_metadata()

    artist = metadata["xesam:artist"][0]
    song = metadata["xesam:title"]
    album = metadata["xesam:album"]

    cfg = read_config()
    print(cfg["format"].format(artist=artist, song=song, album=album))


@app.command()
@handle_spotify_not_running
def playback_status(quiet: bool = False):
    try:
        playback_status = get_playback_status()
        if quiet:
            exit(0)
    except dbus.DBusException:
        if quiet:
            exit(1)
        raise

    cfg = read_config()
    if playback_status == "Playing":
        print(cfg["paused"])
    elif playback_status == "Paused":
        print(cfg["playing"])
    else:
        raise ValueError(f"Unknown playback status {playback_status}")


@app.command()
@handle_spotify_not_running
def play_pause():
    get_player().PlayPause()


@app.command()
@handle_spotify_not_running
def next():
    get_player().Next()


@app.command()
@handle_spotify_not_running
def previous():
    get_player().Previous()


if __name__ == "__main__":
    app()
