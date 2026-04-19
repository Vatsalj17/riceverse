#!/bin/bash

LOW_BATTERY=15
CRITICAL_BATTERY=5
CHECK_INTERVAL=60
PAUSE_DURATION=300

while true; do
    BATTERY_STATUS=$(upower -i "$(upower -e | grep BAT)")
    PERCENTAGE=$(echo "$BATTERY_STATUS" | grep "percentage" | awk '{print $2}' | tr -d '%')
    STATE=$(echo "$BATTERY_STATUS" | grep "state" | awk '{print $2}')

    if [[ "$STATE" == "discharging" ]]; then
        if [[ "$PERCENTAGE" -le "$CRITICAL_BATTERY" ]]; then
            notify-send -u critical -a "battery_alert" "Battery Critical" "Battery at ${PERCENTAGE}%. System may shut down!"
            sleep $PAUSE_DURATION
        elif [[ "$PERCENTAGE" -le "$LOW_BATTERY" ]]; then
            notify-send -u critical -a "battery_alert" "Battery Low" "Battery at ${PERCENTAGE}%. Plug in charger!"
            sleep $PAUSE_DURATION
        fi
    fi

    sleep $CHECK_INTERVAL
done
