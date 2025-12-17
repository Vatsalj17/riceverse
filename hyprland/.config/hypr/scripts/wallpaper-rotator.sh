#!/bin/bash

# --- Configuration ---
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_FILE="$HOME/.cache/wallpaper_list.txt"
SLEEP_DURATION=120 # 2 minutes

# --- Initial Setup (Run Once) ---
echo "[Init] Killing interfering wallpaper daemons..."
pkill -x hyprpaper 2>/dev/null
pkill -x mpvpaper 2>/dev/null

echo "[Init] Ensuring swww-daemon is running..."
pgrep -x swww-daemon >/dev/null || swww-daemon &
until pgrep -x swww-daemon >/dev/null; do sleep 0.1; done
echo "[Init] swww-daemon is running. Starting main loop..."

# --- Main Loop ---
while true; do
    # Get the *first* battery device we can find
    BATTERY_DEVICE=$(upower -e | grep 'BAT' | head -n 1)

    if [ -n "$BATTERY_DEVICE" ]; then
        # Get its state using your script's logic
        STATE=$(upower -i "$BATTERY_DEVICE" | grep "state" | awk '{print $2}')
    else
        # Fallback: No battery found (maybe a desktop?)
        # We'll assume "plugged in"
        STATE="fully-charged"
    fi

    # Check if we are in a non-discharging state
    if [[ "$STATE" == "charging" || "$STATE" == "fully-charged" || "$STATE" == "pending-charge" ]]; then
        # --- System is PLUGGED IN (or full) ---
        echo "[Loop] Power state is '$STATE'. Changing wallpaper."
        SLEEP_DURATION=120

        # Select and set wallpaper
        if [ -s "$CACHE_FILE" ]; then
            SELECTED_WALLPAPER=$(shuf -n 1 "$CACHE_FILE")
            echo "[Loop] Setting wallpaper to: $SELECTED_WALLPAPER"
            swww img "$SELECTED_WALLPAPER" --transition-type any
        else
            echo "[Loop] Warning: Wallpaper cache is empty. Skipping."
        fi
    else
        # --- System is ON BATTERY ---
        echo "[Loop] Power state is '$STATE'. Skipping wallpaper change."
        SLEEP_DURATION=600 # 10 minutes
    fi

    # Wait for the next cycle
    echo "[Loop] Sleeping for $SLEEP_DURATION seconds..."
    sleep "$SLEEP_DURATION"
done
