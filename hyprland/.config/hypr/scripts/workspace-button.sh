#!/bin/bash
# Waybar custom-module JSON for one workspace button.
#
# Hyprland's Lua-dispatcher build broke the built-in hyprland/workspaces
# module: it hardcodes the old `dispatch workspace <id>` IPC string, which
# no longer parses under the Lua dispatcher (see
# github.com/Alexays/Waybar/issues/5008). This script stands in for it,
# paired with an `hl.dsp.focus(...)` on-click in waybar's config.jsonc.

id="$1"
icon="$2"

active=$(hyprctl activeworkspace -j | jq -r '.id')
exists=$(hyprctl workspaces -j | jq -r ".[] | select(.id == $id) | .id")

if [ "$active" = "$id" ]; then
  class="active"
elif [ -z "$exists" ]; then
  class="empty"
else
  class="persistent"
fi

jq -nc --arg text "$icon" --arg class "$class" --arg tip "Workspace $id" \
  '{text: $text, class: $class, tooltip: $tip}'
