#!/bin/bash

chosen=$(printf "Lock\nSuspend\nLogout\nReboot\nShutdown" | fuzzel --dmenu)

case "$chosen" in
    Lock) hyprlock ;;
    Suspend) systemctl suspend ;;
    Logout) hyprctl dispatch exit ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
