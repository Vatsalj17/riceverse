#!/usr/bin/env bash

# 1. Configuration & Maps
# ------------------------------------------------------------------------------
DOTFILES_DIR="$HOME/.dotfiles"
LOG_FILE="$DOTFILES_DIR/install.log"

# Colors
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

# ------------------------------------------------------------------------------
# THE DEPENDENCY MAP
# Key = Directory Name in Stow
# Value = List of Arch Linux packages to install
# ------------------------------------------------------------------------------
declare -A DEPS

# Core stuff (always installed if selected)
DEPS["core"]="stow git base-devel"

# Module-specific dependencies
DEPS["shell"]="zsh starship bat btop fastfetch lsd neofetch"
DEPS["terminal"]="kitty tmux"
DEPS["nvim"]="neovim ripgrep fd npm python-pynvim"
DEPS["hyprland"]="hyprland hyprpaper hyprlock hypridle waybar wofi rofi-wayland swaync nwg-look"
DEPS["tools"]="mpv mpd ncmpcpp cava zathura zathura-pdf-mupdf spicetify-cli clang gdb"
DEPS["gui-tools"]="thunar kvantum gtk3 gtk4 libreoffice-fresh"
DEPS["suckless"]="libx11 libxft libxinerama"
DEPS["assets"]="" # No dependencies, just pictures

# 2. Helpers
# ------------------------------------------------------------------------------
log_info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[OK]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }

# 3. Logic
# ------------------------------------------------------------------------------

resolve_deps_and_stow() {
    local targets=("$@")
    local install_list=()
    local stow_list=()

    # If no arguments, select EVERYTHING
    if [ ${#targets[@]} -eq 0 ]; then
        log_info "No arguments provided. Installing EVERYTHING."
        targets=("${!DEPS[@]}") # All keys from the map
    fi

    # Always add core dependencies
    install_list+=(${DEPS["core"]})

    # Build the installation and stow lists
    for target in "${targets[@]}"; do
        if [[ -v "DEPS[$target]" ]]; then
            log_info "Queueing module: $target"
            
            # Add dependencies to the list
            if [ ! -z "${DEPS[$target]}" ]; then
                install_list+=(${DEPS[$target]})
            fi
            
            # Add to stow list (except 'core' which isn't a directory)
            if [[ "$target" != "core" ]]; then
                stow_list+=("$target")
            fi
        else
            log_error "Unknown module: $target"
            echo "Available modules: ${!DEPS[@]}"
            exit 1
        fi
    done

    # 1. Install Dependencies (Deduplicated)
    # We sort and uniquely filter the list to avoid reinstalling the same thing twice
    unique_pkgs=($(echo "${install_list[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    
    log_info "Installing Dependencies: ${unique_pkgs[*]}"
    
    if command -v yay &> /dev/null; then
        yay -S --needed --noconfirm "${unique_pkgs[@]}"
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --needed --noconfirm "${unique_pkgs[@]}"
    else
        log_error "No package manager found (pacman/yay)."
        exit 1
    fi

    # 2. Stow Directories
    cd "$DOTFILES_DIR" || exit
    
    for dir in "${stow_list[@]}"; do
        # Special case for Wallpapers (root -> Pictures)
        if [[ "$dir" == "assets" ]]; then
            log_info "Stowing Assets to ~/Pictures..."
            mkdir -p "$HOME/Pictures/Wallpapers"
            stow --adopt -v -d "$DOTFILES_DIR" -t "$HOME/Pictures" assets
            continue
        fi

        # Standard Directories
        if [ -d "$dir" ]; then
            log_info "Stowing $dir..."
            stow --adopt -v -t "$HOME" "$dir"
        else
            log_error "Directory '$dir' not found in repo. Skipping stow."
        fi
    done

    # 3. Post-Install (Suckless compilation logic)
    # Only run if 'suckless' was in the target list
    if [[ " ${targets[*]} " =~ " suckless " ]]; then
        compile_suckless
    fi
    
    # Git Restore to clean up --adopt mess
    git restore .
}

compile_suckless() {
    log_info "Compiling Suckless tools..."
    TOOLS=("dwm" "st" "dmenu")
    for tool in "${TOOLS[@]}"; do
        if [ -d "$HOME/.config/$tool" ]; then
            log_info "Building $tool..."
            cd "$HOME/.config/$tool" && sudo make clean install
        fi
    done
}

# 4. Main
# ------------------------------------------------------------------------------
main() {
    # Check if stow is installed explicitly first (bootstrap problem)
    if ! command -v stow &> /dev/null; then
        echo "Installing Stow..."
        sudo pacman -S --noconfirm stow
    fi

    # Pass all command line arguments to the resolver
    resolve_deps_and_stow "$@"

    log_success "Operation Complete."
}

main "$@"
