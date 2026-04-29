#!/bin/bash

status=$(nordvpn status | grep Status | awk '{print $2}')

if [ "$status" = "Connected" ]; then
    nordvpn disconnect
else
    nordvpn connect
fi
