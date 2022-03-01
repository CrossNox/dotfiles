#!/bin/bash

SPOTIFY_CLIENT_ID=$(pass spotify/client_id) SPOTIFY_CLIENT_SECRET=$(pass spotify/client_secret) zscroll -l 30 --delay 0.25 -u true "$HOME/.config/polybar/scripts/spotify_status.py status" &
wait
