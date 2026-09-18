#!/usr/bin/env bash

RASI="$HOME/.config/polybar/scripts/rofi/networkmenu.rasi"
STATUS=$(bash "$HOME/.config/polybar/custom/scripts/vpn.sh")

CHOICE=$(printf '%s\n' "Status: $STATUS" "Alternar VPN" | \
    rofi -no-config -dmenu -p "VPN" -theme "$RASI")

case "$CHOICE" in
"Alternar VPN")
    bash "$HOME/.config/polybar/custom/scripts/vpn.sh" toggle
    ;;
esac
