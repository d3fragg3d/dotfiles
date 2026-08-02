#!/bin/bash
# SUPER+Space: toggle floating, resize to 60% of the monitor, and center.
#
# Hyprland's Lua config manager changed `hyprctl dispatch` semantics — it now
# treats everything after `dispatch` as a Lua expression, not the old
# `DISPATCHER ARGS` CLI syntax, and the resize dispatcher only accepts pixel
# sizes (no percentages), so this is computed here instead of inline.
read -r w h <<< "$(hyprctl -j monitors | jq -r '.[] | select(.focused) | "\(.width) \(.height)"')"
target_w=$(( w * 60 / 100 ))
target_h=$(( h * 60 / 100 ))

hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })'
hyprctl dispatch "hl.dsp.window.resize({ x = $target_w, y = $target_h })"
hyprctl dispatch 'hl.dsp.window.center()'
