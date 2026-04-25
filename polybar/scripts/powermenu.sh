#!/usr/bin/env bash

DIR="$HOME/.config/polybar/scripts/rofi"
UPTIME="$(uptime -p | sed 's/up //')"

ROFI="rofi -no-config -theme $DIR/powermenu.rasi"

lock="󰌾  Lock"
suspend="󰤄  Sleep"
logout="󰍃  Logout"
reboot="󰑓  Restart"
shutdown="󰐥  Shutdown"

confirm() {
    rofi -dmenu -no-config -i -no-fixed-num-lines \
        -p "Confirmar: " -theme "$DIR/confirm.rasi"
}

is_confirmed() {
    [[ "$1" == "yes" || "$1" == "y" ]]
}

OPTIONS="$lock\n$suspend\n$logout\n$reboot\n$shutdown"
CHOSEN="$(echo -e "$OPTIONS" | $ROFI -p "uptime: $UPTIME" -dmenu -selected-row 0)"

case "$CHOSEN" in
    "$lock")
        i3lock -c 2E3440
        ;;
    "$suspend")
        is_confirmed "$(confirm)" && systemctl suspend
        ;;
    "$logout")
        is_confirmed "$(confirm)" && i3-msg exit
        ;;
    "$reboot")
        is_confirmed "$(confirm)" && systemctl reboot
        ;;
    "$shutdown")
        is_confirmed "$(confirm)" && systemctl poweroff
        ;;
esac
