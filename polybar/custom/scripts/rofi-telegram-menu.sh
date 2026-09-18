#!/usr/bin/env bash

RASI="$HOME/.config/polybar/scripts/rofi/networkmenu.rasi"
CHOICE=$(printf '%s\n' "Abrir Telegram" "Fechar Telegram" | rofi -no-config -dmenu -p "Telegram" -theme "$RASI")

case "$CHOICE" in
"Abrir Telegram")
    if command -v telegram-desktop >/dev/null 2>&1; then
        nohup telegram-desktop >/dev/null 2>&1 &
    elif command -v Telegram >/dev/null 2>&1; then
        nohup Telegram >/dev/null 2>&1 &
    fi
    ;;
"Fechar Telegram")
    pkill -x "telegram-desktop" >/dev/null 2>&1 || true
    pkill -x "Telegram" >/dev/null 2>&1 || true
    ;;
esac
