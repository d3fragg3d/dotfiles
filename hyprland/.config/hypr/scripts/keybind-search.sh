#!/bin/bash
# Search Hyprland keybindings by what they do, via fuzzel.
# Selecting an entry runs that keybind's action, same as pressing it for real.

CONF="$HOME/.config/hypr/hyprland.conf"

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

declare -A VARS
while IFS='=' read -r name value; do
    VARS["$(trim "$name")"]="$(trim "$value")"
done < <(grep -E '^\$[A-Za-z_]+ *=' "$CONF")

resolve_vars() {
    local s="$1"
    for name in "${!VARS[@]}"; do
        s="${s//$name/${VARS[$name]}}"
    done
    printf '%s' "$s"
}

declare -A ACTIONS
LINES=""

while IFS= read -r line; do
    body="${line#*= }"

    desc="${body##*# }"
    [ "$desc" = "$body" ] && desc="(no description)"

    combo="${body%%#*}"
    mods=$(trim "$(cut -d',' -f1 <<< "$combo")")
    key=$(trim "$(cut -d',' -f2 <<< "$combo")")

    rest="${combo#*,}"
    rest="${rest#*,}"
    dispatcher=$(trim "$(cut -d',' -f1 <<< "$rest")")
    if [[ "$rest" == *,* ]]; then
        args=$(trim "${rest#*,}")
    else
        args=""
    fi
    args=$(resolve_vars "$args")

    display_mods=${mods//\$mainMod/Super}
    display_mods=$(echo "$display_mods" | sed 's/ /+/g')
    if [ -n "$display_mods" ]; then
        combo_str="${display_mods}+${key}"
    else
        combo_str="$key"
    fi

    entry=$(printf "%-24s %s" "$combo_str" "$desc")

    if [ "$dispatcher" = "exec" ]; then
        ACTIONS["$entry"]="exec:$args"
    else
        ACTIONS["$entry"]="dispatch:$dispatcher $args"
    fi

    LINES+="$entry"$'\n'
done < <(grep -E '^bind[a-z]* = ' "$CONF")

CHOICE=$(printf "%s" "$LINES" | fuzzel --dmenu --prompt "󰌌  Keybinds   " --width 60)
[ -z "$CHOICE" ] && exit 0

ACTION="${ACTIONS[$CHOICE]}"
[ -z "$ACTION" ] && exit 0

if [[ "$ACTION" == exec:* ]]; then
    cmd="${ACTION#exec:}"
    bash -c "$cmd" &
    disown
else
    cmd="${ACTION#dispatch:}"
    hyprctl dispatch $cmd
fi
