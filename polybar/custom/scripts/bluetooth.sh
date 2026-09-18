#!/usr/bin/env bash

if command -v bluetoothctl >/dev/null 2>&1; then
    bash "$HOME/.config/polybar/scripts/btmenu.sh" --status 2>/dev/null || echo "󰂲"
else
    echo "󰂲"
fi
