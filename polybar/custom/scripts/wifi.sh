#!/usr/bin/env bash

if ! command -v nmcli >/dev/null 2>&1; then
    echo "󰤭"
    exit 0
fi

ESSID=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
SIGNAL=$(nmcli -t -f ACTIVE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')

if [[ -z "$ESSID" ]]; then
    echo "󰤮"
    exit 0
fi

if (( SIGNAL >= 80 )); then
    ICON="󰤨"
elif (( SIGNAL >= 55 )); then
    ICON="󰤥"
elif (( SIGNAL >= 30 )); then
    ICON="󰤢"
else
    ICON="󰤟"
fi

if [[ "${POLYBAR_WIFI_SHOW_SSID:-0}" == "1" ]]; then
    echo "${ICON} ${ESSID}"
else
    echo "${ICON}"
fi
