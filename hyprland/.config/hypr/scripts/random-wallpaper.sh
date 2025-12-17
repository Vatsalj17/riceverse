#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_FILE="$HOME/.cache/wallpaper_list.txt"

# Update cache if needed
if [ ! -f "$CACHE_FILE" ] || [ "$(find "$WALLPAPER_DIR" -type f -newer "$CACHE_FILE" | wc -l)" -gt 0 ]; then
    find "$WALLPAPER_DIR" -type f > "$CACHE_FILE"
fi

SELECTED_WALLPAPER=$(shuf -n 1 "$CACHE_FILE")

# Kill interfering wallpaper daemons
pkill -x hyprpaper 2>/dev/null
pkill -x mpvpaper 2>/dev/null

# Ensure swww-daemon is running
pgrep -x swww-daemon >/dev/null || swww-daemon &
until pgrep -x swww-daemon >/dev/null; do sleep 0.1; done

# Set wallpaper with transition
swww img "$SELECTED_WALLPAPER" --transition-type any
