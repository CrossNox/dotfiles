#!/bin/bash

chosen=$(printf "  Power Off\n  Restart\n  Lock" | rofi -dmenu -i -theme-str '@import "power.rasi"')

case "$chosen" in
	# "\tLog out" ) bspc quit ;;
	"  Power Off") systemctl poweroff ;;
	"  Restart") systemctl reboot ;;
	"  Lock") slock ;;
	*) exit 1 ;;
esac
