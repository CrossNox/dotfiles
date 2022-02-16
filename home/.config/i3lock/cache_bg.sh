#!/usr/bin/env bash
source $HOME/.config/wallpaper

ICON=$HOME/.config/i3lock/resources/icon.png
TMPBG=$HOME/.config/i3lock/resources/lock.png

convert "$WP" -blur 0x12 -resize $(xrandr --query | grep primary | grep -oP '\d+x\d+') "$TMPBG"

convert $TMPBG $ICON -gravity center -composite -matte $TMPBG
