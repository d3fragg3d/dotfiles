#!/bin/bash
SCRATCHPAD_CLASS="scratchpad"
SELECTOR="class:^(${SCRATCHPAD_CLASS})$"

if ! hyprctl clients -j | jq -e ".[] | select(.class == \"$SCRATCHPAD_CLASS\")" > /dev/null 2>&1; then
    WIDTH=$(hyprctl monitors -j | jq '.[0].width')
    HEIGHT=$(hyprctl monitors -j | jq '.[0].height')
    TERM_HEIGHT=$(( HEIGHT * 40 / 100 ))

    kitty --class "$SCRATCHPAD_CLASS" &

    until hyprctl clients -j | jq -e ".[] | select(.class == \"$SCRATCHPAD_CLASS\")" > /dev/null 2>&1; do
        sleep 0.05
    done

    hyprctl dispatch resizewindowpixel exact "${WIDTH}" "${TERM_HEIGHT}","${SELECTOR}"
    hyprctl dispatch movewindowpixel exact 0 0,"${SELECTOR}"
fi

# Check if scratchpad is currently visible before toggling
IS_VISIBLE=$(hyprctl monitors -j | jq -r '.[0].specialWorkspace.name')

hyprctl dispatch togglespecialworkspace scratchpad

if [ "$IS_VISIBLE" != "special:scratchpad" ]; then
    hyprctl dispatch focuswindow "${SELECTOR}"
fi
