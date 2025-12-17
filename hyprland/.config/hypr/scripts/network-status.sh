#!/bin/bash

# --- CONFIGURATION ---
# Icon set for WiFi (using Nerd Font icons)
WIFI_DISCONNECTED="󰤭 "
WIFI_SIGNAL_0="󰤟 "   # 0-20%
WIFI_SIGNAL_1="󰤢 "   # 20-40%
WIFI_SIGNAL_2="󰤥 "   # 40-60%
WIFI_SIGNAL_3="󰤨 "   # 60-80%
WIFI_SIGNAL_4="󰤨 "   # 80-100%
WIFI_NO_INTERNET="󰤩 "  # Connected to WiFi but no internet

# Icon set for Ethernet
ETH_CONNECTED="󰈀 "
ETH_DISCONNECTED="󰈂 "
ETH_NO_INTERNET="󰈄 "

# Icon for VPN
VPN_CONNECTED="󰦝 "  # Lock icon indicating VPN is active

# Icon when completely offline
OFFLINE_ICON="󰤮 "

# --- FUNCTIONS ---

# Check for internet connectivity
check_internet() {
    # Try multiple reliable services with a short timeout
    if ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1 || ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check if VPN is active (checks for tun/tap interfaces)
check_vpn() {
    if ip link show | grep -q "tun\|tap\|wg\|nordlynx\|mullvad"; then
        return 0
    else
        return 1
    fi
}

# Get WiFi signal strength as percentage
get_wifi_strength() {
    local device=$1
    local signal quality percentage

    # Try getting quality from iw
    if command -v iw >/dev/null 2>&1; then
        signal=$(iw dev "$device" link 2>/dev/null | grep 'signal' | awk '{print $2}')
        
        if [ -n "$signal" ]; then
            # Convert dBm to percentage (typical range: -100 dBm to -40 dBm)
            # -40 dBm = 100%, -100 dBm = 0%
            signal=${signal%% *} # Remove unit if present
            percentage=$(( (100 - ((-1 * signal) - 40) * 100 / 60) ))
            
            # Ensure the percentage is within bounds
            if [ "$percentage" -gt 100 ]; then
                percentage=100
            elif [ "$percentage" -lt 0 ]; then
                percentage=0
            fi
            
            echo "$percentage"
            return
        fi
    fi
    
    # Fallback to iwconfig if iw failed
    if command -v iwconfig >/dev/null 2>&1; then
        quality=$(iwconfig "$device" 2>/dev/null | grep -i quality | awk '{print $2}' | cut -d= -f2 | cut -d/ -f1)
        max_quality=$(iwconfig "$device" 2>/dev/null | grep -i quality | awk '{print $2}' | cut -d= -f2 | cut -d/ -f2)
        
        if [ -n "$quality" ] && [ -n "$max_quality" ]; then
            percentage=$((quality * 100 / max_quality))
            echo "$percentage"
            return
        fi
    fi
    
    # If all methods failed, return a default value
    echo "0"
}

# Choose WiFi icon based on signal strength
get_wifi_icon() {
    local strength=$1
    local has_internet=$2
    
    # If connected to WiFi but no internet
    if [ "$has_internet" -eq 0 ]; then
        echo -n "$WIFI_NO_INTERNET"
        return
    fi
    
    # Select icon based on signal strength
    if [ "$strength" -ge 80 ]; then
        echo -n "$WIFI_SIGNAL_4"
    elif [ "$strength" -ge 60 ]; then
        echo -n "$WIFI_SIGNAL_3"
    elif [ "$strength" -ge 40 ]; then
        echo -n "$WIFI_SIGNAL_2"
    elif [ "$strength" -ge 20 ]; then
        echo -n "$WIFI_SIGNAL_1"
    else
        echo -n "$WIFI_SIGNAL_0"
    fi
}

# --- MAIN SCRIPT ---

# Find network devices
WIFI_DEVICE=$(ip link | grep -E '^[0-9]+: wl' | cut -d: -f2 | awk '{print $1}' | head -n 1)
ETH_DEVICE=$(ip link | grep -E '^[0-9]+: (eth|en)' | cut -d: -f2 | awk '{print $1}' | head -n 1)

# Check VPN status
if check_vpn; then
    VPN_STATUS=1
else
    VPN_STATUS=0
fi

# Function to check if device exists and is up
is_device_up() {
    local device=$1
    [ -n "$device" ] && [ "$(cat /sys/class/net/$device/operstate 2>/dev/null)" = "up" ]
}

# Check if we have internet connectivity
if check_internet; then
    HAS_INTERNET=1
else
    HAS_INTERNET=0
fi

# Output result without newlines using echo -n
if is_device_up "$WIFI_DEVICE"; then
    SIGNAL_STRENGTH=$(get_wifi_strength "$WIFI_DEVICE")
    get_wifi_icon "$SIGNAL_STRENGTH" "$HAS_INTERNET"
    
    # Add VPN indicator if active
    if [ "$VPN_STATUS" -eq 1 ]; then
        echo -n " $VPN_CONNECTED"
    fi
elif is_device_up "$ETH_DEVICE"; then
    if [ "$HAS_INTERNET" -eq 1 ]; then
        echo -n "$ETH_CONNECTED"
        if [ "$VPN_STATUS" -eq 1 ]; then
            echo -n " $VPN_CONNECTED"
        fi
    else
        echo -n "$ETH_NO_INTERNET"
    fi
else
    # No connection detected
    echo -n "$OFFLINE_ICON"
fi

echo "~"
