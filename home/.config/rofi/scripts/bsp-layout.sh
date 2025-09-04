#!/bin/bash

# bsp-layout rofi menu script
# Place in ~/.config/rofi/scripts/

CONFIG_FILE="$HOME/.config/rofi/bsp-layout.conf"

# Default configuration
LAYOUTS=("tall" "rtall" "wide" "rwide" "grid" "rgrid" "even" "tiled" "monocle")

# Load configuration if it exists
if [[ -f "$CONFIG_FILE" ]]; then
	source "$CONFIG_FILE"
fi

# Layout descriptions
declare -A LAYOUT_DESCRIPTIONS
LAYOUT_DESCRIPTIONS["tall"]="Master-stack with tall window"
LAYOUT_DESCRIPTIONS["rtall"]="Master-stack with reversed tall window"
LAYOUT_DESCRIPTIONS["wide"]="Master-stack with wide window"
LAYOUT_DESCRIPTIONS["rwide"]="Master-stack with reversed wide window"
LAYOUT_DESCRIPTIONS["grid"]="Horizontal grid layout"
LAYOUT_DESCRIPTIONS["rgrid"]="Vertical grid layout"
LAYOUT_DESCRIPTIONS["even"]="Evenly balances all window areas"
LAYOUT_DESCRIPTIONS["tiled"]="Default bspwm's tiled layout"
LAYOUT_DESCRIPTIONS["monocle"]="Default bspwm's monocle layout"

# Build menu string
menu_string=""
for i in "${!LAYOUTS[@]}"; do
	layout="${LAYOUTS[$i]}"
	desc="${LAYOUT_DESCRIPTIONS[$layout]}"
	menu_string+="$layout: $desc"
	if [[ $i -lt $((${#LAYOUTS[@]} - 1)) ]]; then
		menu_string+="\n"
	fi
done

# Show rofi menu with dynamic line count
line_count=${#LAYOUTS[@]}
selected=$(echo -e "$menu_string" | rofi -dmenu -i -p "Layout" -theme bsp-layout -no-custom -lines "$line_count")

# Extract layout name and apply
if [[ -n "$selected" ]]; then
	layout_name=$(echo "$selected" | cut -d':' -f1 | xargs)
	bsp-layout set "$layout_name"
fi
