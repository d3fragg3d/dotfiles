#!/bin/bash

API_KEY=$(grep -oP '(?<=<apikey>)[^<]+' ~/.local/state/syncthing/config.xml)
BASE_URL="http://localhost:8384"
LAST_ID=0
syncing_count=0

until curl -s -H "X-API-Key: $API_KEY" "$BASE_URL/rest/system/ping" &>/dev/null; do
    sleep 2
done

while true; do
    events=$(curl -s --max-time 70 \
        -H "X-API-Key: $API_KEY" \
        "$BASE_URL/rest/events?since=$LAST_ID&timeout=60&events=StateChanged")

    [[ -z "$events" || "$events" == "[]" ]] && continue

    LAST_ID=$(echo "$events" | jq 'last.id // 0')

    while IFS= read -r line; do
        from=$(echo "$line" | jq -r '.from')
        to=$(echo "$line" | jq -r '.to')

        if [[ "$to" == "syncing" ]]; then
            syncing_count=$((syncing_count + 1))
            [[ $syncing_count -eq 1 ]] && notify-send -u low -t 4000 "Syncthing" "Syncing..."
        elif [[ "$from" == "syncing" && "$to" == "idle" ]]; then
            syncing_count=$((syncing_count - 1))
            [[ $syncing_count -le 0 ]] && { syncing_count=0; notify-send -u low -t 4000 "Syncthing" "Sync complete"; }
        fi
    done < <(echo "$events" | jq -c '.[].data')
done
