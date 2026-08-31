#!/bin/bash
# Respawns waybar if it dies (e.g. the wireplumber-race SIGSEGV seen on cold boot).
while true; do
    waybar
    sleep 1
done
