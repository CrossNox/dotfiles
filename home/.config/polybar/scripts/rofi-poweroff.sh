#!/bin/bash

rofi_command="rofi -config $HOME/.config/rofi/power.rasi -p "power""

log_out=" 󰍃 "
power_off="  "
suspend="  "
reboot="  "
lock="  "

options="$power_off\n$reboot\n$lock\n$suspend\n$log_out"

chosen="$(echo -e "$options" | $rofi_command -dmenu -selected-row 2)"

echo "This is your selection: $chosen"

case "$chosen" in
$log_out) bspc quit ;;
$power_off) systemctl poweroff ;;
$reboot) systemctl reboot ;;
$lock) noxlock ;;
$suspend) systemctl suspend ;;
*) exit 1 ;;
esac
