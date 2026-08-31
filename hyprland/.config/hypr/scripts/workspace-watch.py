#!/usr/bin/env python3
"""Nudges waybar's workspace buttons to refresh in lockstep on workspace change.

Without this, each custom/wsN module polls Hyprland independently on its own
1s timer, so buttons drift out of sync during a switch (stale/double
highlighting). This listens on Hyprland's event socket and signals waybar so
all buttons redraw at once, off the same event.
"""
import os
import socket
import subprocess

sig = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
xdg = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
path = f"{xdg}/hypr/{sig}/.socket2.sock"

WATCH_PREFIXES = (
    "workspace>>",
    "workspacev2>>",
    "createworkspace>>",
    "createworkspacev2>>",
    "destroyworkspace>>",
    "destroyworkspacev2>>",
    "moveworkspace>>",
    "moveworkspacev2>>",
)

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
    s.connect(path)
    buf = b""
    while True:
        data = s.recv(4096)
        if not data:
            break
        buf += data
        while b"\n" in buf:
            line, buf = buf.split(b"\n", 1)
            if line.decode(errors="ignore").startswith(WATCH_PREFIXES):
                subprocess.run(["pkill", "-RTMIN+8", "waybar"])
