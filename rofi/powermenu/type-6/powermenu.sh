#!/bin/bash

# Opções do menu com Ícones e Texto
lock="  Lock"
logout="  Logout"
reboot="  Reboot"
shutdown="  Shutdown"

# Captura a escolha do usuário
selected_option=$(echo -e "$lock\n$logout\n$reboot\n$shutdown" | rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/powermenu/type-6/style-3.rasi)

# Executa a ação correspondente
case "$selected_option" in
"$lock")
  i3lock -c 2E3440 # Bloqueia a tela com uma cor Nord
  ;;
"$logout")
  i3-msg exit
  ;;
"$reboot")
  systemctl reboot
  ;;
"$shutdown")
  systemctl poweroff
  ;;
esac
