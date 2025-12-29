#!/usr/bin/env python3

import html
import json
import pathlib
from datetime import datetime
from typing import Dict, List, Optional, Protocol

import dbus
import typer
import youconfigme as ycm
from dateutil import parser
from google.auth.exceptions import RefreshError
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"]

app = typer.Typer()
cfg = ycm.Config(from_items={})


def get_creds(account: str):
    creds = None

    token_json = pathlib.Path.home() / ".cache" / f"dunst_gmail_{account}.json"

    if token_json.exists():
        creds = Credentials.from_authorized_user_file(token_json, SCOPES)

    if creds is not None and creds.expired and creds.refresh_token is not None:
        creds.refresh(Request())
    elif creds is None or not creds.valid:
        client_dict = cfg.dunst.gmail(
            default="dunst/gmail", from_pass=True, cast=json.loads
        )
        flow = InstalledAppFlow.from_client_config(client_dict, SCOPES)
        creds = flow.run_local_server(port=0)

        with open(token_json, "w") as f:
            f.write(creds.to_json())

    return creds


def get_service(account: str):
    service = build("gmail", "v1", credentials=get_creds(account))
    return service


def get_unread(
    account: str, last_seconds: Optional[int] = None, max_results: int = 100
):
    last_days = (
        (last_seconds // (24 * 60 * 60)) + 1 if last_seconds is not None else None
    )
    newer_than_filter_str = f" newer_than:{last_days}d" if last_days is not None else ""
    filter_str = f"is:unread category:primary {newer_than_filter_str}"
    result = (
        get_service(account)
        .users()
        .messages()
        .list(userId="me", q=filter_str, maxResults=max_results)
        .execute()
    )
    messages_ids = [message["id"] for message in result["messages"]]
    size_esimate = result["resultSizeEstimate"]
    return messages_ids, size_esimate


class FilterCallable(Protocol):
    def __call__(self, email: Dict, *args) -> Optional[Dict]:
        ...


def batch_get(
    account: str, ids: List[str], filter_with: Optional[FilterCallable] = None, **kwargs
) -> List[Dict]:
    service = get_service(account)
    emails = []
    for email_id in ids:
        email = service.users().messages().get(userId="me", id=email_id).execute()
        if filter_with is None or not filter_with(email, **kwargs):
            continue
        emails.append(email)
    return emails


def get_headers(email: Dict):
    return {x["name"]: x["value"] for x in email["payload"]["headers"]}


def filter_new_mail(email, last_seconds):
    headers = get_headers(email)
    email_date = parser.parse(headers["Date"])
    tdiff = (datetime.now(email_date.tzinfo) - email_date).total_seconds()
    if tdiff < last_seconds:
        return email
    return None


def notify(account: str, email: Dict):
    headers = get_headers(email)

    bus_name = "org.freedesktop.Notifications"
    object_path = "/org/freedesktop/Notifications"
    interface = bus_name

    notify = dbus.Interface(
        dbus.SessionBus().get_object(bus_name, object_path), interface
    )

    subject, email_from = headers["Subject"], headers["From"]

    email_from = html.escape(email_from)

    notify.Notify(
        f"Gmail ({account})",
        0,
        str(pathlib.Path(__file__).parent / "gmail.png"),
        f"{subject}",
        f"From: {email_from}",
        [],
        {"urgency": 1},
        15000,
    )


@app.command()
def notify_unread(account: str, last_seconds: int = 60, from_pass: bool = False):
    account = cfg.dunst.account(default=account, from_pass=from_pass)
    unread, _ = get_unread(account, last_seconds)
    messages = batch_get(
        account, unread, filter_with=filter_new_mail, last_seconds=last_seconds
    )
    for message in messages:
        notify(account, message)


@app.command()
def number_unread(account: str, max_results: int = 500, from_pass: bool = False):
    account = cfg.dunst.account(default=account, from_pass=from_pass)
    unread, n_unread = get_unread(account, max_results=max_results)
    if n_unread >= max_results:
        typer.echo(f"{n_unread}+")
    else:
        typer.echo(n_unread)


if __name__ == "__main__":
    try:
        app()
    except RefreshError:
        print("Refresh error!")
