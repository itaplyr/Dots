#!/usr/bin/env bash
# Toggle clipboard manager using cliphist and fuzzel

if pgrep -x fuzzel > /dev/null; then
    pkill fuzzel
else
    selected=$(cliphist list | sed 's/^[0-9]*\t//' | fuzzel --dmenu --prompt="Clipboard: ")
    if [ -n "$selected" ]; then
        echo "$selected" | cliphist decode | wl-copy
    fi
fi
