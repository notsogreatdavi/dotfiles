#!/usr/bin/env bash
# Workspaces 1..5 sempre visíveis, no estilo "estrato" do Stratus.
# O internal/i3 da polybar só mostra workspaces que existem; o i3 apaga os vazios.
# Estados: ativo (fundo elevated + traço largo accent), visível em outro monitor
# (fundo elevated + traço largo text.secondary), ocupado (traço curto text.secondary),
# urgente (traço curto status.error), vazio (text.muted).

PERSISTENT=5

ELEVATED="#1B2637"
ACCENT="#6BA3E8"
TEXT="#C8D4E3"
TEXT_DIM="#7A90A8"
MUTED="#4A5A70"
ERROR="#CC6070"

# Célula de ~24px: espaço Mono (~8px) + dígito + espaço; espaço e não %{O} porque
# offsets não recebem underline e quebrariam o traço largo. 2px sem fundo entre células
PAD=" "
GAP="%%{O2}"

workspace_state() {
    local num="$1" json="$2"
    jq -r --argjson n "$num" '
        map(select(.num == $n)) | first //
        {focused: false, visible: false, urgent: false, missing: true}
        | if .missing then "empty"
          elif .focused then "focused"
          elif .urgent then "urgent"
          elif .visible then "visible"
          else "occupied" end' <<<"$json"
}

render_label() {
    local num="$1" state="$2"
    local click="%{A1:i3-msg -q workspace number $num:}"
    case "$state" in
        focused)  printf "$GAP"'%s%%{B%s}%%{F%s}%%{u%s}%%{+u}'"$PAD"'%s'"$PAD"'%%{-u}%%{B-}%%{F-}%%{A}' "$click" "$ELEVATED" "$ACCENT" "$ACCENT" "$num" ;;
        visible)  printf "$GAP"'%s%%{B%s}%%{F%s}%%{u%s}%%{+u}'"$PAD"'%s'"$PAD"'%%{-u}%%{B-}%%{F-}%%{A}' "$click" "$ELEVATED" "$TEXT" "$TEXT_DIM" "$num" ;;
        urgent)   printf "$GAP"'%s%%{F%s}'"$PAD"'%%{u%s}%%{+u}%s%%{-u}'"$PAD"'%%{F-}%%{A}' "$click" "$ERROR" "$ERROR" "$num" ;;
        occupied) printf "$GAP"'%s%%{F%s}'"$PAD"'%%{u%s}%%{+u}%s%%{-u}'"$PAD"'%%{F-}%%{A}' "$click" "$TEXT_DIM" "$TEXT_DIM" "$num" ;;
        empty)    printf "$GAP"'%s%%{F%s}'"$PAD"'%s'"$PAD"'%%{F-}%%{A}' "$click" "$MUTED" "$num" ;;
    esac
}

render_bar() {
    local json line="" num max
    json=$(i3-msg -t get_workspaces)
    # Mostra 1..5 sempre e qualquer workspace acima de 5 que esteja aberto
    max=$(jq --argjson p "$PERSISTENT" '[.[].num, $p] | max' <<<"$json")
    for ((num = 1; num <= max; num++)); do
        state=$(workspace_state "$num" "$json")
        (( num > PERSISTENT )) && [[ "$state" == "empty" ]] && continue
        line+=$(render_label "$num" "$state")
    done
    echo "$line"
}

render_bar
i3-msg -t subscribe -m '["workspace","output"]' | while read -r _; do
    render_bar
done
