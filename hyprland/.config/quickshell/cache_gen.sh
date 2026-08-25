#!/usr/bin/env bash

THUMBS="$HOME/.cache/wallpaper_picker/thumbs"
WALLS="$HOME/Pictures/Wallpapers"
VIDS="$HOME/Videos/wallpapers"

IMG_JOBS=6   # parallel image workers  (tune to your CPU)
VID_JOBS=3   # parallel video workers  (keep low, ffmpeg is heavy)

mkdir -p "$THUMBS"

# ── Catppuccin Mocha ─────────────────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'

# Base palette
TEXT='\033[38;2;205;214;244m'        # #cdd6f4
OVERLAY='\033[38;2;108;112;134m'     # #6c7086  (overlay0)
GREEN='\033[38;2;166;227;161m'       # #a6e3a1
YELLOW='\033[38;2;249;226;175m'      # #f9e2af

# Image theme — Blue + Sapphire
I_PRI='\033[38;2;137;180;250m'       # #89b4fa  blue
I_SEC='\033[38;2;116;199;236m'       # #74c7ec  sapphire
I_BAR='\033[38;2;137;180;250m'       # #89b4fa  blue
I_SKIP='\033[38;2;108;112;134m'      # #6c7086  overlay0

# Video theme — Peach + Mauve
V_PRI='\033[38;2;250;179;135m'       # #fab387  peach
V_SEC='\033[38;2;203;166;247m'       # #cba6f7  mauve
V_BAR='\033[38;2;250;179;135m'       # #fab387  peach
V_SKIP='\033[38;2;108;112;134m'      # #6c7086  overlay0

# ── Progress bar ─────────────────────────────────────────────────────────────
draw_bar() {
    local cur=$1 total=$2 bc=$3
    local width=36
    local filled=$(( total > 0 ? cur * width / total : 0 ))
    local empty=$(( width - filled ))
    local pct=$(( total > 0 ? cur * 100 / total : 0 ))
    local bar=""
    for (( i=0; i<filled; i++ )); do bar+="█"; done
    for (( i=0; i<empty;  i++ )); do bar+="░"; done
    printf "  ${bc}[${bar}]${RESET} ${BOLD}${TEXT}%3d%%${RESET} ${OVERLAY}%d/%d${RESET}" "$pct" "$cur" "$total"
}

# ── Display loop ──────────────────────────────────────────────────────────────
display_loop() {
    local log=$1 total=$2 bc=$3 sec=$5 skipc=$6 label=$7 workers=$8
    local TAIL=6
    local done_count=0 new_count=0 skip_count=0
    local -a recent=()

    for (( i=0; i < TAIL + 2; i++ )); do printf "\n"; done

    while true; do
        local new_lines
        new_lines=$(tail -n +$(( done_count + 1 )) "$log" 2>/dev/null)

        while IFS= read -r line; do
            [ -z "$line" ] && continue
            local status="${line:0:1}"
            recent+=("$line")
            (( done_count++ ))
            [[ "$status" == "+" ]] && (( new_count++ ))
            [[ "$status" == "-" ]] && (( skip_count++ ))
        done <<< "$new_lines"

        printf "\033[%dA" $(( TAIL + 2 ))

        printf "\r\033[K"
        draw_bar "$done_count" "$total" "$bc"
        printf "  ${OVERLAY}(${workers} workers)${RESET}\n"

        local start=$(( ${#recent[@]} - TAIL ))
        (( start < 0 )) && start=0
        for (( i=start; i<${#recent[@]}; i++ )); do
            local entry="${recent[$i]}"
            local st="${entry:0:1}"
            local fn="${entry:2}"
            printf "\033[K"
            if [[ "$st" == "+" ]]; then
                printf "  ${GREEN}✓  ${sec}%-45s${RESET}  ${OVERLAY}done${RESET}\n" "$fn"
            else
                printf "  ${skipc}↷  %-45s${RESET}  ${OVERLAY}cached${RESET}\n" "$fn"
            fi
        done

        local shown=$(( ${#recent[@]} - start ))
        for (( i=shown; i<TAIL; i++ )); do printf "\033[K\n"; done
        printf "\033[K\n"

        (( done_count >= total )) && break
        sleep 0.12
    done

    printf "\033[%dA" $(( TAIL + 2 ))
    printf "\r\033[K"
    draw_bar "$total" "$total" "$bc"
    printf "  ${OVERLAY}(${IMG_JOBS} workers)${RESET}\n"
    for (( i=0; i<TAIL+1; i++ )); do printf "\033[K\n"; done

    echo -e "  ${GREEN}${BOLD}✓ ${label} complete${RESET} ${OVERLAY}—${RESET} ${BOLD}${TEXT}${new_count} generated${RESET}  ${OVERLAY}${skip_count} cached${RESET}\n"
}

# ── Worker: single image ──────────────────────────────────────────────────────
process_image() {
    local f=$1 thumbs=$2 log=$3
    local fname
    fname=$(basename "$f")
    if [ -f "$thumbs/$fname" ]; then
        echo "- $fname" >> "$log"
    else
        magick "$f" -resize x840 -quality 90 "$thumbs/$fname"
        echo "+ $fname" >> "$log"
    fi
}
export -f process_image

# ── Worker: single video ──────────────────────────────────────────────────────
process_video() {
    local v=$1 thumbs=$2 log=$3
    local fname thumb_name
    fname=$(basename "$v")
    thumb_name="${fname}.jpg"
    if [ -f "$thumbs/$thumb_name" ]; then
        echo "- $fname" >> "$log"
    else
        ffmpeg -y -ss 00:00:03 -i "$v" \
            -vframes 1 \
            -vf "scale=-1:840,crop=840:840" \
            -q:v 1 \
            -f image2 "$thumbs/$thumb_name" -loglevel quiet 2>/dev/null
        echo "+ $fname" >> "$log"
    fi
}
export -f process_video

# ── Collect file lists ────────────────────────────────────────────────────────
mapfile -t img_files < <(find "$WALLS" -maxdepth 1 -type f | sort)
mapfile -t vid_files < <(find "$VIDS" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" -o -name "*.mov" \) | sort)

total_imgs=${#img_files[@]}
total_vids=${#vid_files[@]}

# ── Header ────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${TEXT}  Wallpaper Thumbnail Cache Builder${RESET}"
echo -e "  ${OVERLAY}cache → ${THUMBS}${RESET}\n"


# ╔══════════════════════════════════════════════════════╗
# ║  IMAGES                                              ║
# ╚══════════════════════════════════════════════════════╝
echo -e "  ${BOLD}${I_PRI}▐ IMAGES${RESET}  ${OVERLAY}${WALLS}${RESET}"
echo -e "  ${I_SEC}${total_imgs} wallpaper(s) found  ${OVERLAY}•  ${IMG_JOBS} parallel workers${RESET}\n"

if (( total_imgs > 0 )); then
    img_log=$(mktemp)
    display_loop "$img_log" "$total_imgs" "$I_BAR" "$I_PRI" "$I_SEC" "$I_SKIP" "Images" "$IMG_JOBS" &
    disp_pid=$!

    printf '%s\n' "${img_files[@]}" | \
        xargs -P "$IMG_JOBS" -I{} bash -c 'process_image "$@"' _ {} "$THUMBS" "$img_log"

    wait "$disp_pid"
    rm -f "$img_log"
else
    echo -e "  ${YELLOW}⚠  No images found, skipping.${RESET}\n"
fi

echo -e "  ${OVERLAY}────────────────────────────────────────────${RESET}\n"


# ╔══════════════════════════════════════════════════════╗
# ║  VIDEOS                                              ║
# ╚══════════════════════════════════════════════════════╝
echo -e "  ${BOLD}${V_PRI}▐ VIDEOS${RESET}  ${OVERLAY}${VIDS}${RESET}"
echo -e "  ${V_SEC}${total_vids} video(s) found  ${OVERLAY}•  ${VID_JOBS} parallel workers${RESET}\n"

if (( total_vids > 0 )); then
    vid_log=$(mktemp)
    display_loop "$vid_log" "$total_vids" "$V_BAR" "$V_PRI" "$V_SEC" "$V_SKIP" "Videos" "$VID_JOBS" &
    disp_pid=$!

    printf '%s\n' "${vid_files[@]}" | \
        xargs -P "$VID_JOBS" -I{} bash -c 'process_video "$@"' _ {} "$THUMBS" "$vid_log"

    wait "$disp_pid"
    rm -f "$vid_log"
else
    echo -e "  ${YELLOW}⚠  No videos found, skipping.${RESET}\n"
fi

echo -e "  ${OVERLAY}────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${GREEN}  All done!${RESET}  ${OVERLAY}thumbs cached at ${THUMBS}${RESET}\n"
