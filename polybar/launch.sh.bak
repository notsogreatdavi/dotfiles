#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 1; done

MONITOR=eDP-1 polybar bar --reload &
