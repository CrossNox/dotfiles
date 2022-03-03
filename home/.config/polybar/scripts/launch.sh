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
		#done
		#for m in $(xrandr --query | grep " primary" | cut -d" " -f1); do
		SPOTIFY_CLIENT_ID=$(pass spotify/client_id) SPOTIFY_CLIENT_SECRET=$(pass spotify/client_secret) MONITOR=$m polybar --reload --config=$HOME/.config/polybar/spotify.ini spotibar &
		MONITOR=$m polybar --reload --config=$HOME/.config/polybar/bottom.ini bottomstatus &
	done
else
	POLYBAR_GH_ACCESS_TOKEN=$(pass github/tokens/polybar) polybar --reload --config=$HOME/.config/polybar/statusbar.ini statusbar &
	SPOTIFY_CLIENT_ID=$(pass spotify/client_id) SPOTIFY_CLIENT_SECRET=$(pass spotify/client_secret) polybar --reload --config=$HOME/.config/polybar/spotify.ini spotibar &
	polybar --reload --config=$HOME/.config/polybar/bottom.ini bottomstatus &
fi
echo "Polybar launched"
