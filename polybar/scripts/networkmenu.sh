#!/usr/bin/env bash

RASI="$HOME/.config/polybar/scripts/rofi/networkmenu.rasi"

wifi_on()   { nmcli -f WIFI general | awk 'NR==2{print $1}' | grep -qi "^enabled"; }
connected() { nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}'; }

CONNECTED="$(connected)"
SSIDS=()
LABELS=()

if wifi_on; then
    SSIDS+=("__toggle_off__")
    LABELS+=("󰤭  Desativar Wi-Fi")
    SSIDS+=("__rescan__")
    LABELS+=("󰑓  Atualizar lista")

    while IFS= read -r line; do
        ssid="$(echo "$line" | cut -d: -f1)"
        security="$(echo "$line" | cut -d: -f2)"
        [[ -z "$ssid" || "$ssid" == "--" ]] && continue
        [[ "$security" =~ WPA|WEP ]] && icon="󰒃" || icon="󰀑"
        label="${icon} ${ssid}"
        [[ "$ssid" == "$CONNECTED" ]] && label+="  ✓"
        SSIDS+=("$ssid")
        LABELS+=("$label")
    done < <(
        nmcli -t -f SSID,SECURITY,SIGNAL dev wifi list --rescan no 2>/dev/null \
            | sort -t: -k3 -rn \
            | awk -F: '!seen[$1]++ && $1!=""'
    )
else
    SSIDS+=("__toggle_on__")
    LABELS+=("󰤨  Ativar Wi-Fi")
fi

IDX=$(printf '%s\n' "${LABELS[@]}" | rofi -no-config -dmenu -i -p "Wi-Fi" -format i -theme "$RASI")
[[ -z "$IDX" || "$IDX" == "-1" ]] && exit 0

ACTION="${SSIDS[$IDX]}"

case "$ACTION" in
    __toggle_off__) nmcli radio wifi off ;;
    __toggle_on__)  nmcli radio wifi on ;;
    __rescan__)
        nmcli dev wifi list --rescan yes > /dev/null 2>&1
        notify-send "Wi-Fi" "Lista atualizada" -t 2000
        ;;
    *)
        if nmcli -g NAME connection show | grep -qFx "$ACTION" || \
           nmcli -g NAME connection show | grep -qFx "Auto $ACTION"; then
            nmcli connection up id "$ACTION" 2>/dev/null \
                || nmcli connection up id "Auto $ACTION" 2>/dev/null
            notify-send "Wi-Fi" "Conectado a \"$ACTION\""
        else
            PASSWD=$(rofi -no-config -dmenu -password -p "Senha: " -theme "$RASI")
            [[ -z "$PASSWD" ]] && exit 0
            nmcli dev wifi connect "$ACTION" password "$PASSWD" \
                && notify-send "Wi-Fi" "Conectado a \"$ACTION\""
        fi
        ;;
esac
