#!/bin/bash
if pgrep -f "kitty --class calendar" > /dev/null; then
    pkill -f "kitty --class calendar"
else
    kitty --class calendar \
          --override font_size=11 \
          --override window_padding_width=16 \
          -e python3 ~/.config/hypr/scripts/cal-popup.py
fi
