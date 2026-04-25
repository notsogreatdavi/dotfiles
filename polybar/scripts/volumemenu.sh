#!/usr/bin/env bash

RASI="$HOME/.config/polybar/scripts/rofi/volume.rasi"

volume_info() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{
        vol   = int($2 * 100)
        muted = ($3 == "[MUTED]") ? 1 : 0
        print vol, muted
    }'
}

volume_bar() {
    local pct=$1 bar=""
    local filled=$(( pct / 10 ))
    local empty=$(( 10 - filled ))
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo "$bar"
}

read -r VOL MUTED < <(volume_info)
BAR="$(volume_bar "$VOL")"

[[ "$MUTED" == "1" ]] \
    && STATUS="󰝟  Mudo  [${BAR}]" \
    || STATUS="󰕾  ${VOL}%  [${BAR}]"

ENTRIES=(
    "$STATUS"
    "󰍭  Alternar Mudo"
    "󰀩  Abrir Mixer"
)

IDX=$(printf '%s\n' "${ENTRIES[@]}" | rofi -no-config -dmenu -p "Áudio" -format i -theme "$RASI")
[[ -z "$IDX" || "$IDX" == "-1" ]] && exit 0

case "$IDX" in
    0) ;;
    1) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    2) pavucontrol & ;;
esac
