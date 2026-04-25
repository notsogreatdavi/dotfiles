#!/usr/bin/env bash

read -r VOL MUTED < <(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{
    print int($2 * 100), ($3 == "[MUTED]") ? 1 : 0
}')

if [[ "$MUTED" == "1" ]]; then
    echo "%{F#BF616A}󰝟%{F-}  Mudo"
elif (( VOL >= 66 )); then
    echo "%{F#88C0D0}󰕾%{F-}  ${VOL}%"
elif (( VOL >= 33 )); then
    echo "%{F#88C0D0}󰖀%{F-}  ${VOL}%"
else
    echo "%{F#88C0D0}󰕿%{F-}  ${VOL}%"
fi
