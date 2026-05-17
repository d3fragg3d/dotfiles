#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures"
INTERVAL=600

awww-daemon &
sleep 0.5

while true; do
    img=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n1)
    awww img "$img" --transition-type wipe --transition-duration 2 --transition-angle 30
    sleep "$INTERVAL"
done
