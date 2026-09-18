#!/usr/bin/env bash

RASI="$HOME/.config/polybar/scripts/rofi/message.rasi"

if [[ -z "${OPENWEATHER_API_KEY:-}" || -z "${OPENWEATHER_CITY_ID:-}" ]]; then
    MSG="Defina OPENWEATHER_API_KEY e OPENWEATHER_CITY_ID para ativar o clima."
else
    MSG="Clima ativo via OpenWeather."
fi

printf '%s\n' "$MSG" | rofi -no-config -dmenu -p "Weather" -theme "$RASI" >/dev/null
