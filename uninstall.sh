#!/bin/bash
# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Riceverse Dotfiles Uninstallation Script ===${NC}"
echo -e "${YELLOW}This script will restore your previous configuration and remove Riceverse dotfiles${NC}"
echo

# Find the most recent backup directory
find_latest_backup() {
    BACKUP_BASE_DIR="$HOME/.config"
    LATEST_BACKUP=$(find "$BACKUP_BASE_DIR" -type d -name "dotfiles_backup_*" | sort -r | head -n 1)
    
    if [ -z "$LATEST_BACKUP" ]; then
        echo -e "${RED}Error: No backup directory found.${NC}"
        exit 1
    fi
    
    echo "$LATEST_BACKUP"
}

# Remove current configurations
remove_current_configs() {
    echo -e "${BLUE}Removing current configurations...${NC}"
    
    # List of configs to remove
    configs=("cava" "cmus" "fastfetch" "hypr" "kitty" "mpv" "neofetch" "nvim" "qt6ct" "rofi" "Thunar" "tmux" "waybar" "wofi" "starship.toml")
    
    for config in "${configs[@]}"; do
        if [ -e "$HOME/.config/$config" ]; then
            echo -e "${YELLOW}Removing $config...${NC}"
            rm -rf "$HOME/.config/$config"
        fi
    done
    
    # Remove home files
    home_files=(".bash_profile" ".bashrc" ".clang-format" ".tmux.conf")
    for file in "${home_files[@]}"; do
        if [ -e "$HOME/$file" ]; then
            echo -e "${YELLOW}Removing $file...${NC}"
            rm "$HOME/$file"
        fi
    done
    
    # Remove Catppuccin tmux plugin
    if [ -d "$HOME/.config/tmux/plugins/catppuccin" ]; then
        echo -e "${YELLOW}Removing Catppuccin tmux plugin...${NC}"
        rm -rf "$HOME/.config/tmux/plugins/catppuccin"
    fi
}

# Restore backup configurations
restore_backup_configs() {
    BACKUP_DIR="$1"
    
    echo -e "${BLUE}Restoring configurations from backup...${NC}"
    
    # Restore config files
    if [ -d "$BACKUP_DIR" ]; then
        # List of configs to restore
        configs=("cava" "cmus" "fastfetch" "hypr" "kitty" "mpv" "neofetch" "nvim" "qt6ct" "rofi" "Thunar" "tmux" "waybar" "wofi" "starship.toml")
        
        for config in "${configs[@]}"; do
            if [ -e "$BACKUP_DIR/$config" ]; then
                echo -e "${YELLOW}Restoring $config...${NC}"
                cp -r "$BACKUP_DIR/$config" "$HOME/.config/"
            fi
        done
        
        # Restore home files
        home_files=(".bash_profile" ".bashrc" ".clang-format" ".tmux.conf")
        for file in "${home_files[@]}"; do
            if [ -e "$BACKUP_DIR/$file" ]; then
                echo -e "${YELLOW}Restoring $file...${NC}"
                cp "$BACKUP_DIR/$file" "$HOME/"
            fi
        done
        
        echo -e "${GREEN}Configurations restored successfully.${NC}"
    else
        echo -e "${RED}Backup directory not found. Cannot restore configurations.${NC}"
        exit 1
    fi
}

# Main uninstallation function
uninstall() {
    # Find the latest backup
    BACKUP_DIR=$(find_latest_backup)
    
    # Remove current configurations
    remove_current_configs
    
    # Restore backup configurations
    restore_backup_configs "$BACKUP_DIR"
    
    # Optional: Remove the backup directory
    read -p "Do you want to remove the backup directory? (y/n): " remove_backup
    if [[ "$remove_backup" == "y" || "$remove_backup" == "Y" ]]; then
        rm -rf "$BACKUP_DIR"
        echo -e "${GREEN}Backup directory removed.${NC}"
    fi
    
    echo -e "${GREEN}Uninstallation completed successfully!${NC}"
    echo -e "${YELLOW}You may need to log out and log back in for all changes to take effect.${NC}"
    echo -e "${BLUE}Your previous configuration has been restored.${NC}"
}

# Confirm before uninstalling
read -p "Are you sure you want to uninstall Riceverse dotfiles and restore previous configuration? (y/n): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    uninstall
else
    echo -e "${YELLOW}Uninstallation cancelled.${NC}"
    exit 0
fi
