#!/bin/sh

checkIfRunning() {
	if [ $(systemctl --user is-active xautolock) == "active" ]; then
		return 0
	else
		return 1
	fi
}

changeModeToggle() {

	if checkIfRunning; then
		systemctl --user stop xautolock
	else
		systemctl --user start xautolock
	fi
}

case $1 in
toggle)
	changeModeToggle
	;;
isactive)
	if checkIfRunning; then
		echo " "
	else
		echo " "
	fi
	;;
esac
