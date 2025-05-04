#!/bin/bash

# Enhanced battery.sh for Arch Linux
# Displays battery status with appropriate icons and additional details

# --- CONFIGURATION ---
# Icon sets using Nerd Font icons

# Discharging icons at different levels
BATTERY_DISCHARGING_CRITICAL="󰁺"   # 0-5%
BATTERY_DISCHARGING_0="󰁻"   # 5-10%
BATTERY_DISCHARGING_1="󰁼"   # 10-20%
BATTERY_DISCHARGING_2="󰁽"   # 20-30%
BATTERY_DISCHARGING_3="󰁾"   # 30-40%
BATTERY_DISCHARGING_4="󰁿"   # 40-50%
BATTERY_DISCHARGING_5="󰂀"   # 50-60%
BATTERY_DISCHARGING_6="󰂁"   # 60-70%
BATTERY_DISCHARGING_7="󰂂"   # 70-80%
BATTERY_DISCHARGING_8="󰂃"   # 80-90%
BATTERY_DISCHARGING_9="󰁹"   # 90-100%

# Charging icons at different levels
BATTERY_CHARGING_0="󰢜"   # 0-10%
BATTERY_CHARGING_1="󰂆"   # 10-30%
BATTERY_CHARGING_2="󰂇"   # 30-50%
BATTERY_CHARGING_3="󰂈"   # 50-70%
BATTERY_CHARGING_4="󰂉"   # 70-90%
BATTERY_CHARGING_5="󰂅"   # 90-100%

# Full and plugged in
BATTERY_FULL_PLUGGED="󰂄"

# Not charging (plugged but not charging - often happens when battery is full)
BATTERY_NOT_CHARGING="󰁙"

# No battery detected
NO_BATTERY="󰚥"

# Low battery threshold (percentage)
LOW_BATTERY_THRESHOLD=15
CRITICAL_BATTERY_THRESHOLD=5

# --- FUNCTIONS ---

# Find the battery device
find_battery() {
    local battery_path=""
    
    # First look for common battery paths
    for bat in /sys/class/power_supply/BAT*; do
        if [ -e "$bat/capacity" ]; then
            battery_path="${bat##*/}"
            break
        fi
    done
    
    # If no standard BAT* found, look for CMB* (some laptops use this)
    if [ -z "$battery_path" ]; then
        for bat in /sys/class/power_supply/CMB*; do
            if [ -e "$bat/capacity" ]; then
                battery_path="${bat##*/}"
                break
            fi
        done
    fi
    
    echo "$battery_path"
}

# Get time remaining estimate
get_time_remaining() {
    local status=$1
    local rate power full now

    # We only calculate time remaining when discharging
    if [ "$status" != "Discharging" ]; then
        return
    fi
    
    # Try using the power_now and energy_now values if available
    if [ -f "/sys/class/power_supply/$BATTERY/power_now" ] && [ -f "/sys/class/power_supply/$BATTERY/energy_now" ]; then
        rate=$(cat "/sys/class/power_supply/$BATTERY/power_now")
        now=$(cat "/sys/class/power_supply/$BATTERY/energy_now")
        
        # Avoid division by zero and tiny rates (which would give huge times)
        if [ "$rate" -gt 10000 ]; then
            # Calculate hours remaining (energy/power)
            # The result is in microwatt-hours / microwatts = hours
            time_h=$(echo "scale=1; $now / $rate" | bc)
            echo " ${time_h}h"
        fi
    # Alternatively, try current_now and charge_now
    elif [ -f "/sys/class/power_supply/$BATTERY/current_now" ] && [ -f "/sys/class/power_supply/$BATTERY/charge_now" ]; then
        rate=$(cat "/sys/class/power_supply/$BATTERY/current_now")
        now=$(cat "/sys/class/power_supply/$BATTERY/charge_now")
        
        # Avoid division by zero and tiny rates
        if [ "$rate" -gt 10000 ]; then
            # Calculate hours remaining (charge/current)
            time_h=$(echo "scale=1; $now / $rate" | bc)
            echo " ${time_h}h"
        fi
    fi
}

# Get battery icon based on status and level
get_battery_icon() {
    local status=$1
    local level=$2
    
    case "$status" in
        "Charging")
            if [ "$level" -lt 10 ]; then
                echo "$BATTERY_CHARGING_0"
            elif [ "$level" -lt 30 ]; then
                echo "$BATTERY_CHARGING_1"
            elif [ "$level" -lt 50 ]; then
                echo "$BATTERY_CHARGING_2"
            elif [ "$level" -lt 70 ]; then
                echo "$BATTERY_CHARGING_3"
            elif [ "$level" -lt 90 ]; then
                echo "$BATTERY_CHARGING_4"
            else
                echo "$BATTERY_CHARGING_5"
            fi
            ;;
        "Discharging")
            if [ "$level" -lt 5 ]; then
                echo "$BATTERY_DISCHARGING_CRITICAL"
            elif [ "$level" -lt 10 ]; then
                echo "$BATTERY_DISCHARGING_0"
            elif [ "$level" -lt 20 ]; then
                echo "$BATTERY_DISCHARGING_1"
            elif [ "$level" -lt 30 ]; then
                echo "$BATTERY_DISCHARGING_2"
            elif [ "$level" -lt 40 ]; then
                echo "$BATTERY_DISCHARGING_3"
            elif [ "$level" -lt 50 ]; then
                echo "$BATTERY_DISCHARGING_4"
            elif [ "$level" -lt 60 ]; then
                echo "$BATTERY_DISCHARGING_5"
            elif [ "$level" -lt 70 ]; then
                echo "$BATTERY_DISCHARGING_6"
            elif [ "$level" -lt 80 ]; then
                echo "$BATTERY_DISCHARGING_7"
            elif [ "$level" -lt 90 ]; then
                echo "$BATTERY_DISCHARGING_8"
            else
                echo "$BATTERY_DISCHARGING_9"
            fi
            ;;
        "Full")
            echo "$BATTERY_FULL_PLUGGED"
            ;;
        "Not charging")
            echo "$BATTERY_NOT_CHARGING"
            ;;
        *)
            echo "$BATTERY_DISCHARGING_9"
            ;;
    esac
}

# --- MAIN SCRIPT ---

# Check if acpi is available for additional info
HAS_ACPI=0
if command -v acpi >/dev/null 2>&1; then
    HAS_ACPI=1
fi

# Check if we have bc for calculations
HAS_BC=0
if command -v bc >/dev/null 2>&1; then
    HAS_BC=1
fi

# Find battery
BATTERY=$(find_battery)

# Check if we found a battery
if [ -z "$BATTERY" ]; then
    echo "$NO_BATTERY"  # No battery found - show AC power icon
    exit 0
fi

# Get battery status info from sysfs
STATUS=$(cat "/sys/class/power_supply/$BATTERY/status" 2>/dev/null)
CAPACITY=$(cat "/sys/class/power_supply/$BATTERY/capacity" 2>/dev/null)

# Default values if reading fails
if [ -z "$STATUS" ]; then STATUS="Unknown"; fi
if [ -z "$CAPACITY" ]; then CAPACITY=100; fi

# Get the appropriate icon
ICON=$(get_battery_icon "$STATUS" "$CAPACITY")

# Format output based on status
if [ "$STATUS" = "Discharging" ]; then
    # Check if we should add time remaining estimate
    if [ "$HAS_BC" -eq 1 ]; then
        TIME_REMAINING=$(get_time_remaining "$STATUS")
    else
        TIME_REMAINING=""
    fi
    
    # Add warning symbol for low battery
    if [ "$CAPACITY" -le "$CRITICAL_BATTERY_THRESHOLD" ]; then
        echo "$ICON $CAPACITY%⚠️"
    elif [ "$CAPACITY" -le "$LOW_BATTERY_THRESHOLD" ]; then
        echo "$ICON $CAPACITY%⚠"
    else
        # Normal display with optional time remaining
        if [ -n "$TIME_REMAINING" ]; then
            echo "$ICON $CAPACITY%$TIME_REMAINING"
        else
            echo "$ICON"
        fi
    fi
elif [ "$STATUS" = "Charging" ]; then
    echo "$ICON"
elif [ "$STATUS" = "Full" ] || [ "$STATUS" = "Not charging" ]; then
    echo "$ICON"
else
    # Unknown status
    echo "$ICON $CAPACITY%"
fi
