#!/bin/bash


WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
SELECTED_WALLPAPER=$(ls "$WALLPAPER_DIR" | wofi --dmenu --width 600 --height 400 --prompt "Select a Wallpaper")

if [ -n "$SELECTED_WALLPAPER" ]; then
	pgrep -x hyprpaper >/dev/null && pkill -x hyprpaper
	pgrep -x mpvpaper >/dev/null && pkill -x mpvpaper
    pgrep -x swww-daemon >/dev/null || swww-daemon &
	swww img "$WALLPAPER_DIR/$SELECTED_WALLPAPER" --transition-type any
	swww img "$WALLPAPER_DIR/$SELECTED_WALLPAPER" --transition-type any
fi
