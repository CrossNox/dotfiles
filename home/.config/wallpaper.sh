#!/usr/bin/env bash

export WP="$HOME/Pictures/Wallpapers/monsters.jpg"
feh --bg-fill "$WP"
wal -i "$WP" -e -t -s &
. "${HOME}/.cache/wal/colors.sh"
~/.config/i3lock/cache_bg.sh &
