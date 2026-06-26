#!/bin/bash

# Configuration
RAM_THRESH=75
TEMP_THRESH=80
BAT_LOW=15
BAT_CRIT=5

RAM_COOLDOWN=120
TEMP_COOLDOWN=120
BAT_COOLDOWN=300
LOOP_INTERVAL=30

last_ram_notify=0
last_temp_notify=0
last_bat_notify=0

while true; do
    current_time=$(date +%s)

    # RAM Check
    if (( current_time - last_ram_notify >= RAM_COOLDOWN )); then
        RAM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
        if [ "$RAM_USAGE" -ge "$RAM_THRESH" ]; then
            TOP_PROCESS=$(ps aux --no-headers | awk '$11 !~ /^\[.*\]$/ {print $11, $4}' | sort -k2 -nr | head -1)
            PROCESS_NAME=$(echo "$TOP_PROCESS" | awk '{print $1}' | sed 's/.*\///')
            PROCESS_RAM=$(echo "$TOP_PROCESS" | awk '{printf "%.1f", $2}')
            notify-send -u critical "⚠️ High RAM Usage!" "RAM: ${RAM_USAGE}% | Top Process: ${PROCESS_NAME} (${PROCESS_RAM}%)"
            last_ram_notify=$current_time
        fi
    fi

    # CPU Temp Check
    if (( current_time - last_temp_notify >= TEMP_COOLDOWN )); then
        CPU_TEMP=$(sensors | awk '/Package id 0:/ {print $4+0}')
        if [[ -n "$CPU_TEMP" ]] && [ "$CPU_TEMP" -ge "$TEMP_THRESH" ]; then
            TOP_PROCESS=$(ps aux --no-headers | awk '$11 !~ /^\[.*\]$/ {print $11, $3}' | sort -k2 -nr | head -1)
            PROCESS_NAME=$(echo "$TOP_PROCESS" | awk '{print $1}' | sed 's/.*\///')
            PROCESS_CPU=$(echo "$TOP_PROCESS" | awk '{printf "%.1f", $2}')
            notify-send -u critical "🔥 CPU Overheating!" "Temperature: ${CPU_TEMP}°C | Top Process: ${PROCESS_NAME} (${PROCESS_CPU}%)"
            last_temp_notify=$current_time
        fi
    fi

    # Battery Check (using sysfs for near-zero overhead)
    if (( current_time - last_bat_notify >= BAT_COOLDOWN )); then
        if [[ -d /sys/class/power_supply/BAT0 ]]; then
            BAT_DIR="/sys/class/power_supply/BAT0"
        elif [[ -d /sys/class/power_supply/BAT1 ]]; then
            BAT_DIR="/sys/class/power_supply/BAT1"
        else
            BAT_DIR=""
        fi

        if [[ -n "$BAT_DIR" ]]; then
            STATE=$(cat "$BAT_DIR/status" 2>/dev/null)
            PERCENTAGE=$(cat "$BAT_DIR/capacity" 2>/dev/null)

            if [[ "$STATE" == "Discharging" ]]; then
                if [[ "$PERCENTAGE" -le "$BAT_CRIT" ]]; then
                    notify-send -u critical -a "battery_alert" "Battery Critical" "Battery at ${PERCENTAGE}%. System may shut down!"
                    last_bat_notify=$current_time
                elif [[ "$PERCENTAGE" -le "$BAT_LOW" ]]; then
                    notify-send -u critical -a "battery_alert" "Battery Low" "Battery at ${PERCENTAGE}%. Plug in charger!"
                    last_bat_notify=$current_time
                fi
            fi
        fi
    fi

    sleep $LOOP_INTERVAL
done
