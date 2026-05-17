#!/bin/bash
BUTTONS=${1:-4}
HEIGHT=$(hyprctl monitors -j | jq '.[0].height')
MARGIN=$(( (HEIGHT - 220) / 2 ))
exec wlogout -b "$BUTTONS" -c 10 -r 10 -T "$MARGIN" -B "$MARGIN"
