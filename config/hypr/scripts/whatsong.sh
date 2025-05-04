#!/bin/bash

# Check if playerctl is installed
if ! command -v playerctl &> /dev/null; then
    echo " No media"
    exit 0
fi

# Get the player status
player_status=$(playerctl status 2> /dev/null)

if [[ "$player_status" = "Playing" ]]; then
    title=$(playerctl metadata title 2> /dev/null)
    
    # Handle potentially long titles by truncating, with increased length
    if [[ ${#title} -gt 60 ]]; then
        title="${title:0:100}..."
    fi
    
    echo " $title"
elif [[ "$player_status" = "Paused" ]]; then
    title=$(playerctl metadata title 2> /dev/null)
    
    # Handle potentially long titles by truncating, with increased length
    if [[ ${#title} -gt 60 ]]; then
        title="${title:0:57}..."
    fi
    
    echo " $title (Paused)"
else
    echo " No media"
fi
