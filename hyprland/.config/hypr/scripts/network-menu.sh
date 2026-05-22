#!/bin/bash
# iwd network selector via fuzzel

IFACE=$(ls /sys/class/net/ | grep -E '^wl' | head -1)
[ -z "$IFACE" ] && exit 1

iwctl station "$IFACE" scan 2>/dev/null &

CURRENT=$(iwctl station "$IFACE" show 2>/dev/null \
  | sed 's/\x1b\[[0-9;]*[mK]//g' \
  | grep "Connected network" \
  | awk '{$1=$2=""; print}' \
  | xargs)

NETWORKS=$(iwctl station "$IFACE" get-networks 2>/dev/null \
  | sed 's/\x1b\[[0-9;]*[mK]//g' \
  | awk 'NR>4 && /\*+/' \
  | sed 's/^[[:space:]>]*//' \
  | awk '{
      stars = length($NF)
      if      (stars >= 4) icon = "󰤨"
      else if (stars == 3) icon = "󰤥"
      else if (stars == 2) icon = "󰤢"
      else                 icon = "󰤟"
      name = ""
      for (i = 1; i <= NF-2; i++) name = name (i > 1 ? " " : "") $i
      print icon " " name
    }')

MENU=$(
  if [ -n "$CURRENT" ]; then
    printf "Connected: %s\nDisconnect\n──────────\n" "$CURRENT"
  else
    printf "Not connected\n──────────\n"
  fi
  echo "$NETWORKS"
)

CHOICE=$(echo "$MENU" | fuzzel --dmenu --prompt "  WiFi   " --width 40)
[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
  "Disconnect")
    iwctl station "$IFACE" disconnect
    ;;
  "Connected: "*|"Not connected"|"──────────")
    ;;
  *)
    SSID=$(echo "$CHOICE" | cut -d' ' -f2-)
    [ "$SSID" = "$CURRENT" ] && exit 0

    if ls /var/lib/iwd/ 2>/dev/null | grep -qF "$SSID"; then
      iwctl station "$IFACE" connect "$SSID"
    else
      kitty --title "network-connect" -- bash -c "
        printf 'Connecting to: %s\n' '$SSID'
        read -rsp 'Passphrase: ' PASS
        printf '\n'
        iwctl --passphrase \"\$PASS\" station '$IFACE' connect '$SSID' \
          && printf 'Connected.\n' || printf 'Failed.\n'
        sleep 2
      "
    fi
    ;;
esac
