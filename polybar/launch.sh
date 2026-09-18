#!/usr/bin/env bash
# Sobe as 3 ilhas da polybar Stratus no monitor externo (ou no eDP-1 sem externo)

CONFIG="$HOME/.config/polybar/custom/config.ini"

# Uma instância travada ignora SIGTERM e prendia o loop de espera para sempre
stop_polybar() {
    killall -q polybar
    for _ in 1 2 3; do
        pgrep -u "$UID" -x polybar >/dev/null || return
        sleep 1
    done
    killall -q -9 polybar
}

stop_polybar

EXTERNAL=$(xrandr --query | grep -E "^HDMI.* connected" | awk '{print $1}' | head -n1)
export MONITOR="${EXTERNAL:-eDP-1}"

for island in left center status clock; do
    polybar "$island" -c "$CONFIG" --reload 2>"/tmp/polybar-$island.log" &
done
