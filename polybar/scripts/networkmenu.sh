#!/usr/bin/env bash
# Menu de wi-fi Stratus: uma linha por rede (sinal, SSID, segurança ou ✓ na conectada).
# Ações do rodapé via teclas: alt+d liga/desliga o rádio, alt+r reescaneia;
# as duas mantêm o menu aberto.

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
# Roda em segundo plano e grava o PID: o scan em andamento fecha este rofi para
# reabrir com a lista nova. O <&0 evita que o bash troque o stdin do job em
# segundo plano por /dev/null. O -l perde para o lines do tema, por isso o -theme-str
show_menu() {
    local status="$1" status_color="$2" lines="$3" hint="$4"
    rofi -no-config -dmenu -i -markup-rows -format i -p "Wi-Fi" -theme "$RASI" \
        -mesg "$hint" \
        -theme-str "textbox-status { str: \"$status\"; text-color: $status_color; } listview { lines: $lines; }" \
        -kb-custom-1 "Alt+d" -kb-custom-2 "Alt+r" <&0 &
    echo $! > "$STATE/rofi.pid"
    wait $!
}

# Espera o scan terminar (o --rescan yes bloqueia até lá) e troca o menu aberto
start_scan() {
    rm -f "$STATE/scan.done"
    (
        sleep 1
        nmcli dev wifi list --rescan yes >/dev/null 2>&1
        touch "$STATE/scan.done" 2>/dev/null || exit
        local pid; pid=$(cat "$STATE/rofi.pid" 2>/dev/null)
        [[ "$(ps -p "$pid" -o comm= 2>/dev/null)" == "rofi" ]] && kill "$pid"
    ) &
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

placeholder_row() { printf '<span foreground="%s">%s</span>\n' "$MUTED" "$1"; }

main() {
    local -a ssids rows
    local status status_color hint in_use signal security ssid choice code scanning=false

    STATE=$(mktemp -d "${XDG_RUNTIME_DIR:-/tmp}/wifimenu.XXXX")
    trap 'rm -rf "$STATE"' EXIT

    # Cada ação (alt+d, alt+r, fim do scan) reabre o menu em vez de encerrar
    while true; do
        ssids=(); rows=()
        if wifi_on; then
            while IFS=: read -r in_use signal security ssid; do
                ssids+=("$ssid")
                rows+=("$(render_network "$in_use" "$signal" "$security" "$ssid")")
            done < <(list_networks)
            if $scanning; then
                status="buscando…"; status_color="$TEXT_DIM"
            elif nmcli -t -f IN-USE dev wifi list --rescan no | grep -q '^\*'; then
                status="conectado"; status_color="$SUCCESS"
            else
                status="desconectado"; status_color="$MUTED"
            fi
            if (( ${#rows[@]} == 0 )); then
                ssids+=("__none__")
                if $scanning; then rows+=("$(placeholder_row "buscando redes…")")
                else rows+=("$(placeholder_row "nenhuma rede encontrada")"); fi
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

        if [[ -e "$STATE/scan.done" ]]; then
            rm -f "$STATE/scan.done"; scanning=false; continue
        fi

        case "$code" in
            "$EXIT_TOGGLE")
                toggle_radio
                if wifi_on; then scanning=true; start_scan; else scanning=false; fi
                continue ;;
            "$EXIT_RESCAN")
                wifi_on && { scanning=true; start_scan; }
                continue ;;
        esac
        [[ -z "$choice" || "$choice" == "-1" ]] && return

        ssid="${ssids[$choice]}"
        case "$ssid" in
            __none__)   continue ;;
            __toggle__) toggle_radio; scanning=true; start_scan; continue ;;
            *)          connect_to "$ssid"; return ;;
        esac
    done
}

main
