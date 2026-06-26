#!/bin/bash

if find $HOME/.config/nvim/lua/plugins/trash/which-key.lua 2> /dev/null; then
    mv $HOME/.config/nvim/lua/plugins/trash/which-key.lua $HOME/.config/nvim/lua/plugins/
elif find $HOME/.config/nvim/lua/plugins/which-key.lua 2> /dev/null; then
    mv $HOME/.config/nvim/lua/plugins/which-key.lua $HOME/.config/nvim/lua/plugins/trash/
fi
