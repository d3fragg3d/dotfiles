#!/bin/bash
WEATHER=$(curl -sf --max-time 5 "wttr.in/?format=%c+%t" 2>/dev/null)
[ -z "$WEATHER" ] && WEATHER="? --"
printf '{"text":"%s"}\n' "$WEATHER"
