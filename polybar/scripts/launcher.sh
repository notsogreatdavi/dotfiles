#!/usr/bin/env bash

COLORS_FILE="$HOME/.config/polybar/scripts/rofi/colors.rasi"

# Stratus accent options
COLORS=('#6BA3E8' '#8B6FBE' '#45C4C4')
AC="${COLORS[$(( RANDOM % ${#COLORS[@]} ))]}"

sed -i -e "s/ac: .*/ac:  ${AC}FF;/" "$COLORS_FILE"
sed -i -e "s/se: .*/se:  ${AC}40;/" "$COLORS_FILE"

rofi -no-config -no-lazy-grab -show drun -modi drun \
    -theme "$HOME/.config/polybar/scripts/rofi/launcher.rasi"
