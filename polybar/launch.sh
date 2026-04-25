#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 1; done

EXTERNAL=$(xrandr --query | grep -E "^HDMI.* connected" | awk '{print $1}' | head -n1)
MONITOR="${EXTERNAL:-eDP-1}" polybar bar --reload &
