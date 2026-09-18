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

# Cor do valor por estado: status.success carregando, status.error <=10, status.warning <=30
if [[ "$STATUS" == "Charging" || "$STATUS" == "Full" ]]; then
    COLOR="#7ABF8A"
    ICON="󱐋 $ICON"
elif (( CAPACITY <= 10 )); then
    COLOR="#CC6070"
elif (( CAPACITY <= 30 )); then
    COLOR="#E0B84A"
else
    COLOR="#C8D4E3"
fi

printf "%s %%{F%s}%s%%%%{F-}\n" "$ICON" "$COLOR" "$CAPACITY"
