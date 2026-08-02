#!/bin/bash

PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/sleep-inhibit.pid"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "Sleep" "Automatic sleep re-enabled"
else
    systemd-inhibit --what=idle:sleep:handle-lid-switch --who="hyprland" --why="Manually disabled" sleep infinity &
    echo $! > "$PIDFILE"
    notify-send "Sleep" "Automatic sleep disabled"
fi
