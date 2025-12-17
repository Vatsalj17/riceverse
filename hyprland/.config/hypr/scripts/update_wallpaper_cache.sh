#!/bin/bash

# --- Configuration ---
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper_thumbs"
CACHE_FILE="$HOME/.cache/wallpaper_list.txt"

# --- Setup ---
# Ensure thumbnail directory exists
mkdir -p "$THUMB_DIR"

# Clear the old wallpaper list file before regenerating
> "$CACHE_FILE"

echo "Starting wallpaper cache update..."
echo "  - List file: $CACHE_FILE"
echo "  - Thumbnails: $THUMB_DIR"

# --- Thumbnail Generation Function (Improved) ---
# This function is now a true "updater":
# 1. It checks if the thumbnail doesn't exist.
# 2. OR if the original wallpaper is NEWER than the thumbnail.
generate_thumbnail() {
    local wallpaper_path="$1"
    local filename=$(basename "$wallpaper_path")
    # We force .png for all thumbnails for consistency
    local thumb_path="$THUMB_DIR/${filename%.*}.png"

    # The Core Update Logic:
    if [[ ! -f "$thumb_path" || "$wallpaper_path" -nt "$thumb_path" ]]; then
        echo "  -> Updating thumbnail for: $filename"
        
        # Try imagemagick (convert) first - it's generally faster for this
        # [0] selects the first frame (for GIFs/multi-frame images)
        # -thumbnail is optimized for thumbs (faster than -resize, strips metadata)
        convert "$wallpaper_path[0]" -thumbnail 200x150^ -gravity center -extent 200x150 "$thumb_path" 2>/dev/null
        
        # Fallback to ffmpeg if convert failed (e.g., not installed or bad format)
        if [[ $? -ne 0 || ! -f "$thumb_path" ]]; then
            echo "     (convert failed, trying ffmpeg...)"
            
            # This ffmpeg filter chain mimics the "fill and crop" logic:
            # 1. Scale smallest dim to 200 or 150 (force_original_aspect_ratio=increase)
            # 2. Crop the 200x150 center
            ffmpeg -i "$wallpaper_path" -vf "thumbnail,scale=200:150:force_original_aspect_ratio=increase,crop=200:150" -vframes 1 "$thumb_path" 2>/dev/null
        fi
    fi
}

# Export the function so 'find -exec' can use it
export -f generate_thumbnail
export THUMB_DIR # Export variables needed by the function

# --- Main Processing ---
# Use 'find' to get all image files, including in subdirectories.
# This is more robust than looping with '*'.
# We execute two commands for each file found:
# 1. 'sh -c' to append the full path to our cache file
# 2. 'sh -c' to call our thumbnail function

echo "Finding all images and processing..."
find "$WALLPAPER_DIR" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.bmp" -o \
    -iname "*.gif" -o \
    -iname "*.webp" \
\) -exec sh -c 'echo "$0" >> "$1"' {} "$CACHE_FILE" \; \
  -exec sh -c 'generate_thumbnail "$0"' {} \;

echo "Cache update complete."
