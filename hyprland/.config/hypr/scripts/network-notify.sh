#!/bin/bash

nmcli monitor | while IFS= read -r line; do
    case "$line" in
        *": connected to "*)
            SSID="${line##*connected to }"
            notify-send -u normal -t 4000 "Network" "Connected to $SSID"
            ;;
        *": disconnected"*)
            notify-send -u critical -t 5000 "Network" "Disconnected"
            ;;
    esac
done
