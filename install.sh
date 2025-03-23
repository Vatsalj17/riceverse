#!/bin/bash

REPO_DIR="$HOME/hyprspace"
CONFIG_DIR="$HOME/.config"
TMUX_PLUGIN_DIR="$CONFIG_DIR/tmux/plugins"

echo "🚀 Setting up Hyprspace dotfiles..."

# Ensure ~/.config exists
mkdir -p "$CONFIG_DIR"

# Symlink function
link_file() {
    local src="$REPO_DIR/$1"
    local dest="$HOME/$2"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "⚠️  $dest already exists. Backing up to $dest.bak"
        mv "$dest" "$dest.bak"
    fi

    ln -s "$src" "$dest"
    echo "✅ Linked $dest → $src"
}

# Clone the repo if not already cloned
if [ ! -d "$REPO_DIR" ]; then
    echo "📂 Cloning hyprspace repository..."
    git clone --depth=1 https://github.com/vatsalj17/hyprspace.git "$REPO_DIR"
else
    echo "🔄 Updating existing repository..."
    cd "$REPO_DIR" && git pull
fi

# Link home dotfiles
link_file "home/.bashrc" ".bashrc"
link_file "home/.bash_profile" ".bash_profile"
link_file "home/.clang-format" ".clang-format"
link_file "home/.tmux.conf" ".tmux.conf"

# Link config files
for dir in cava cmus fastfetch hypr kitty mpv neofetch nvim qt6ct rofi Thunar tmux waybar wofi; do
    if [ -d "$CONFIG_DIR/$dir" ]; then
        echo "⚠️  $CONFIG_DIR/$dir already exists. Backing up..."
        mv "$CONFIG_DIR/$dir" "$CONFIG_DIR/${dir}.bak"
    fi
    ln -s "$REPO_DIR/config/$dir" "$CONFIG_DIR/$dir"
    echo "✅ Linked $CONFIG_DIR/$dir"
done

# Ensure Tmux plugins directory exists
mkdir -p "$TMUX_PLUGIN_DIR"

# Clone catppuccin/tmux if not already present
if [ ! -d "$TMUX_PLUGIN_DIR/catppuccin" ]; then
    echo "🌙 Installing Catppuccin Tmux theme..."
    git clone --depth=1 https://github.com/catppuccin/tmux.git "$TMUX_PLUGIN_DIR/catppuccin"
    echo "✅ Catppuccin Tmux theme installed!"
else
    echo "🔄 Updating Catppuccin Tmux theme..."
    cd "$TMUX_PLUGIN_DIR/catppuccin" && git pull
fi

echo "🎉 Installation complete! Please restart your session for all changes to take effect."
