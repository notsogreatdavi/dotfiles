#!/usr/bin/env bash

RASI="$HOME/.config/polybar/scripts/rofi/volume.rasi"

get_volume_info() {
    if command -v wpctl >/dev/null 2>&1; then
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{
            vol   = int($2 * 100)
            muted = ($3 == "[MUTED]") ? 1 : 0
            print vol, muted
        }'
        return
    fi

    if command -v pamixer >/dev/null 2>&1; then
        local vol muted
        vol="$(pamixer --get-volume 2>/dev/null)"
        pamixer --get-mute 2>/dev/null | grep -q true && muted=1 || muted=0
        echo "${vol:-0} ${muted}"
        return
    fi

    echo "0 0"
}

set_volume_up() {
    if command -v wpctl >/dev/null 2>&1; then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ >/dev/null 2>&1
    elif command -v pamixer >/dev/null 2>&1; then
        pamixer -i 5 >/dev/null 2>&1
    fi
}

set_volume_down() {
    if command -v wpctl >/dev/null 2>&1; then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- >/dev/null 2>&1
    elif command -v pamixer >/dev/null 2>&1; then
        pamixer -d 5 >/dev/null 2>&1
    fi
}

toggle_mute() {
    if command -v wpctl >/dev/null 2>&1; then
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1
    elif command -v pamixer >/dev/null 2>&1; then
        pamixer -t >/dev/null 2>&1
    fi
}

volume_bar() {
    local pct=$1 bar=""
    local filled=$(( pct / 10 ))
    local empty=$(( 10 - filled ))
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo "$bar"
}

while true; do
    read -r VOL MUTED < <(get_volume_info)
    BAR="$(volume_bar "$VOL")"

    if [[ "$MUTED" == "1" ]]; then
        STATUS="󰝟  Mudo    [${BAR}]"
    else
        STATUS="󰕾  ${VOL}%    [${BAR}]"
    fi

    ENTRIES=(
        "$STATUS"
        "󰕾  Aumentar +5%"
        "󰕿  Diminuir -5%"
        "󰍭  Alternar Mudo"
        "󰀩  Abrir Mixer"
        "󰅖  Fechar"
    )

    IDX=$(printf '%s\n' "${ENTRIES[@]}" | rofi -no-config -dmenu -p "Áudio" -format i -theme "$RASI")
    [[ -z "$IDX" || "$IDX" == "-1" ]] && exit 0

    case "$IDX" in
    1)
        set_volume_up
        ;;
    2)
        set_volume_down
        ;;
    3)
        toggle_mute
        ;;
    4)
        command -v pavucontrol >/dev/null 2>&1 && pavucontrol >/dev/null 2>&1 &
        ;;
    5)
        exit 0
        ;;
    esac
done
