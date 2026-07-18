#!/bin/bash

WAYBAR_CONFIG="$HOME/.config/waybar/sidepanel.jsonc"

if pgrep -f "$WAYBAR_CONFIG" > /dev/null; then
    pkill -f "$WAYBAR_CONFIG"
else
    waybar -c "$WAYBAR_CONFIG" -s "$HOME/.config/waybar/sidepanel.css" &
fi
