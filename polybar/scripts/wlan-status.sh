#!/usr/bin/env bash

ESSID=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
SIGNAL=$(nmcli -t -f ACTIVE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')

if [[ -z "$ESSID" ]]; then
    echo "%{F#BF616A}󰤭%{F-}  Sem rede"
    exit 0
fi

if   (( SIGNAL >= 75 )); then COLOR="#88C0D0"; ICON="󰤨"
elif (( SIGNAL >= 50 )); then COLOR="#A3BE8C"; ICON="󰤥"
elif (( SIGNAL >= 25 )); then COLOR="#EBCB8B"; ICON="󰤢"
else                          COLOR="#BF616A"; ICON="󰤟"
fi

echo "%{F${COLOR}}${ICON}%{F-}  ${ESSID}"
