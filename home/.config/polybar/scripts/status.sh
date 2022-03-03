#!/bin/bash

zscroll -l 30 --delay 0.25 -u true "$HOME/.config/polybar/scripts/spotify_status.py status" &
wait
