#!/usr/bin/env bash

COLORS_FILE="$HOME/.config/polybar/scripts/rofi/colors.rasi"

# Nord palette — frost + aurora accent options
COLORS=('#8FBCBB' '#88C0D0' '#81A1C1' '#5E81AC' '#A3BE8C' '#B48EAD' '#BF616A')
AC="${COLORS[$(( RANDOM % ${#COLORS[@]} ))]}"

sed -i -e "s/ac: .*/ac:  ${AC}FF;/" "$COLORS_FILE"
sed -i -e "s/se: .*/se:  ${AC}40;/" "$COLORS_FILE"

rofi -no-config -no-lazy-grab -show drun -modi drun \
    -theme "$HOME/.config/polybar/scripts/rofi/launcher.rasi"
