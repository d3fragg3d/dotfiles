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

cat > ~/.config/fuzzel/fuzzel.ini << EOF
[main]
font=JetBrainsMono Nerd Font:size=8
dpi-aware=yes
prompt="  "
lines=8
width=42
horizontal-pad=18
vertical-pad=14
inner-pad=10
icons-enabled=yes

[colors]
background=111111ee
text=c8c8c8ff
match=${accent#\#}ff
selection=222222ff
selection-text=c8c8c8ff
selection-match=${accent#\#}ff
border=${accent#\#}ff

[border]
width=2
radius=14
EOF
