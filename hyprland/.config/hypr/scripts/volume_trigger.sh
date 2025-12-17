#!/bin/bash

case "$1" in
    --up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    --down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    --mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    *)
        echo "Usage: $0 {--up|--down|--mute}"
        exit 1
        ;;
esac

echo "update" > /tmp/volume_osd.sock
