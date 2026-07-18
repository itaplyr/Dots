#!/usr/bin/env bash
# Toggle fuzzel launcher

if pgrep -x fuzzel > /dev/null; then
    pkill fuzzel
else
    fuzzel
fi
