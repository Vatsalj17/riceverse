#!/bin/bash

WALLPAPER_DIR="$HOME/Videos/wallpapers"
THUMB_DIR="$HOME/.cache/live_wallpaper_thumbs"
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"

mkdir -p "$THUMB_DIR"

generate_thumbnail() {
    local video="$1"
    local filename=$(basename "$video")
    local thumb_path="$THUMB_DIR/${filename%.*}.png"

    if [[ ! -f "$thumb_path" ]]; then
        # Extract frame at 3 seconds, fallback to first frame
        ffmpeg -ss 3 -i "$video" -vf "scale=300:200:force_original_aspect_ratio=increase,crop=300:200" \
            -vframes 1 "$thumb_path" 2>/dev/null
        if [[ ! -f "$thumb_path" ]]; then
            ffmpeg -i "$video" -vf "scale=300:200:force_original_aspect_ratio=increase,crop=300:200" \
                -vframes 1 "$thumb_path" 2>/dev/null
        fi
    fi
    echo "$thumb_path"
}

entries=""
declare -A name_to_path

for video in "$WALLPAPER_DIR"/*; do
    [[ -f "$video" ]] || continue
    filename=$(basename "$video")
    name="${filename%.*}"
    thumb=$(generate_thumbnail "$video")

    if [[ -f "$thumb" ]]; then
        entries+="${name}\0icon\x1f${thumb}\n"
    else
        entries+="${name}\n"
    fi
    name_to_path["$name"]="$video"
done

SELECTED=$(echo -e "$entries" | rofi \
    -dmenu \
    -i \
    -p "󰎁  Live" \
    -theme "$ROFI_THEME" \
    -show-icons)

[[ -z "$SELECTED" ]] && exit 0

VIDEO_PATH="${name_to_path[$SELECTED]}"
[[ -z "$VIDEO_PATH" ]] && exit 0

# Kill everything before starting mpvpaper
pkill -x awww-daemon 2>/dev/null
pkill -x hyprpaper 2>/dev/null
pkill -x mpvpaper 2>/dev/null

mpvpaper -p -f -o "--loop --no-audio --load-scripts=no" eDP-1 "$VIDEO_PATH" &
echo "Live wallpaper set: $SELECTED"
