#!/usr/bin/env bash

if pgrep -x "Telegram" >/dev/null 2>&1 || \
   pgrep -x "telegram-desktop" >/dev/null 2>&1 || \
   pgrep -x "TelegramDesktop" >/dev/null 2>&1; then
    echo ""
else
    echo ""
fi
