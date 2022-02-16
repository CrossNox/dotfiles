#!/usr/bin/env bash

WP=$1
ICON=$HOME/.config/i3lock/resources/icon.png
TMPBG=$HOME/.config/i3lock/resources/lock.png

convert "$WP" -blur 0x12 -resize $(xrandr --query | grep primary | grep -oP '\d+x\d+') "$TMPBG"

convert $TMPBG $ICON -gravity center -composite -matte $TMPBG
