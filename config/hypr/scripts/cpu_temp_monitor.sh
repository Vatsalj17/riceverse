#!/bin/bash

MAX_TEMP=70  # Set temperature threshold
NOTIFY_INTERVAL=60  # Time between warnings

while true; do
    # Extract CPU temperature
    CPU_TEMP=$(sensors | awk '/Package id 0:/ {print $4+0}')

    if [ "$CPU_TEMP" -ge "$MAX_TEMP" ]; then
        notify-send -u critical "🔥 CPU Overheating!" "Temperature: ${CPU_TEMP}°C"
        echo "Warning: CPU Temperature is ${CPU_TEMP}°C"
        sleep $NOTIFY_INTERVAL  # Prevent spamming
    fi

    sleep 5  # Check every 5 seconds
done

