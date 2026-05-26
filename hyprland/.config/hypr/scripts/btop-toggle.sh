#!/bin/bash
SELECTOR='class:^(btop-float)$'

if hyprctl clients -j | jq -e '.[] | select(.class == "btop-float")' > /dev/null 2>&1; then
    hyprctl dispatch closewindow "$SELECTOR"
else
    kitty --class btop-float -o "map escape quit" btop &

    until hyprctl clients -j | jq -e '.[] | select(.class == "btop-float")' > /dev/null 2>&1; do
        sleep 0.05
    done

    WIDTH=$(hyprctl monitors -j | jq '.[0].width')
    HEIGHT=$(hyprctl monitors -j | jq '.[0].height')
    W=$(( WIDTH * 85 / 100 ))
    H=$(( HEIGHT * 85 / 100 ))

    hyprctl dispatch resizewindowpixel exact "${W}" "${H}","${SELECTOR}"
    hyprctl dispatch centerwindow
fi
