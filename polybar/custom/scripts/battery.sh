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

# Ícones horizontais do design (Font Awesome battery-full..empty, nível dentro do contorno)
level_icon() {
    if (( CAPACITY <= 10 )); then echo $'\uf244'
    elif (( CAPACITY <= 35 )); then echo $'\uf243'
    elif (( CAPACITY <= 60 )); then echo $'\uf242'
    elif (( CAPACITY <= 85 )); then echo $'\uf241'
    else echo $'\uf240'
    fi
}

# O glifo desenha ~21px mas avança ~12px; os offsets compensam o transbordo.
# Carregando: contorno vazio com raio pequeno (T5) sobreposto por offset negativo
charging_icon() {
    printf '%s%%{O-5}%%{T5}%s%%{T4}%%{O1}' $'\uf244' $'\uf0e7'
}

# Contorno em text.secondary; o estado pinta ícone e valor: carregando status.success,
# <=10 status.error, <=30 status.warning
if [[ "$STATUS" == "Charging" || "$STATUS" == "Full" ]]; then
    ICON=$(charging_icon)
    COLOR="#7ABF8A"
    ICON_COLOR="$COLOR"
elif (( CAPACITY <= 10 )); then
    ICON=$(level_icon)
    COLOR="#CC6070"
    ICON_COLOR="$COLOR"
elif (( CAPACITY <= 30 )); then
    ICON=$(level_icon)
    COLOR="#E0B84A"
    ICON_COLOR="$COLOR"
else
    ICON=$(level_icon)
    COLOR="#C8D4E3"
    ICON_COLOR="#7A90A8"
fi

printf "%%{F%s}%%{T4}%s%%{T-}%%{F-}%%{O9} %%{F%s}%s%%%%{F-}\n" "$ICON_COLOR" "$ICON" "$COLOR" "$CAPACITY"
