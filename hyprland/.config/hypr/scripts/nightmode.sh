#!/bin/bash

if pgrep -x hyprsunset > /dev/null; then
    current="󰛩 Disable night mode"
else
    current="󰛨 Enable night mode"
fi

choice=$(printf "󰛨 Enable night mode\n󰛩 Disable night mode" | fuzzel --dmenu --prompt="Night mode: " --lines=2)

case "$choice" in
    "󰛨 Enable night mode")
        killall hyprsunset 2>/dev/null
        hyprsunset -t 4500 &
        notify-send "Night Mode" "Warm tone enabled"
        ;;
    "󰛩 Disable night mode")
        killall hyprsunset 2>/dev/null
        notify-send "Night Mode" "Disabled"
        ;;
esac
