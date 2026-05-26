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

cat > ~/.config/kitty/colors.conf << EOF
background            #111111
foreground            #c8c8c8
cursor                $accent
cursor_text_color     #111111
selection_background  #333333
selection_foreground  #c8c8c8

color0   #1a1a1a
color1   #ac5555
color2   #5a8a50
color3   #7a7a60
color4   #5a78a0
color5   #7a6a8a
color6   #4a8080
color7   #8a8a8a
color8   #454545
color9   #cc6666
color10  #6a9a60
color11  #8a8a70
color12  $accent
color13  $accent
color14  #5a9090
color15  #c8c8c8
EOF

for sock in /tmp/kitty /tmp/kitty-*; do
    [ -S "$sock" ] && kitty @ --to unix:"$sock" set-colors --all --configured ~/.config/kitty/colors.conf 2>/dev/null || true
done
