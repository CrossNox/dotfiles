#!/bin/sh

checkIfRunning() {
	if [ $(systemctl --user is-active gammastep) == "active" ]; then
		return 0
	else
		return 1
	fi
}

changeModeToggle() {

	if checkIfRunning; then
		systemctl --user stop gammastep
	else
		systemctl --user start gammastep
	fi
}

case $1 in
toggle)
	changeModeToggle
	;;
temperature)
	if checkIfRunning; then
		CURRENT_TEMP=$(gammastep -p 2>&1 | grep "Color temperature" | sed 's/.*: //')
		echo " $CURRENT_TEMP"
	else
		echo ""
	fi
	;;
esac
