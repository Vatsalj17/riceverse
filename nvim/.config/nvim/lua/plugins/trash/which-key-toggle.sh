#!/bin/bash

if find /home/Vatsal/.config/nvim/lua/plugins/trash/which-key.lua 2> /dev/null; then
    mv /home/Vatsal/.config/nvim/lua/plugins/trash/which-key.lua /home/Vatsal/.config/nvim/lua/plugins/
elif find /home/Vatsal/.config/nvim/lua/plugins/which-key.lua 2> /dev/null; then
    mv /home/Vatsal/.config/nvim/lua/plugins/which-key.lua /home/Vatsal/.config/nvim/lua/plugins/trash/
fi
