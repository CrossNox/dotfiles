#!/bin/bash
zscroll -l 30 --delay 0.2 -u true "SPOTIFY_CLIENT_ID=$(pass spotify/client_id) SPOTIFY_CLIENT_SECRET=$(pass spotify/client_secret) $HOME/.config/polybar/scripts/spotify_status.py status" &
wait
