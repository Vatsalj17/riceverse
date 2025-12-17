#!/bin/bash

WALLPAPER_DIR="$HOME/Videos/wallpapers"
SELECTED_WALLPAPER=$(ls "$WALLPAPER_DIR" | wofi --dmenu --width 600 --height 400 --prompt "Select a Live Wallpaper")

if [ -n "$SELECTED_WALLPAPER" ]; then
    pgrep -x swww-daemon >/dev/null && pkill -x swww-daemon
    pgrep -x hyprpaper >/dev/null && pkill -x hyprpaper
    pgrep -x mpvpaper >/dev/null && pkill -x mpvpaper

    mpvpaper -p -f -o --loop eDP-1 "$WALLPAPER_DIR/$SELECTED_WALLPAPER" &
fi
