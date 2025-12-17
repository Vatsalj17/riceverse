#!/bin/bash

USER_ICON="󰀄"             # User
HOSTNAME_ICON="󰇅"         # Computer/Host
DISTRO_ICON="󰣇"           # Arch Linux logo
KERNEL_ICON="󰒔"           # Kernel
UPTIME_ICON="󱑁"           # Clock/Uptime
CPU_ICON="󰘚"              # Processor
MEMORY_ICON="󰍛"           # RAM
TEMP_ICON="󰔏"             # Temperature
PACKAGES_ICON="󰏖"         # Packages

RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"

# Settings
SHOW_PACKAGES=true         # Show package count
SHOW_CPU_TEMP=true         # Show CPU temperature
SHOW_MEMORY=true           # Show memory usage
COMPACT_MODE=true         # Set to true for more compact output


get_distro_info() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "$NAME $VERSION_ID"
    elif [ -f /etc/arch-release ]; then
        echo "Arch Linux"
    else
        echo "Unknown Linux"
    fi
}

# Get uptime in a human-readable format
get_uptime() {
    uptime -p | sed 's/^up //'
}

# Get CPU model
get_cpu_model() {
    grep -m 1 "model name" /proc/cpuinfo | cut -d':' -f2- | sed 's/^[ \t]*//' | 
    sed 's/(R)//g; s/(TM)//g; s/CPU //g; s/Intel //g; s/AMD //g; s/ @ .*//g' | 
    awk '{$1=$1};1'
}

# Get CPU temperature
get_cpu_temp() {
    # Try different temperature sources
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        # Value is in millidegrees Celsius
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        echo "$((temp/1000))°C"
    elif [ -f /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input ]; then
        # Value is in millidegrees Celsius
        temp=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input)
        echo "$((temp/1000))°C"
    elif command -v sensors > /dev/null 2>&1; then
        # Try using lm_sensors
        temp=$(sensors | grep -m 1 -E "Core|Tdie" | awk '{print $3}' | sed 's/[^0-9.]//g')
        if [ -n "$temp" ]; then
            echo "${temp}°C"
        else
            echo "N/A"
        fi
    else
        echo "N/A"
    fi
}

# Get memory usage
get_memory_usage() {
    if [ -f /proc/meminfo ]; then
        # Extract memory information from /proc/meminfo
        mem_total=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
        mem_available=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
        
        if [ -n "$mem_total" ] && [ -n "$mem_available" ]; then
            mem_used=$((mem_total - mem_available))
            mem_used_percent=$((mem_used * 100 / mem_total))
            
            # Convert to more readable format (GB)
            mem_total_gb=$(echo "scale=1; $mem_total / 1024 / 1024" | bc)
            mem_used_gb=$(echo "scale=1; $mem_used / 1024 / 1024" | bc)
            
            echo "${mem_used_gb}GB/${mem_total_gb}GB (${mem_used_percent}%)"
        else
            echo "N/A"
        fi
    else
        echo "N/A"
    fi
}

# Get installed package count
get_package_count() {
    # Check for pacman (Arch)
    if command -v pacman > /dev/null 2>&1; then
        pacman -Q | wc -l
    # Check for other package managers if needed
    else
        echo "N/A"
    fi
}

# --- MAIN SCRIPT ---

# Check for required tools
if ! command -v bc > /dev/null 2>&1; then
    BC_AVAILABLE=false
else
    BC_AVAILABLE=true
fi

# Get system information
USERNAME=$(whoami)
HOSTNAME=$(hostname)
DISTRO=$(get_distro_info)
KERNEL=$(uname -r)
UPTIME=$(get_uptime)
CPU=$(get_cpu_model)

# Format output based on settings
if [ "$COMPACT_MODE" = false ]; then
    # Compact mode: username@hostname • distro • kernel • uptime
    echo "$USER_ICON $USERNAME@$HOSTNAME • $DISTRO_ICON $DISTRO • $KERNEL_ICON $KERNEL • $UPTIME_ICON $UPTIME"
else
    # Full mode: Add more details
    OUTPUT="$USER_ICON $USERNAME • $DISTRO_ICON $DISTRO"
    
    # Add uptime
    # OUTPUT="$OUTPUT • $UPTIME_ICON $UPTIME"
    
    # Add CPU info
    # if [ -n "$CPU" ]; then
    #     OUTPUT="$OUTPUT • $CPU_ICON $CPU"
    # fi
    
    # Add CPU temperature
    # if [ "$SHOW_CPU_TEMP" = true ]; then
    #     CPU_TEMP=$(get_cpu_temp)
    #     if [ "$CPU_TEMP" != "N/A" ]; then
    #         OUTPUT="$OUTPUT ($TEMP_ICON $CPU_TEMP)"
    #     fi
    # fi
    
    # Add memory usage
    # if [ "$SHOW_MEMORY" = true ] && [ "$BC_AVAILABLE" = true ]; then
    #     MEM_USAGE=$(get_memory_usage)
    #     if [ "$MEM_USAGE" != "N/A" ]; then
    #         OUTPUT="$OUTPUT • $MEMORY_ICON $MEM_USAGE"
    #     fi
    # fi
    
    # Add package count
    # if [ "$SHOW_PACKAGES" = true ]; then
    #     PACKAGES=$(get_package_count)
    #     if [ "$PACKAGES" != "N/A" ]; then
    #         OUTPUT="$OUTPUT • $PACKAGES_ICON $PACKAGES"
    #     fi
    # fi
    
    echo "$OUTPUT"
fi
