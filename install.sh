#!/bin/bash
# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== RiceVerse Dotfiles Installation Script ===${NC}"
echo -e "${YELLOW}This script will install the RiceVerse dotfiles configuration${NC}"
echo

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed. Please install it before continuing.${NC}"
        exit 1
    fi
}

# Check for required commands
check_command git

# Create necessary directories
create_directories() {
    echo -e "${BLUE}Creating necessary directories...${NC}"
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.config/tmux/plugins"
    echo -e "${GREEN}Directories created successfully.${NC}"
}

# Backup existing configs
backup_configs() {
    echo -e "${BLUE}Backing up existing configurations...${NC}"
    BACKUP_DIR="$HOME/.config/dotfiles_backup_$(date +%Y%m%d%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # List of configs to backup
    configs=("cava" "cmus" "fastfetch" "hypr" "kitty" "mpv" "neofetch" "nvim" "qt6ct" "rofi" "Thunar" "tmux" "waybar" "wofi" "starship.toml")
    
    for config in "${configs[@]}"; do
        if [ -e "$HOME/.config/$config" ]; then
            echo -e "${YELLOW}Backing up $config...${NC}"
            cp -r "$HOME/.config/$config" "$BACKUP_DIR/"
        fi
    done
    
    # Backup home files
    home_files=(".bash_profile" ".bashrc" ".clang-format" ".tmux.conf")
    for file in "${home_files[@]}"; do
        if [ -e "$HOME/$file" ]; then
            echo -e "${YELLOW}Backing up $file...${NC}"
            cp "$HOME/$file" "$BACKUP_DIR/"
        fi
    done
    
    echo -e "${GREEN}Backup completed to $BACKUP_DIR${NC}"
}

# Copy configuration files
copy_configs() {
    echo -e "${BLUE}Copying configuration files...${NC}"
    
    # Determine the current directory (assuming the script is run from the repository root)
    REPO_DIR="$(pwd)"
    
    # Copy config files
    cp -r "$REPO_DIR/config/"* "$HOME/.config/"
    
    # Copy home files
    cp "$REPO_DIR/home/.bash_profile" "$HOME/"
    cp "$REPO_DIR/home/.bashrc" "$HOME/"
    cp "$REPO_DIR/home/.clang-format" "$HOME/"
    cp "$REPO_DIR/home/.tmux.conf" "$HOME/"
    
    echo -e "${GREEN}Configuration files copied successfully.${NC}"
}

# Clone catppuccin/tmux repository
clone_catppuccin() {
    echo -e "${BLUE}Cloning catppuccin/tmux repository...${NC}"
    
    # Remove existing directory if it exists
    if [ -d "$HOME/.config/tmux/plugins/catppuccin" ]; then
        echo -e "${YELLOW}Catppuccin tmux directory already exists. Removing...${NC}"
        rm -rf "$HOME/.config/tmux/plugins/catppuccin"
    fi
    
    # Clone the repository
    git clone https://github.com/catppuccin/tmux.git "$HOME/.config/tmux/plugins/catppuccin"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to clone catppuccin/tmux. Please check your internet connection and try again.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Catppuccin tmux cloned successfully.${NC}"
}

# Main installation function
install() {
    create_directories
    backup_configs
    copy_configs
    clone_catppuccin
    
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${YELLOW}You may need to log out and log back in for all changes to take effect.${NC}"
    echo -e "${BLUE}Enjoy your new Riceverse configuration!${NC}"
}

# Run the installation
install
