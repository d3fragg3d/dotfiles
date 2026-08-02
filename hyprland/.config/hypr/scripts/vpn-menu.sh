#!/bin/bash

wg_up=false
nord_up=false

ip link show WG-HP &>/dev/null && wg_up=true

if command -v nordvpn &>/dev/null; then
    status=$(nordvpn status 2>/dev/null | grep -m1 Status | awk '{print $2}')
    [ "$status" = "Connected" ] && nord_up=true
fi

$wg_up   && wg_label="WireGuard: Disconnect"   || wg_label="WireGuard: Connect"
$nord_up && nord_label="NordVPN: Disconnect"    || nord_label="NordVPN: Connect"

CHOICE=$(printf "%s\n%s" "$wg_label" "$nord_label" | fuzzel --dmenu --prompt "  VPN   " --width 30)
[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    "WireGuard: Connect")    sudo wg-quick up /home/chris/vpn/WG-HP.conf ;;
    "WireGuard: Disconnect") sudo wg-quick down /home/chris/vpn/WG-HP.conf ;;
    "NordVPN: Connect")      nordvpn connect ;;
    "NordVPN: Disconnect")   nordvpn disconnect ;;
esac
