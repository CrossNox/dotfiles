#!/bin/bash

chosen=$(printf " Log out\n Power Off\n Restart\n Lock" | rofi -dmenu -i -theme-str '@import "power.rasi"')

case "$chosen" in
	" Log out" ) bspc quit ;;
	" Power Off") systemctl poweroff ;;
	" Restart") systemctl reboot ;;
	" Lock") noxlock ;;
	*) exit 1 ;;
esac
