#!/usr/bin/env bash

API_KEY="${OPENWEATHER_API_KEY:-}"
CITY_ID="${OPENWEATHER_CITY_ID:-}"
UNITS="${OPENWEATHER_UNITS:-metric}"

if [[ -z "$API_KEY" || -z "$CITY_ID" ]] || ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    echo "󰖐"
    exit 0
fi

API_URL="https://api.openweathermap.org/data/2.5/weather?appid=${API_KEY}&id=${CITY_ID}&units=${UNITS}"
DATA=$(curl -sf "$API_URL" 2>/dev/null)

if [[ -z "$DATA" ]]; then
    echo "󰖐"
    exit 0
fi

ICON_CODE=$(echo "$DATA" | jq -r ".weather[0].icon")

case "$ICON_CODE" in
01d) echo "󰖙" ;;
01n) echo "󰖔" ;;
02d) echo "󰖕" ;;
02n) echo "󰼱" ;;
03d|03n|04d|04n) echo "󰖐" ;;
09d|09n|10d|10n) echo "󰖖" ;;
11d|11n) echo "󰙾" ;;
13d|13n) echo "󰖘" ;;
50d|50n) echo "󰖑" ;;
*) echo "󰖐" ;;
esac
