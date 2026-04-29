#!/bin/bash

status=$(nordvpn status | grep Status | awk '{print $2}')

if [ "$status" = "Connected" ]; then
    country=$(nordvpn status | grep Country | cut -d: -f2 | xargs)
    echo "{\"text\":\"󰌾 $country\",\"class\":\"connected\"}"
else
    echo "{\"text\":\"󰌿 VPN Off\",\"class\":\"disconnected\"}"
fi
