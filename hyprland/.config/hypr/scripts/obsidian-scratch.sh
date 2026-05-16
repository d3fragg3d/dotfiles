#!/usr/bin/env bash

SCRATCH="$HOME/syncthing/obsidian/scratch/$(date +%Y-%m-%d).md"
mkdir -p "$HOME/syncthing/obsidian/scratch"

hyprctl dispatch workspace 3
hyprctl dispatch exec "[workspace 3] kitty nvim '$SCRATCH'"
