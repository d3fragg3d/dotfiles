#!/usr/bin/env bash
# Switch to workspace 3 and open kitty+nvim if not already there

hyprctl dispatch workspace 3

KITTY_ON_WS=$(hyprctl clients -j | jq '[.[] | select(.workspace.id == 3 and .class == "kitty")] | length')

if [ "$KITTY_ON_WS" -eq 0 ]; then
    hyprctl dispatch exec '[workspace 3] kitty nvim'
fi
