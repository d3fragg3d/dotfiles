#!/bin/bash
source ~/.cache/wallust/current.sh || exit 0

accent=$(
    for hex in ${color0#\#} ${color1#\#} ${color2#\#} ${color3#\#} ${color4#\#} ${color5#\#} \
               ${color6#\#} ${color7#\#} ${color8#\#} ${color9#\#} ${color10#\#} ${color11#\#} \
               ${color12#\#} ${color13#\#} ${color14#\#} ${color15#\#}; do
        r=$((16#${hex:0:2})); g=$((16#${hex:2:2})); b=$((16#${hex:4:2}))
        max=$(( r > g ? (r > b ? r : b) : (g > b ? g : b) ))
        min=$(( r < g ? (r < b ? r : b) : (g < b ? g : b) ))
        printf '%05d #%s\n' "$(( max - min ))" "$hex"
    done | sort -rn | head -1 | awk '{print $2}'
)

printf '@define-color accent %s;\n' "$accent" > ~/.config/waybar/colors.css

pkill -x -SIGUSR2 waybar 2>/dev/null || true
