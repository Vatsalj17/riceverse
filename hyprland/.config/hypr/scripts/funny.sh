#!/bin/bash

# Funny Command Fail Notifier for Hyprland + swaync
# Place this in ~/.local/bin/command-fail-notifier and make executable

# Path to the lines file (relative to script location)
LINES_FILE="${BASH_SOURCE%/*}/lines.txt"

# Function to get random message from lines.txt
get_random_message() {
    # Check if lines.txt exists
    if [[ ! -f "$LINES_FILE" ]]; then
        echo "🤖 Command not found. Also, lines.txt is missing!"
        return 1
    fi
    
    # Read all non-empty lines into an array
    local lines=()
    while IFS= read -r line; do
        # Skip empty lines and comments (lines starting with #)
        [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]] && lines+=("$line")
    done < "$LINES_FILE"
    
    # Check if we have any lines
    if [[ ${#lines[@]} -eq 0 ]]; then
        echo "🤖 Command not found. Also, lines.txt is empty!"
        return 1
    fi
    
    # Get random line
    local random_index=$((RANDOM % ${#lines[@]}))
    echo "${lines[$random_index]}"
}

# Function to send notification
send_notification() {
    local message="$1"
    local failed_command="$2"
    
    # Send notification via swaync
    notify-send -u normal -t 4000 \
        -i "dialog-error" \
        "Command Oops!" \
        "$message\n\nFailed: <i>$failed_command</i>"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main function to handle command checking
check_command() {
    local cmd="$1"
    
    # Skip if empty or starts with common valid patterns
    [[ -z "$cmd" ]] && return 0
    [[ "$cmd" =~ ^(cd|ls|pwd|echo|export|source|\.|sudo|su|exit|clear|history)$ ]] && return 0
    [[ "$cmd" =~ ^(nvim|nvim|tmux|kitty|firefox|brave)$ ]] && return 0
    [[ "$cmd" =~ ^[[:space:]]*$ ]] && return 0
    
    # Check if it's a valid command, builtin, or alias
    if ! command_exists "$cmd" && ! type "$cmd" >/dev/null 2>&1; then
        local message=$(get_random_message)
        send_notification "$message" "$cmd"
        return 1
    fi
    
    return 0
}

# Trap function for command_not_found_handle
command_not_found_handle() {
    local cmd="$1"
    local message=$(get_random_message)
    send_notification "$message" "$cmd"
    
    # Still show the regular error
    echo "bash: $cmd: command not found" >&2
    return 127
}

# If sourced, set up the trap
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f command_not_found_handle
else
    # If run directly, check the provided command
    if [[ $# -gt 0 ]]; then
        check_command "$1"
    else
        echo "Usage: $0 <command-to-check>"
        echo "Or source this script in your .bashrc/.zshrc"
    fi
fi

# Optional: Monitor for rapid-fire failures (3+ in 10 seconds)
declare -a recent_failures=()

track_failure() {
    local current_time=$(date +%s)
    recent_failures+=("$current_time")
    
    # Clean old entries (older than 10 seconds)
    local temp_array=()
    for timestamp in "${recent_failures[@]}"; do
        if (( current_time - timestamp <= 10 )); then
            temp_array+=("$timestamp")
        fi
    done
    recent_failures=("${temp_array[@]}")
    
    # If 3+ failures in 10 seconds, send special message
    if (( ${#recent_failures[@]} >= 3 )); then
        notify-send -u critical -t 6000 \
            -i "face-laugh" \
            "Rapid Fire Mode!" \
            "🔥 Someone's having a typing day! Maybe it's time for coffee? ☕"
        recent_failures=()  # Reset counter
    fi
}

# Enhanced command_not_found_handle with tracking
command_not_found_handle() {
    local cmd="$1"
    local message=$(get_random_message)
    send_notification "$message" "$cmd"
    track_failure
    
    echo "bash: $cmd: command not found" >&2
    return 127
}
