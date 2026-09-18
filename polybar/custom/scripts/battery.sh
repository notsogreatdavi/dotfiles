#!/usr/bin/env bash

BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
if [[ -z "$BAT_PATH" ]]; then
    echo "󱉝"
    exit 0
fi

CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null)
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)

if [[ -z "$CAPACITY" ]]; then
    echo "󱉝"
    exit 0
fi

if (( CAPACITY <= 10 )); then
    ICON=""
elif (( CAPACITY <= 30 )); then
    ICON=""
elif (( CAPACITY <= 59 )); then
    ICON=""
elif (( CAPACITY <= 79 )); then
    ICON=""
else
    ICON=""
fi

if [[ "$STATUS" == "Charging" || "$STATUS" == "Full" ]]; then
    printf "󱐋 %s\n" "$ICON"
else
    printf "%s\n" "$ICON"
fi
