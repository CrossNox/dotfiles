#!/usr/bin/env bash

set -e -o functrace
trap 'failure "LINENO" "BASH_LINENO" "#{BASH_COMMAND}" "${?}"' ERR
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

WP=$1
ICON=$HOME/.config/i3lock/resources/icon.png
TMPBG=$HOME/.config/i3lock/resources/lock.png

RES=$(xrandr --query | grep primary | grep -oP '\d+x\d+')

echo "Converting $WP to $TMPBG with resolution $RES"
/usr/bin/convert "$WP" -blur 0x12 -background none -gravity center -extent "$RES" -resize "$RES" -trim "$TMPBG"

echo "Composite background"
/usr/bin/convert "$TMPBG" "$ICON" -gravity center -composite -matte "$TMPBG"
