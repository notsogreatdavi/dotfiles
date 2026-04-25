#!/usr/bin/env bash

RASI="$HOME/.config/polybar/scripts/rofi/bluetooth.rasi"
GOBACK="↩  Voltar"

bt_powered()  { bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; }
bt_scanning() { bluetoothctl show 2>/dev/null | grep -q "Discovering: yes"; }
bt_pairable() { bluetoothctl show 2>/dev/null | grep -q "Pairable: yes"; }

toggle_power() {
    if bt_powered; then
        bluetoothctl power off
    else
        rfkill unblock bluetooth 2>/dev/null
        bluetoothctl power on
    fi
}

dev_connected() { bluetoothctl info "$1" 2>/dev/null | grep -q "Connected: yes"; }
dev_paired()    { bluetoothctl info "$1" 2>/dev/null | grep -q "Paired: yes"; }
dev_trusted()   { bluetoothctl info "$1" 2>/dev/null | grep -q "Trusted: yes"; }

status() {
    if bt_powered; then
        local names=""
        while IFS= read -r dev; do
            local mac name
            mac="$(awk '{print $2}' <<< "$dev")"
            name="$(cut -d' ' -f3- <<< "$dev")"
            dev_connected "$mac" && names+=" ${name}"
        done < <(bluetoothctl devices Paired 2>/dev/null)
        [[ -n "$names" ]] && echo "󰂱${names}" || echo "󰂯"
    else
        echo "󰂲"
    fi
}

device_menu() {
    local mac="$1" name="$2"
    dev_connected "$mac" && conn="Conectado: Sim" || conn="Conectado: Não"
    dev_paired    "$mac" && pair="Pareado: Sim"   || pair="Pareado: Não"
    dev_trusted   "$mac" && trus="Confiável: Sim" || trus="Confiável: Não"

    CHOSEN=$(printf '%s\n' "$conn" "$pair" "$trus" "$GOBACK" | \
        rofi -no-config -dmenu -p "$name" -theme "$RASI")

    case "$CHOSEN" in
        "Conectado: Sim")  bluetoothctl disconnect "$mac" ;;
        "Conectado: Não")  bluetoothctl connect "$mac" ;;
        "Pareado: Sim")    bluetoothctl remove "$mac" ;;
        "Pareado: Não")    bluetoothctl pair "$mac" ;;
        "Confiável: Sim")  bluetoothctl untrust "$mac" ;;
        "Confiável: Não")  bluetoothctl trust "$mac" ;;
        "$GOBACK")         show_menu ;;
    esac
}

show_menu() {
    local ENTRIES=() MACS=()

    if bt_powered; then
        ENTRIES+=("󰂯  Bluetooth: Ligado")
        MACS+=("__power__")
        bt_scanning && ENTRIES+=("󰐇  Scan: Ligado")   || ENTRIES+=("󰐇  Scan: Desligado")
        MACS+=("__scan__")
        bt_pairable && ENTRIES+=("󰂱  Pareável: Sim")   || ENTRIES+=("󰂱  Pareável: Não")
        MACS+=("__pair__")
        ENTRIES+=("──────────────────")
        MACS+=("__sep__")

        while IFS= read -r dev; do
            local mac name icon
            mac="$(awk '{print $2}' <<< "$dev")"
            name="$(cut -d' ' -f3- <<< "$dev")"
            dev_connected "$mac" && icon="󰂱" || icon="󰂰"
            ENTRIES+=("${icon}  ${name}")
            MACS+=("$mac")
        done < <(bluetoothctl devices 2>/dev/null | grep " Device ")
    else
        ENTRIES+=("󰂲  Bluetooth: Desligado")
        MACS+=("__power__")
    fi

    IDX=$(printf '%s\n' "${ENTRIES[@]}" | rofi -no-config -dmenu -p "Bluetooth" -format i -theme "$RASI")
    [[ -z "$IDX" || "$IDX" == "-1" ]] && exit 0

    local ACTION="${MACS[$IDX]}"
    local LABEL="${ENTRIES[$IDX]}"

    case "$ACTION" in
        __power__) toggle_power ;;
        __scan__)
            bt_scanning \
                && (kill "$(pgrep -f 'bluetoothctl.*scan on')" 2>/dev/null; bluetoothctl scan off) \
                || bluetoothctl --timeout 5 scan on &
            ;;
        __pair__) bt_pairable && bluetoothctl pairable off || bluetoothctl pairable on ;;
        __sep__)  show_menu ;;
        *)
            [[ -n "$ACTION" ]] && device_menu "$ACTION" "$(cut -d' ' -f2- <<< "${LABEL#*  }")"
            ;;
    esac
}

case "$1" in
    --status) status ;;
    *)        show_menu ;;
esac
