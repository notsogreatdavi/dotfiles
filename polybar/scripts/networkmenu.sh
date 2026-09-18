#!/usr/bin/env bash
# Menu de wi-fi Stratus: uma linha por rede (sinal, SSID, segurança ou ✓ na conectada).
# Ações do rodapé via teclas: alt+d liga/desliga o rádio, alt+r reescaneia.

RASI="$HOME/.config/polybar/scripts/rofi/wifi.rasi"

ACCENT="#6BA3E8"
TEXT_DIM="#7A90A8"
MUTED="#4A5A70"
SUCCESS="#7ABF8A"

# Colunas da linha em VictorMono Mono 10 (7px por célula, ~296px úteis = 42):
# ícone + 2 espaços + SSID + meta (1 célula de folga) alinhada à direita
SSID_WIDTH=34
META_WIDTH=6

EXIT_TOGGLE=10
EXIT_RESCAN=11

wifi_on() { [[ "$(nmcli radio wifi)" == "enabled" ]]; }

toggle_radio() {
    if wifi_on; then nmcli radio wifi off; else nmcli radio wifi on; fi
}

signal_icon() {
    local signal="$1"
    if   (( signal >= 75 )); then printf '%s' $'\U000f0928'
    elif (( signal >= 50 )); then printf '%s' $'\U000f0925'
    elif (( signal >= 25 )); then printf '%s' $'\U000f0922'
    else                          printf '%s' $'\U000f091f'
    fi
}

# "WPA1 WPA2" vira "wpa2"; rede sem segurança vira "aberta"
security_label() {
    local security="$1"
    [[ -z "$security" || "$security" == "--" ]] && { printf 'aberta'; return; }
    printf '%s' "${security##* }" | tr '[:upper:]' '[:lower:]'
}

fit_ssid() {
    local ssid="$1"
    (( ${#ssid} > SSID_WIDTH )) && ssid="${ssid:0:SSID_WIDTH-1}…"
    printf '%-*s' "$SSID_WIDTH" "$ssid"
}

escape_markup() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' <<<"$1"; }

render_network() {
    local in_use="$1" signal="$2" security="$3" ssid="$4"
    local icon_color="$TEXT_DIM" meta meta_color="$MUTED"
    if [[ "$in_use" == "*" ]]; then
        icon_color="$ACCENT"; meta="✓"; meta_color="$SUCCESS"
    else
        meta="$(security_label "$security")"
    fi
    # printf %*s conta bytes e o ✓ tem 3; o padding é feito em caracteres
    printf '<span foreground="%s">%s</span>  %s%*s<span foreground="%s">%s</span>\n' \
        "$icon_color" "$(signal_icon "$signal")" \
        "$(escape_markup "$(fit_ssid "$ssid")")" \
        $(( META_WIDTH - ${#meta} )) "" "$meta_color" "$meta"
}

# Uma linha por SSID (a de sinal mais forte), sem redes ocultas, conectada primeiro
list_networks() {
    nmcli -t -e no -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan no 2>/dev/null |
        sort -t: -k1,1r -k2,2rn |
        awk '{ ssid = $0; sub(/^([^:]*:){3}/, "", ssid) } ssid != "" && !seen[ssid]++'
}

# A lista encolhe até o número de redes (no máximo 8); -l perde para o lines do tema
show_menu() {
    local status="$1" status_color="$2" lines="$3" hint="$4"
    rofi -no-config -dmenu -i -markup-rows -format i -p "Wi-Fi" -theme "$RASI" \
        -mesg "$hint" \
        -theme-str "textbox-status { str: \"$status\"; text-color: $status_color; } listview { lines: $lines; }" \
        -kb-custom-1 "Alt+d" -kb-custom-2 "Alt+r"
}

connect_to() {
    local ssid="$1" passwd
    if nmcli -g NAME connection show | grep -qFx -e "$ssid" -e "Auto $ssid"; then
        nmcli connection up id "$ssid" 2>/dev/null ||
            nmcli connection up id "Auto $ssid" 2>/dev/null
    else
        passwd=$(rofi -no-config -dmenu -password -p "Senha" -theme "$RASI" \
            -mesg "enter conecta  ·  esc cancela" \
            -theme-str 'textbox-status { str: ""; } listview { lines: 0; }')
        [[ -z "$passwd" ]] && return
        nmcli dev wifi connect "$ssid" password "$passwd"
    fi && notify-send "Wi-Fi" "Conectado a \"$ssid\""
}

main() {
    local -a ssids=() rows=()
    local status status_color hint in_use signal security ssid choice code

    if wifi_on; then
        while IFS=: read -r in_use signal security ssid; do
            ssids+=("$ssid")
            rows+=("$(render_network "$in_use" "$signal" "$security" "$ssid")")
        done < <(list_networks)
        if nmcli -t -f IN-USE dev wifi list --rescan no | grep -q '^\*'; then
            status="conectado"; status_color="$SUCCESS"
        else
            status="desconectado"; status_color="$MUTED"
        fi
        hint="alt+d desligar wi-fi  ·  alt+r reescanear"
    else
        ssids+=("__toggle__")
        rows+=("<span foreground=\"$MUTED\">$(printf '%s' $'\U000f092d')</span>  ligar wi-fi")
        status="desligado"; status_color="$MUTED"
        hint="alt+d ligar wi-fi"
    fi

    choice=$(printf '%s\n' "${rows[@]}" | show_menu "$status" "$status_color" $(( ${#rows[@]} < 8 ? ${#rows[@]} : 8 )) "$hint")
    code=$?

    case "$code" in
        "$EXIT_TOGGLE") toggle_radio; return ;;
        "$EXIT_RESCAN") nmcli dev wifi list --rescan yes >/dev/null 2>&1; exec bash "$0" ;;
    esac
    [[ -z "$choice" || "$choice" == "-1" ]] && return

    ssid="${ssids[$choice]}"
    if [[ "$ssid" == "__toggle__" ]]; then
        toggle_radio
    else
        connect_to "$ssid"
    fi
}

main
