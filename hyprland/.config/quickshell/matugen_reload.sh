#!/usr/bin/env bash
killall -USR1 kitty 2>/dev/null || true

if pgrep -x "cava" > /dev/null; then
    cat ~/.config/cava/config_base ~/.config/cava/colors > ~/.config/cava/config 2>/dev/null
    killall -USR1 cava
fi

if command -v swaync-client &> /dev/null; then
    swaync-client -rs
fi
