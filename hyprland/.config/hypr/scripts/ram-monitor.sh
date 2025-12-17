#!/bin/bash

MAX_RAM=75         # Set RAM usage threshold (percentage)
NOTIFY_INTERVAL=60 # Time between warnings

while true; do
	# Get RAM usage percentage
	RAM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')

	if [ "$RAM_USAGE" -ge "$MAX_RAM" ]; then
		# Get the process using the most RAM (excluding kernel threads)
		TOP_PROCESS=$(ps aux --no-headers | awk '$11 !~ /^\[.*\]$/ {print $11, $4}' | sort -k2 -nr | head -1)
		PROCESS_NAME=$(echo "$TOP_PROCESS" | awk '{print $1}' | sed 's/.*\///')
		PROCESS_RAM=$(echo "$TOP_PROCESS" | awk '{printf "%.1f", $2}')

		# Send notification
		notify-send -u critical "⚠️ High RAM Usage!" "RAM: ${RAM_USAGE}% | Top Process: ${PROCESS_NAME} (${PROCESS_RAM}%)"
		echo "Warning: RAM Usage is ${RAM_USAGE}% | Top Process: ${PROCESS_NAME} using ${PROCESS_RAM}%"

		sleep $NOTIFY_INTERVAL # Prevent spamming
	fi

	sleep 5 # Check every 5 seconds
done
