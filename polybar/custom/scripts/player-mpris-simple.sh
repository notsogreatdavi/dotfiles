#!/usr/bin/env bash

MAX_LEN=55
PLAYERS=$(playerctl -l 2>/dev/null)

if [[ -z "$PLAYERS" ]]; then
    echo ""
    exit 0
fi

while IFS= read -r PLAYER; do
    STATUS=$(playerctl --player="$PLAYER" status 2>/dev/null)
    if [[ "$STATUS" != "Playing" && "$STATUS" != "Paused" ]]; then
        continue
    fi

    ARTIST=$(playerctl --player="$PLAYER" metadata artist 2>/dev/null)
    TITLE=$(playerctl --player="$PLAYER" metadata title 2>/dev/null)
    TEXT="$ARTIST - $TITLE"
    [[ -z "$ARTIST" && -z "$TITLE" ]] && TEXT="$PLAYER"

    ICON=""
    [[ "$STATUS" == "Paused" ]] && ICON=""

    if (( ${#TEXT} > MAX_LEN )); then
        TEXT="${TEXT:0:$((MAX_LEN - 1))}…"
    fi

    echo "$ICON $TEXT"
    exit 0
done <<< "$PLAYERS"

echo ""
