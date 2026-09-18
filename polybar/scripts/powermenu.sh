#!/usr/bin/env bash
# Menu de energia Stratus: 5 blocos, ações destrutivas passam pelo `confirm`

DIR="$HOME/.config/polybar/scripts/rofi"
UPTIME="$(uptime -p | sed 's/up //')"

lock="<span size='xx-large'>󰌾</span>\nbloquear"
suspend="<span size='xx-large'>󰤄</span>\nsuspender"
logout="<span size='xx-large'>󰍃</span>\nsair"
reboot="<span size='xx-large'>󰑓</span>\nreiniciar"
shutdown="<span size='xx-large'>󰐥</span>\ndesligar"

chosen=$(printf '%b|%b|%b|%b|%b' "$lock" "$suspend" "$logout" "$reboot" "$shutdown" |
    rofi -dmenu -no-config -theme "$DIR/powermenu.rasi" \
        -sep '|' -eh 3 -markup-rows -u 4 -selected-row 0 \
        -p "Até logo, $USER" \
        -theme-str "textbox-uptime { str: \"up $UPTIME\"; }" \
        -format i)

case "$chosen" in
    0) lock ;;
    1) confirm "Suspender?" "O sistema entra em suspensão." "suspender" && systemctl suspend ;;
    2) confirm "Sair do i3?" "A sessão X será encerrada. Janelas abertas vão fechar sem salvar." "sair" && i3-msg exit ;;
    3) confirm "Reiniciar?" "Janelas abertas vão fechar sem salvar." "reiniciar" && systemctl reboot ;;
    4) confirm "Desligar?" "Janelas abertas vão fechar sem salvar." "desligar" && systemctl poweroff ;;
esac
