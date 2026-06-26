#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper_thumbs"
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"

mkdir -p "$THUMB_DIR"

generate_thumbnail() {
    local wallpaper="$1"
    local filename=$(basename "$wallpaper")
    local thumb_path="$THUMB_DIR/${filename%.*}.png"

    if [[ ! -f "$thumb_path" ]]; then
        convert "$wallpaper" -resize 300x200^ -gravity center -extent 300x200 "$thumb_path" 2>/dev/null
        if [[ ! -f "$thumb_path" ]]; then
            ffmpeg -i "$wallpaper" -vf "scale=300:200:force_original_aspect_ratio=increase,crop=300:200" -vframes 1 "$thumb_path" 2>/dev/null
        fi
    fi
    echo "$thumb_path"
}

entries=""
declare -A name_to_path

for wallpaper in "$WALLPAPER_DIR"/*; do
    [[ -f "$wallpaper" ]] || continue
    filename=$(basename "$wallpaper")
    name="${filename%.*}"
    thumb=$(generate_thumbnail "$wallpaper")

    if [[ -f "$thumb" ]]; then
        entries+="${name}\0icon\x1f${thumb}\n"
    else
        entries+="${name}\n"
    fi
    name_to_path["$name"]="$wallpaper"
done

SELECTED=$(echo -e "$entries" | rofi \
    -dmenu \
    -i \
    -p "󰸉  Search" \
    -theme "$ROFI_THEME" \
    -show-icons)

[[ -z "$SELECTED" ]] && exit 0

WALLPAPER_PATH="${name_to_path[$SELECTED]}"
[[ -z "$WALLPAPER_PATH" ]] && exit 0

killed_mpvpaper=0

pkill -x hyprpaper 2>/dev/null
pkill -x mpvpaper 2>/dev/null && killed_mpvpaper=1
pgrep -x awww-daemon >/dev/null || awww-daemon &
awww img "$WALLPAPER_PATH" --transition-type any
if (( killed_mpvpaper == 1 )); then
    awww img "$WALLPAPER_PATH" --transition-type any
fi
echo "Wallpaper set: $SELECTED"
