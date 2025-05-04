#!/bin/bash

# Define thresholds
LOW_BATTERY=15
CRITICAL_BATTERY=5
FULL_BATTERY=100
CHECK_INTERVAL=60  # Check every 60 seconds
PAUSE_DURATION=300 # Pause for 5 minutes (300 seconds) after dismissal

while true; do
    BATTERY_STATUS=$(upower -i $(upower -e | grep BAT))
    PERCENTAGE=$(echo "$BATTERY_STATUS" | grep "percentage" | awk '{print $2}' | tr -d '%')
    STATE=$(echo "$BATTERY_STATUS" | grep "state" | awk '{print $2}')

    if [[ "$STATE" == "discharging" && "$PERCENTAGE" -le "$LOW_BATTERY" ]]; then
        notify-send -u critical -a "battery_alert" "Battery Low" "Battery at ${PERCENTAGE}%. Plug in charger!"
    fi

    if [[ "$STATE" == "discharging" && "$PERCENTAGE" -le "$CRITICAL_BATTERY" ]]; then
        notify-send -u critical -a "battery_alert" "Battery Critical" "Battery at ${PERCENTAGE}%. System may shut down!"
    fi

    if [[ "$STATE" == "fully-charged" || ("$STATE" == "charging" && "$PERCENTAGE" -ge "$FULL_BATTERY") ]]; then
        notify-send -u normal -a "battery_alert" "Battery Full" "Battery at ${PERCENTAGE}%. Unplug charger!"
    fi

    # Listen for notification dismissals related to battery alerts
    if swaync-client --wait | grep -q "battery_alert"; then
        #echo "Battery notification dismissed. Pausing alerts for $PAUSE_DURATION seconds."
        sleep $PAUSE_DURATION
    fi

    sleep $CHECK_INTERVAL
done

