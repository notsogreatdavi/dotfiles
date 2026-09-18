#!/usr/bin/env bash

if command -v pamixer >/dev/null 2>&1; then
    get_volume() { pamixer --get-volume; }
    is_muted() { pamixer --get-mute; }
    vol_up() { pamixer -i 5; }
    vol_down() { pamixer -d 5; }
elif command -v wpctl >/dev/null 2>&1; then
    get_volume() {
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
    }
    is_muted() {
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "\[MUTED\]" && echo "true" || echo "false"
    }
    vol_up() { wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+; }
    vol_down() { wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; }
else
    echo "%{T4}󰝟%{T-}"
    exit 0
fi

case "$1" in
up)
    vol_up
    ;;
down)
    vol_down
    ;;
*)
    VOLUME="$(get_volume 2>/dev/null)"
    MUTED="$(is_muted 2>/dev/null)"

    # Cores: text.muted (#4A5A70) no mudo, valor em text.primary
    if [[ "$MUTED" == "true" || "$MUTED" == "muted" ]]; then
        echo "%{F#4A5A70}%{T4}󰝟%{T-} mudo%{F-}"
    elif [[ -z "$VOLUME" ]]; then
        echo "%{T4}󰕾%{T-}"
    elif (( VOLUME >= 70 )); then
        echo "%{T4}󰕾%{T-} %{F#C8D4E3}${VOLUME}%%{F-}"
    elif (( VOLUME >= 30 )); then
        echo "%{T4}󰖀%{T-} %{F#C8D4E3}${VOLUME}%%{F-}"
    else
        echo "%{T4}󰕿%{T-} %{F#C8D4E3}${VOLUME}%%{F-}"
    fi
    ;;
esac
