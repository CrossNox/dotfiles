#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done


echo "Launching polybar"
# Launch polybar
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
	  POLYBAR_GH_ACCESS_TOKEN=$(pass github/tokens/polybar) MONITOR=$m polybar --reload --config=$HOME/.config/polybar/statusbar.ini statusbar &
  done
else
  polybar --reload statusbar --config $HOME/.config/polybar/statusbar.ini &
fi
echo "Polybar launched"
