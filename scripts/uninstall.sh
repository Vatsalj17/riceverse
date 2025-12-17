#!/usr/bin/env bash

# 1. Configuration
# ------------------------------------------------------------------------------
DOTFILES_DIR="$HOME/.dotfiles"
LOG_FILE="$DOTFILES_DIR/uninstall.log"

# Colors
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Valid Stow Modules (Must match directory names)
VALID_MODULES=("shell" "terminal" "nvim" "hyprland" "tools" "gui-tools" "suckless" "assets")

# 2. Helpers
# ------------------------------------------------------------------------------
log_info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[OK]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }

# 3. Unstow Logic
# ------------------------------------------------------------------------------
unstow_modules() {
    local targets=("$@")
    local modules_to_remove=()

    # If no args, select ALL
    if [ ${#targets[@]} -eq 0 ]; then
        log_warn "No arguments provided. Unstowing EVERYTHING."
        read -p "Are you sure? This will strip your config. (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
        modules_to_remove=("${VALID_MODULES[@]}")
    else
        # Validate arguments
        for target in "${targets[@]}"; do
            # Check if target exists in our valid list
            if [[ " ${VALID_MODULES[*]} " =~ " ${target} " ]]; then
                modules_to_remove+=("$target")
            else
                log_error "Unknown module: $target"
                exit 1
            fi
        done
    fi

    cd "$DOTFILES_DIR" || exit

    for mod in "${modules_to_remove[@]}"; do
        
        # Special Case: Assets (Wallpapers)
        if [[ "$mod" == "assets" ]]; then
            log_info "Unlinking Assets (Wallpapers)..."
            # We target ~/Pictures just like in install.sh
            stow -D -v -d "$DOTFILES_DIR" -t "$HOME/Pictures" assets
            continue
        fi

        # Special Case: Suckless (Binaries)
        if [[ "$mod" == "suckless" ]]; then
            log_info "Unlinking Suckless configs..."
            stow -D -v -t "$HOME" suckless
            
            # Optional: Ask to remove binaries
            read -p "Do you want to uninstall compiled binaries (dwm/st/dmenu)? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                clean_suckless_binaries
            fi
            continue
        fi

        # Standard Modules
        if [ -d "$mod" ]; then
            log_info "Unstowing $mod..."
            stow -D -v -t "$HOME" "$mod"
        else
            log_warn "Directory '$mod' not found. Skipping."
        fi
    done
}

# 4. Suckless Cleanup (Make Uninstall)
# ------------------------------------------------------------------------------
clean_suckless_binaries() {
    log_info "Removing compiled Suckless binaries..."
    TOOLS=("dwm" "st" "dmenu")
    
    # We must look in the stow directory because symlinks might already be gone
    for tool in "${TOOLS[@]}"; do
        SRC_DIR="$DOTFILES_DIR/suckless/.config/$tool"
        if [ -d "$SRC_DIR" ]; then
            log_info "Running 'make uninstall' for $tool..."
            cd "$SRC_DIR" && sudo make uninstall
        fi
    done
}

# 5. Dead Link Cleanup
# ------------------------------------------------------------------------------
cleanup_dead_links() {
    log_info "Scanning $HOME for broken symlinks..."
    # Find symlinks in Home that point to nowhere (safeguard: maxdepth 2 to not scan entire drive)
    find "$HOME" -maxdepth 2 -xtype l -print
    
    read -p "Delete these broken links? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find "$HOME" -maxdepth 2 -xtype l -delete
        log_success "Broken links removed."
    fi
}

# 6. Main
# ------------------------------------------------------------------------------
main() {
    unstow_modules "$@"
    
    # Optional: Run cleanup
    cleanup_dead_links
    
    log_success "Uninstallation complete."
    log_info "Note: Packages (pacman/yay) were NOT removed to prevent dependency breakage."
}

main "$@"
