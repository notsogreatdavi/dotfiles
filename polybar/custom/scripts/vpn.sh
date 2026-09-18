#!/usr/bin/env bash

SINGBOX_BIN="sing-box"
SINGBOX_CONFIG="$HOME/.config/sing-box/config.json"

vpn_active_nmcli() {
    nmcli -t -f TYPE,NAME con show --active 2>/dev/null | awk -F: '$1=="vpn"{print $2; exit}'
}

vpn_defined_nmcli() {
    nmcli -t -f TYPE,NAME con show 2>/dev/null | awk -F: '$1=="vpn"{print $2; exit}'
}

is_singbox_active() {
    pgrep -x "$SINGBOX_BIN" >/dev/null 2>&1
}

toggle_singbox() {
    if is_singbox_active; then
        pkill -x "$SINGBOX_BIN"
    else
        nohup "$SINGBOX_BIN" run -c "$SINGBOX_CONFIG" >/dev/null 2>&1 &
    fi
}

toggle_nmcli_vpn() {
    local active defined
    active="$(vpn_active_nmcli)"
    if [[ -n "$active" ]]; then
        nmcli con down id "$active" >/dev/null 2>&1
        return
    fi

    defined="$(vpn_defined_nmcli)"
    if [[ -n "$defined" ]]; then
        nmcli con up id "$defined" >/dev/null 2>&1
        return
    fi

    command -v notify-send >/dev/null 2>&1 && notify-send "VPN" "Nenhuma conexão VPN configurada"
}

case "$1" in
toggle)
    if command -v "$SINGBOX_BIN" >/dev/null 2>&1 && [[ -f "$SINGBOX_CONFIG" ]]; then
        toggle_singbox
    elif command -v nmcli >/dev/null 2>&1; then
        toggle_nmcli_vpn
    else
        command -v notify-send >/dev/null 2>&1 && notify-send "VPN" "Nenhum backend disponível"
    fi
    ;;
*)
    if is_singbox_active || [[ -n "$(vpn_active_nmcli)" ]]; then
        echo "󰞀"
    else
        echo "󰦞"
    fi
    ;;
esac
