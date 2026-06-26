#!/bin/bash

DIR="$HOME/.config/nvim/lua/plugins"

if ls $DIR | grep -q lsp-config; then
    mv $DIR/completions.lua $DIR/trash/
    mv $DIR/lsp-config.lua $DIR/trash/
else 
    mv $DIR/trash/completions.lua $DIR/
    mv $DIR/trash/lsp-config.lua $DIR/
fi
