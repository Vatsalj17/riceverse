#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_FILE="$HOME/.cache/wallpaper_list.txt"
SLEEP_DURATION=120
BREAK=600

echo "[Init] Killing interfering wallpaper daemons..."
pkill -x hyprpaper 2>/dev/null
pkill -x mpvpaper 2>/dev/null

echo "[Init] Ensuring awww-daemon is running..."
pgrep -x awww-daemon >/dev/null || awww-daemon &
until pgrep -x awww-daemon >/dev/null; do sleep 0.1; done
echo "[Init] awww-daemon is running. Starting main loop..."

while true; do
    # If live wallpaper is running, skip rotation entirely
    if pgrep -x mpvpaper >/dev/null; then
        echo "[Loop] mpvpaper is active. Going on a break."
        sleep "$BREAK"
        continue
    fi

    # Ensure awww-daemon is still running (it might have crashed)
    if ! pgrep -x awww-daemon >/dev/null; then
        echo "[Loop] awww-daemon died, restarting..."
        awww-daemon &
        until pgrep -x awww-daemon >/dev/null; do sleep 0.1; done
    fi

    # Rebuild cache if stale
    if [ ! -s "$CACHE_FILE" ] || [ -n "$(find "$WALLPAPER_DIR" -newer "$CACHE_FILE" -type f 2>/dev/null)" ]; then
        echo "[Loop] Cache stale or missing, rebuilding..."
        ~/.config/hypr/scripts/update_wallpaper_cache.sh
    fi

    if [ -s "$CACHE_FILE" ]; then
        SELECTED_WALLPAPER=$(shuf -n 1 "$CACHE_FILE")
        echo "[Loop] Setting wallpaper: $SELECTED_WALLPAPER"
        awww img "$SELECTED_WALLPAPER" --transition-type any
    else
        echo "[Loop] Warning: Wallpaper cache is empty. Skipping."
    fi

    sleep "$SLEEP_DURATION"
done
