#!/bin/bash

chosen=$(printf "\tLog out\n\tPower Off\n\tRestart\n\tLock" | rofi -dmenu -i -theme-str '@import "power.rasi"')

case "$chosen" in
	"\tLog out" ) bspc quit ;;
	"\tPower Off") systemctl poweroff ;;
	"\tRestart") systemctl reboot ;;
	"\tLock") slock ;;
	*) exit 1 ;;
esac
