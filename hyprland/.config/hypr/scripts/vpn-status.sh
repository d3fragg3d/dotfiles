#!/bin/bash

wg_up=false
nord_up=false

ip link show WG-HP &>/dev/null && wg_up=true

if command -v nordvpn &>/dev/null; then
    status=$(nordvpn status 2>/dev/null | grep -m1 Status | awk '{print $2}')
    [ "$status" = "Connected" ] && nord_up=true
fi

if $wg_up; then
    echo '{"text":"󰌾 WireGuard","class":"connected"}'
elif $nord_up; then
    country=$(nordvpn status 2>/dev/null | grep Country | cut -d: -f2 | xargs)
    echo "{\"text\":\"󰌾 $country\",\"class\":\"connected\"}"
else
    echo '{"text":"󰌿 VPN Off","class":"disconnected"}'
fi
