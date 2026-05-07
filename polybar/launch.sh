#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 1; done

EXTERNAL=$(xrandr --query | grep -E "^HDMI.* connected" | awk '{print $1}' | head -n1)
MONITOR_NAME="${EXTERNAL:-eDP-1}"
CUSTOM_CONFIG="$HOME/.config/polybar/custom/config.ini"

if [[ -f "$CUSTOM_CONFIG" ]]; then
    MONITOR="$MONITOR_NAME" polybar main -c "$CUSTOM_CONFIG" --reload &
else
    MONITOR="$MONITOR_NAME" polybar bar --reload &
fi
