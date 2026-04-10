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

# Ensure awww-daemon is running
pgrep -x awww-daemon >/dev/null || awww-daemon &
until pgrep -x awww-daemon >/dev/null; do sleep 0.1; done

# Set wallpaper with transition
awww img "$SELECTED_WALLPAPER" --transition-type any
