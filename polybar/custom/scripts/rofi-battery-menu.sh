#!/usr/bin/env bash

RASI="$HOME/.config/polybar/scripts/rofi/networkmenu.rasi"
BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)

if [[ -n "$BAT_PATH" ]]; then
    CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null)
    STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)
    HEADER="Bateria: ${CAPACITY:-N/A}% (${STATUS:-N/A})"
else
    HEADER="Bateria indisponível"
fi

OPTS="Status atual\nPower Saver\nBalanced\nPerformance"
CHOICE=$(printf '%b' "$OPTS" | rofi -no-config -dmenu -p "$HEADER" -theme "$RASI")

case "$CHOICE" in
"Power Saver")
    command -v powerprofilesctl >/dev/null 2>&1 && powerprofilesctl set power-saver
    ;;
"Balanced")
    command -v powerprofilesctl >/dev/null 2>&1 && powerprofilesctl set balanced
    ;;
"Performance")
    command -v powerprofilesctl >/dev/null 2>&1 && powerprofilesctl set performance
    ;;
esac
