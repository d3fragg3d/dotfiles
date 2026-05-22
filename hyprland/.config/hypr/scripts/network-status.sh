#!/bin/bash

IFACE=$(ip route show default 2>/dev/null | awk 'NR==1{print $5}')

if [ -z "$IFACE" ]; then
  printf '{"text":"󰖪 Offline","class":"disconnected"}\n'
  exit 0
fi

if [ -d "/sys/class/net/$IFACE/wireless" ]; then
  SSID=$(iwctl station "$IFACE" show 2>/dev/null \
    | sed 's/\x1b\[[0-9;]*[mK]//g' \
    | grep "Connected network" \
    | awk '{$1=$2=""; print}' \
    | xargs)
  [ -z "$SSID" ] && SSID="WiFi"
  ICON="󰖩"
  CLASS="wifi"
else
  SSID="Wired"
  ICON="󰈀"
  CLASS="ethernet"
fi

CACHE="/tmp/waybar-net-$IFACE"
RX=$(cat "/sys/class/net/$IFACE/statistics/rx_bytes" 2>/dev/null || echo 0)
TX=$(cat "/sys/class/net/$IFACE/statistics/tx_bytes" 2>/dev/null || echo 0)
NOW=$(date +%s)

RX_SPEED=0
TX_SPEED=0

if [ -f "$CACHE" ]; then
  read -r RX_PREV TX_PREV TIME_PREV <"$CACHE"
  ELAPSED=$((NOW - TIME_PREV))
  if [ "$ELAPSED" -gt 0 ]; then
    RX_SPEED=$(((RX - RX_PREV) / ELAPSED))
    TX_SPEED=$(((TX - TX_PREV) / ELAPSED))
  fi
fi

echo "$RX $TX $NOW" >"$CACHE"

fmt() {
  local b=$1
  if [ "$b" -ge 1048576 ]; then
    awk "BEGIN{printf \"%.1fM\", $b/1048576}"
  elif [ "$b" -ge 1024 ]; then
    printf "%dK" $((b / 1024))
  else
    printf "%dB" "$b"
  fi
}

DOWN=$(fmt "$RX_SPEED")
UP=$(fmt "$TX_SPEED")

TEXT="${ICON} ${SSID}  <span color='#7aaa9e'>↓ ${DOWN}</span> <span color='#c46a6a'>↑ ${UP}</span>"
printf '{"text":"%s","class":"%s"}\n' "$TEXT" "$CLASS"
