#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper_thumbs"

# Create thumbnail directory if it doesn't exist
mkdir -p "$THUMB_DIR"

# Function to generate thumbnail
generate_thumbnail() {
    local wallpaper="$1"
    local filename=$(basename "$wallpaper")
    local thumb_path="$THUMB_DIR/${filename%.*}.png"
    
    if [[ ! -f "$thumb_path" ]]; then
        # Generate thumbnail using imagemagick
        convert "$wallpaper" -resize 200x150^ -gravity center -extent 200x150 "$thumb_path" 2>/dev/null
        
        # Fallback to ffmpeg if imagemagick fails
        if [[ ! -f "$thumb_path" ]]; then
            ffmpeg -i "$wallpaper" -vf "scale=200:150" -vframes 1 "$thumb_path" 2>/dev/null
        fi
    fi
    
    if [[ -f "$thumb_path" ]]; then
        echo "$thumb_path"
    fi
}

# Check if rofi is installed
if ! command -v rofi >/dev/null 2>&1; then
    echo "Error: rofi is not installed. Install it with: sudo pacman -S rofi"
    echo "Rofi is needed for image preview functionality."
    exit 1
fi

# Generate thumbnails and create rofi entries
entries=""
declare -A thumb_to_file

for wallpaper in "$WALLPAPER_DIR"/*; do
    if [[ -f "$wallpaper" ]]; then
        filename=$(basename "$wallpaper")
        name_without_ext="${filename%.*}"
        
        thumb_path=$(generate_thumbnail "$wallpaper")
        
        if [[ -n "$thumb_path" && -f "$thumb_path" ]]; then
            entries+="$name_without_ext\0icon\x1f$thumb_path\n"
            thumb_to_file["$name_without_ext"]="$filename"
        else
            entries+="$name_without_ext\n"
            thumb_to_file["$name_without_ext"]="$filename"
        fi
    fi
done

# Create rofi theme file
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"
mkdir -p "$(dirname "$ROFI_THEME")"

# Display rofi menu with image previews
SELECTED_WALLPAPER=$(echo -e "$entries" | rofi -dmenu -i -p "Select Wallpaper" -theme "$ROFI_THEME" -show-icons)

if [[ -n "$SELECTED_WALLPAPER" ]]; then
    ACTUAL_FILENAME="${thumb_to_file["$SELECTED_WALLPAPER"]}"
    
    if [[ -n "$ACTUAL_FILENAME" ]]; then
        WALLPAPER_PATH="$WALLPAPER_DIR/$ACTUAL_FILENAME"
        
        # Kill existing wallpaper processes
        pgrep -x hyprpaper >/dev/null && pkill -x hyprpaper
        pgrep -x mpvpaper >/dev/null && pkill -x mpvpaper
        
        # Start swww daemon if not running
        pgrep -x swww-daemon >/dev/null || swww-daemon &
        
        # Set the wallpaper
        swww img "$WALLPAPER_PATH" --transition-type any
        swww img "$WALLPAPER_PATH" --transition-type any
        
        echo "Wallpaper set to: $ACTUAL_FILENAME"
    fi
fi
