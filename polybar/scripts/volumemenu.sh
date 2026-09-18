#!/usr/bin/env bash
# Menu de volume Stratus: título com o nível, slider e uma linha por saída de áudio.
# ←/→ ajustam 5%, alt+m alterna o mudo, enter troca a saída padrão; o menu
# reabre após cada ação e só fecha no esc.

RASI="$HOME/.config/polybar/scripts/rofi/volume.rasi"

ACCENT="#6BA3E8"
TEXT="#C8D4E3"
TEXT_DIM="#7A90A8"
MUTED="#4A5A70"
BORDER="#293849"

# Slider em VictorMono Mono 13 (9px por célula): 326px úteis = 36 células
SLIDER_WIDTH=36
STEP="5%"

EXIT_DOWN=10
EXIT_UP=11
EXIT_MUTE=12

# Imprime "volume mudo" (0–100 e 0/1) da saída padrão
read_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ |
        awk '{ printf "%d %d\n", $2 * 100 + 0.5, ($3 == "[MUTED]") }'
}

repeat_char() {
    local count="$1" char="$2" out=""
    for ((i = 0; i < count; i++)); do out+="$char"; done
    printf '%s' "$out"
}

render_slider() {
    local volume="$1" muted="$2" fill_color="$ACCENT" knob_color="$TEXT"
    (( volume > 100 )) && volume=100
    local filled=$(( volume * (SLIDER_WIDTH - 1) / 100 ))
    local rest=$(( SLIDER_WIDTH - 1 - filled ))
    (( muted )) && { fill_color="$MUTED"; knob_color="$MUTED"; }
    printf '<span foreground="%s">%s</span><span foreground="%s">●</span><span foreground="%s">%s</span>' \
        "$fill_color" "$(repeat_char "$filled" "━")" \
        "$knob_color" \
        "$BORDER" "$(repeat_char "$rest" "━")"
}

# Uma linha por saída: "nome<TAB>descrição<TAB>barramento<TAB>formato"
list_sinks() {
    pactl -f json list sinks | jq -r '.[] | [
        .name, .description,
        .properties["device.bus"] // "",
        .properties["device.form_factor"] // ""
    ] | @tsv'
}

sink_label() {
    local description="$1" form="$2"
    [[ "$form" == "internal" ]] && { printf 'Alto-falantes internos'; return; }
    printf '%s' "$description"
}

sink_icon() {
    local bus="$1" form="$2"
    if [[ "$bus" == "bluetooth" || "$form" =~ ^(headphone|headset)$ ]]; then
        printf '%s' $'\U000f02cb'
    else
        printf '%s' $'\U000f04c3'
    fi
}

render_sink() {
    local is_default="$1" description="$2" bus="$3" form="$4"
    local icon_color="$MUTED" text_color="$TEXT_DIM"
    (( is_default )) && { icon_color="$ACCENT"; text_color="$TEXT"; }
    printf '<span foreground="%s">%s</span>  <span foreground="%s">%s</span>\n' \
        "$icon_color" "$(sink_icon "$bus" "$form")" \
        "$text_color" "$(sink_label "$description" "$form")"
}

show_menu() {
    local level="$1" level_color="$2" slider="$3" lines="$4" selected="$5"
    rofi -no-config -dmenu -markup-rows -format i -p "Volume" -theme "$RASI" \
        -mesg "$slider" -selected-row "$selected" \
        -theme-str "textbox-level { str: \"$level\"; text-color: $level_color; } listview { lines: $lines; }" \
        -kb-move-char-back "Control+b" -kb-move-char-forward "Control+f" \
        -kb-custom-1 "Left" -kb-custom-2 "Right" -kb-custom-3 "Alt+m"
}

main() {
    local -a sinks rows
    local volume muted level level_color default name description bus form
    local choice code selected=0

    while true; do
        read -r volume muted < <(read_volume)
        if (( muted )); then level="mudo"; level_color="$MUTED"
        else level="${volume}%"; level_color="$TEXT_DIM"; fi

        default="$(pactl get-default-sink)"
        sinks=(); rows=()
        while IFS=$'\t' read -r name description bus form; do
            [[ "$name" == "$default" ]] && selected=${#sinks[@]}
            sinks+=("$name")
            rows+=("$(render_sink "$([[ "$name" == "$default" ]] && echo 1 || echo 0)" "$description" "$bus" "$form")")
        done < <(list_sinks)

        choice=$(printf '%s\n' "${rows[@]}" |
            show_menu "$level" "$level_color" "$(render_slider "$volume" "$muted")" "${#rows[@]}" "$selected")
        code=$?

        case "$code" in
            "$EXIT_DOWN") wpctl set-volume @DEFAULT_AUDIO_SINK@ "$STEP-" ;;
            "$EXIT_UP")   wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$STEP+" ;;
            "$EXIT_MUTE") wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
            0)            [[ -n "$choice" ]] && pactl set-default-sink "${sinks[$choice]}" ;;
            *)            return ;;
        esac
    done
}

main
