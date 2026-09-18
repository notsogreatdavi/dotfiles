#!/usr/bin/env bash

case "$1" in
--popup)
    bash "$HOME/.config/polybar/scripts/powermenu.sh"
    ;;
*)
    echo "󰐥"
    ;;
esac
