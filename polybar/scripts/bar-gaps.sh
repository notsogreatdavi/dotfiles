#!/usr/bin/env bash
# Reserva o espaço da polybar só no monitor que tem a polybar.
# As ilhas usam override-redirect (flutuam com offset), então o i3 não reserva nada
# sozinho; o i3/config põe "gaps top 44" em todo workspace. Aqui, workspaces em outro
# monitor voltam a ter só a margem externa. O i3 só tem gap por workspace e o comando
# age no workspace focado, por isso o script reage aos eventos de foco.
# Uso: MONITOR=<saída da polybar> bar-gaps.sh (chamado pelo launch.sh)

BAR_OUTPUT="${MONITOR:?defina MONITOR com a saída da polybar}"
BAR_GAP=44
EDGE_GAP=4

focused_output() {
    i3-msg -t get_workspaces | jq -r '.[] | select(.focused) | .output'
}

apply_gap() {
    local gap=$EDGE_GAP
    [[ "$(focused_output)" == "$BAR_OUTPUT" ]] && gap=$BAR_GAP
    i3-msg -q "gaps top current set $gap"
}

# Workspaces que já existem só recebem o gap quando focados: visita os que estão fora
# do monitor da barra e devolve a tela como estava (visíveis primeiro, focado por último)
fix_existing_workspaces() {
    local json focused name
    json=$(i3-msg -t get_workspaces)
    focused=$(jq -r '.[] | select(.focused) | .name' <<<"$json")
    while read -r name; do
        i3-msg -q "workspace --no-auto-back-and-forth \"$name\""
        apply_gap
    done < <(jq -r --arg bar "$BAR_OUTPUT" '.[] | select(.output != $bar) | .name' <<<"$json")
    while read -r name; do
        i3-msg -q "workspace --no-auto-back-and-forth \"$name\""
    done < <(jq -r '.[] | select(.visible and (.focused | not)) | .name' <<<"$json")
    i3-msg -q "workspace --no-auto-back-and-forth \"$focused\""
}

fix_existing_workspaces
i3-msg -t subscribe -m '["workspace"]' | while read -r _; do
    apply_gap
done
