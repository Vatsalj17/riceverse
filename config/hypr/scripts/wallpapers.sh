#!/bin/bash

pkill swww-daemon && swww-daemon &

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
SELECTED_WALLPAPER=$(ls "$WALLPAPER_DIR" | wofi --dmenu --width 600 --height 400 --prompt "Select a Wallpaper")

if [ -n "$SELECTED_WALLPAPER" ]; then
    swww img "$WALLPAPER_DIR/$SELECTED_WALLPAPER" --transition-type any
fi

