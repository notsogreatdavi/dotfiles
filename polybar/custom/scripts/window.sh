#!/usr/bin/env bash
# Título da janela em foco com o ícone do aplicativo, escolhido pela classe (WM_CLASS).
# Substitui o internal/xwindow, que só aceita um prefixo fixo.

HIGHLIGHT="#45C4C4"
TEXT_DIM="#7A90A8"
MUTED="#4A5A70"

MAX_TITLE=60

app_icon() {
    case "${1,,}" in
        *ghostty*|*kitty*|*alacritty*|*term*) printf '%s' $'\U000f018d' ;;
        chromium|google-chrome)               printf '%s' $'\U000f02af' ;;
        zen|firefox)                          printf '%s' $'\U000f0239' ;;
        code)                                 printf '%s' $'\U000f0a1e' ;;
        dev.zed.zed|zed)                      printf '%s' $'\U000f0169' ;;
        telegramdesktop|*telegram*)           printf '%s' $'' ;;
        discord)                              printf '%s' $'\U000f066f' ;;
        spotify)                              printf '%s' $'\U000f04c7' ;;
        steam)                                printf '%s' $'\U000f04d3' ;;
        vlc)                                  printf '%s' $'\U000f057c' ;;
        *nautilus*)                           printf '%s' $'\U000f024b' ;;
        *zathura*)                            printf '%s' $'\U000f0226' ;;
        gimp*)                                printf '%s' $'\U000f03d8' ;;
        libreoffice*|soffice)                 printf '%s' $'\U000f0219' ;;
        pavucontrol)                          printf '%s' $'\U000f057e' ;;
        *)                                    printf '%s' $'\U000f08c6' ;;
    esac
}

# Imprime "classe<TAB>título" da janela em foco; vazio se o foco está num workspace sem janela
focused_window() {
    i3-msg -t get_tree | jq -r '
        .. | objects | select(.focused? == true)
        | select(.window_properties?)
        | [.window_properties.class // "", .name // ""] | @tsv'
}

fit_title() {
    local title="$1"
    (( ${#title} > MAX_TITLE )) && title="${title:0:MAX_TITLE-1}…"
    # "%{" no título seria lido como tag da polybar
    printf '%s' "${title//%\{/%%\{}"
}

render() {
    local class title
    IFS=$'\t' read -r class title < <(focused_window)
    if [[ -z "$class" ]]; then
        printf '%%{F%s}%%{T4}%s%%{T-}%%{O12}%%{T2}desktop%%{T-}%%{F-}\n' "$MUTED" $'\U000f0379'
        return
    fi
    printf '%%{F%s}%%{T4}%s%%{T-}%%{F-}%%{O12}%%{F%s}%%{T2}%s%%{T-}%%{F-}\n' \
        "$HIGHLIGHT" "$(app_icon "$class")" "$TEXT_DIM" "$(fit_title "$title")"
}

render
i3-msg -t subscribe -m '["window","workspace"]' | while read -r _; do
    render
done
