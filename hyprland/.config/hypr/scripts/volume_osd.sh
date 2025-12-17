#!/bin/bash

SOCKET="/tmp/volume_osd.sock"
TIMEOUT=2  # seconds of inactivity before disappearing

[ -e "$SOCKET" ] && rm -f "$SOCKET"
mkfifo "$SOCKET"

cleanup() {
    rm -f "$SOCKET"
    pkill -f "rofi.*volume.rasi"
    exit
}

trap cleanup INT TERM EXIT

last_update=$(date +%s)

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oP '[0-9.]+'
}

is_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED
}

show_bar() {
    local volume_float
    volume_float=$(get_volume)
    local volume=${volume_float%.*}  # strip decimal part

    local icon
    if is_muted; then
        icon="󰖁"
    elif [ "$volume" -ge 70 ]; then
        icon="󰕾"
    elif [ "$volume" -ge 30 ]; then
        icon="󰖀"
    else
        icon="󰕿"
    fi

    local bar_length=15
    local filled_length=$((volume * bar_length / 100))
    local bar=""
    for ((i=0; i<filled_length; i++)); do bar+="▮"; done
    for ((i=filled_length; i<bar_length; i++)); do bar+="▯"; done

    local message
    if is_muted; then
        message="$icon Muted\n▯▯▯▯▯▯▯▯▯▯▯▯▯▯▯ 0%"
    else
        message="$icon Volume\n$bar $volume%"
    fi

    pkill -f "rofi.*volume.rasi" 2>/dev/null
    echo -e "$message" | rofi -dmenu -theme ~/.config/rofi/volume.rasi -p "" -no-fixed-num-lines &
}

while true; do
    if read -t 0.1 line <"$SOCKET"; then
        show_bar
        last_update=$(date +%s)
    else
        now=$(date +%s)
        if (( now - last_update >= TIMEOUT )); then
            pkill -f "rofi.*volume.rasi" 2>/dev/null
            last_update=$((now + 100000))
        fi
    fi
done
