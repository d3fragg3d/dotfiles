#!/bin/bash

BAT=$(cat /sys/class/power_supply/BAT0/capacity)
STATUS=$(cat /sys/class/power_supply/BAT0/status)

if [ "$STATUS" = "Discharging" ] && [ "$BAT" -le 15 ]; then
    notify-send -u critical "Battery Low" "$BAT% remaining"
fi
