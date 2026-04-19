#!/bin/bash

MAX_TEMP=80  # Set temperature threshold
NOTIFY_INTERVAL=120  # Time between warnings

while true; do
    # Extract CPU temperature
    CPU_TEMP=$(sensors | awk '/Package id 0:/ {print $4+0}')

    if [ "$CPU_TEMP" -ge "$MAX_TEMP" ]; then
        # Get the process using the most CPU (excluding kernel threads)
        TOP_PROCESS=$(ps aux --no-headers | awk '$11 !~ /^\[.*\]$/ {print $11, $3}' | sort -k2 -nr | head -1)
        PROCESS_NAME=$(echo "$TOP_PROCESS" | awk '{print $1}' | sed 's/.*\///')
        PROCESS_CPU=$(echo "$TOP_PROCESS" | awk '{printf "%.1f", $2}')
        
        # Send notification with process info
        notify-send -u critical "🔥 CPU Overheating!" "Temperature: ${CPU_TEMP}°C | Top Process: ${PROCESS_NAME} (${PROCESS_CPU}%)"
        echo "Warning: CPU Temperature is ${CPU_TEMP}°C | Top Process: ${PROCESS_NAME} using ${PROCESS_CPU}%"
        
        sleep $NOTIFY_INTERVAL  # Prevent spamming
    fi

    sleep 15  # Check every 15 seconds
done
