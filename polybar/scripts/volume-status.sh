#!/usr/bin/env bash

MENU="bash /home/notsogreatdavi/.config/polybar/scripts/volumemenu.sh"
VOL_UP="wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
VOL_DOWN="wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

read -r VOL MUTED < <(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{
    print int($2 * 100), ($3 == "[MUTED]") ? 1 : 0
}')

if [[ "$MUTED" == "1" ]]; then
    CONTENT="%{F#BF616A}󰝟%{F-}  Mudo"
elif (( VOL >= 66 )); then
    CONTENT="%{F#88C0D0}󰕾%{F-}  ${VOL}%"
elif (( VOL >= 33 )); then
    CONTENT="%{F#88C0D0}󰖀%{F-}  ${VOL}%"
else
    CONTENT="%{F#88C0D0}󰕿%{F-}  ${VOL}%"
fi

# A1=left-click  A4=scroll-up  A5=scroll-down
echo "%{A1:${MENU}:}%{A4:${VOL_UP}:}%{A5:${VOL_DOWN}:}${CONTENT}%{A}%{A}%{A}"
