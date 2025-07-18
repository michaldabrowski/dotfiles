#!/usr/bin/env bash

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create symlinks with validation
create_symlinks() {
    log_info "Creating symlinks..."

    local git_files=("git/.gitconfig" "git/.gitignore_global")

    for file in "${git_files[@]}"; do
        local source="$DOTFILES_DIR/$file"
        local target="$HOME/$(basename "$file")"

        if [[ ! -f "$source" ]]; then
            log_error "Source file not found: $source"
            return 1
        fi

        if [[ -L "$target" ]]; then
            log_warn "Symlink already exists: $target"
        elif [[ -f "$target" ]]; then
            log_warn "Backing up existing file: $target -> $target.backup"
            mv "$target" "$target.backup"
        fi

        ln -sfv "$source" "$target"
        log_info "Created symlink: $target -> $source"
    done
}

# Install Homebrew
install_homebrew() {
    if command_exists brew; then
        log_info "Homebrew already installed, skipping..."
        return 0
    fi

    log_info "Installing Homebrew..."
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_error "Failed to install Homebrew"
        return 1
    fi

    # Add Homebrew to PATH for the rest of the script
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# Install Homebrew packages
install_brew_packages() {
    local brewfile="$DOTFILES_DIR/brew/Brewfile"

    if [[ ! -f "$brewfile" ]]; then
        log_warn "Brewfile not found at $brewfile, skipping package installation"
        return 0
    fi

    log_info "Installing Homebrew packages..."
    if ! brew bundle --file="$brewfile"; then
        log_error "Failed to install some Homebrew packages"
        return 1
    fi
}

export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Main execution
main() {
    log_info "Starting dotfiles installation..."
    log_info "Dotfiles directory: $DOTFILES_DIR"

    create_symlinks || { log_error "Failed to create symlinks"; exit 1; }
    install_homebrew || { log_error "Failed to install Homebrew"; exit 1; }
    install_brew_packages || { log_error "Failed to install Homebrew packages"; exit 1; }

    log_info "Dotfiles installation completed successfully!"
}

# Run main function
main "$@"
