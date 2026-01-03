#!/bin/bash

# 1. Get the current workspace ID
WS=$(hyprctl activeworkspace -j | jq '.id')

# 2. Get all window addresses in this workspace, excluding floating windows 
# (Grouping floating windows often causes layout glitches)
WINS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $WS and .floating == false) | .address")

# 3. Convert the list to an array
readarray -t ADDR_ARRAY <<< "$WINS"

if [ ${#ADDR_ARRAY[@]} -lt 2 ]; then
    echo "Not enough windows to group."
    exit 0
fi

# 4. Focus the first window and ensure it is a group
hyprctl dispatch focuswindow address:${ADDR_ARRAY[0]}
hyprctl dispatch togglegroup 
sleep 0.1

# 5. Iterate through the rest and merge them
for (( i=1; i<${#ADDR_ARRAY[@]}; i++ )); do
    # We focus the window we want to move
    hyprctl dispatch focuswindow address:${ADDR_ARRAY[$i]}
    sleep 0.05
    # We use 'u' (up), 'd' (down), 'l' (left), or 'r' (right). 
    # To be safe, we try to merge into the first window's group.
    # 'movewindoworgroup' is more reliable than 'moveintogroup'
    hyprctl dispatch movewindoworgroup l
done
