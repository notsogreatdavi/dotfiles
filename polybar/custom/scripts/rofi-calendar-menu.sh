#!/usr/bin/env bash

RASI="$HOME/.config/polybar/scripts/rofi/calendar.rasi"
STATE_FILE="/tmp/polybar-calendar-offset"
ACCENT="#6BA3E8"  # accent.primary
CAL_WIDTH=23

[[ -f "$STATE_FILE" ]] || echo 0 > "$STATE_FILE"
OFFSET="$(cat "$STATE_FILE" 2>/dev/null)"
[[ "$OFFSET" =~ ^-?[0-9]+$ ]] || OFFSET=0

center_text() {
    local text="$1"
    local width="$2"
    local len left right
    len=${#text}
    if (( len >= width )); then
        echo "$text"
        return
    fi
    left=$(( (width - len) / 2 ))
    right=$(( width - len - left ))
    printf "%*s%s%*s" "$left" "" "$text" "$right" ""
}

render_week_line() {
    local line="$1"
    local highlight_day="$2"
    local rendered=""
    local padded cell trimmed

    printf -v padded "%-21s" "$line"
    for col in {0..6}; do
        cell="${padded:$((col * 3)):2}"
        trimmed="${cell#"${cell%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

        if [[ -n "$highlight_day" && "$trimmed" == "$highlight_day" ]]; then
            rendered+="<span foreground='${ACCENT}'><b>$(printf "%2s" "$trimmed")</b></span> "
        else
            rendered+="$(printf "%2s" "$trimmed") "
        fi
    done

    echo "$(center_text "${rendered% }" "$CAL_WIDTH")"
}

show_calendar() {
    local base target month year today_month today_year today_day
    local highlight_day=""
    base="$(date +%Y-%m-15)"
    target="$(date -d "$base ${OFFSET} month" +%Y-%m-%d)"
    month="$(date -d "$target" +%m)"
    year="$(date -d "$target" +%Y)"
    today_month="$(date +%m)"
    today_year="$(date +%Y)"
    today_day="$(date +%-d)"

    if [[ "$month" == "$today_month" && "$year" == "$today_year" ]]; then
        highlight_day="$today_day"
    fi

    mapfile -t CAL_LINES < <(cal -m "$month" "$year")
    HEADER="<span foreground='${ACCENT}'><b>$(center_text "${CAL_LINES[0]}" "$CAL_WIDTH")</b></span>"
    WEEKDAY_LINE="$(center_text "${CAL_LINES[1]}" "$CAL_WIDTH")"

    ENTRIES=(
        "$HEADER"
        "$WEEKDAY_LINE"
    )

    for ((i = 2; i < ${#CAL_LINES[@]}; i++)); do
        ENTRIES+=("$(render_week_line "${CAL_LINES[$i]}" "$highlight_day")")
    done

    ENTRIES+=("───────────────────────")
    ENTRIES+=("  Previous Month")
    ENTRIES+=("  Next Month")

    IDX=$(printf '%s\n' "${ENTRIES[@]}" | rofi -no-config -dmenu -markup-rows -p "Calendar" -format i -theme "$RASI")
    [[ -z "$IDX" || "$IDX" == "-1" ]] && return 1

    local start_actions=$(( ${#ENTRIES[@]} - 2 ))
    case "$IDX" in
    "$start_actions")
        OFFSET=$((OFFSET - 1))
        ;;
    "$((start_actions + 1))")
        OFFSET=$((OFFSET + 1))
        ;;
    esac

    echo "$OFFSET" > "$STATE_FILE"
    return 0
}

while show_calendar; do :; done
