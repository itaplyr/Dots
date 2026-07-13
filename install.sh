#!/usr/bin/env bash
# ── Dots Installer ─────────────────────────────────────────
# Copies dotfiles to their corresponding system locations.
# Usage: ./install.sh [hyprland|kitty|fish|all]

set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dots-backup/$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config"

# ── Colors ─────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ── Backup existing config ─────────────────────────────────
backup_config() {
    local target="$1"
    if [ -e "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        local rel_path="${target#$HOME/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$rel_path")"
        cp -r "$target" "$BACKUP_DIR/$rel_path"
        warn "Backed up existing: $target"
    fi
}

# ── Install a dotfile package ──────────────────────────────
install_package() {
    local name="$1"
    local src="$DOTS_DIR/$name/.config"
    local dst="$CONFIG_DIR"

    if [ ! -d "$src" ]; then
        error "Package '$name' not found at $src"
    fi

    info "Installing $name..."

    # Find all config files and copy them
    find "$src" -type f | while read -r file; do
        local rel="${file#$src/}"
        local target="$dst/$rel"

        backup_config "$target"
        mkdir -p "$(dirname "$target")"
        cp "$file" "$target"
        info "  Copied: $rel"
    done
}

# ── List available packages ────────────────────────────────
list_packages() {
    echo "Available packages:"
    for dir in "$DOTS_DIR"/*/; do
        local name="$(basename "$dir")"
        if [ -d "$dir/.config" ]; then
            echo "  - $name"
        fi
    done
}

# ── Main ───────────────────────────────────────────────────
main() {
    local target="${1:-all}"

    echo "╔══════════════════════════════════════╗"
    echo "║       Dots Installer v1.0            ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    if [ "$target" = "--list" ] || [ "$target" = "-l" ]; then
        list_packages
        exit 0
    fi

    if [ "$target" = "all" ]; then
        for dir in "$DOTS_DIR"/*/; do
            local name="$(basename "$dir")"
            if [ -d "$dir/.config" ]; then
                install_package "$name"
            fi
        done
    else
        install_package "$target"
    fi

    echo ""
    info "Installation complete!"
    if [ -d "$BACKUP_DIR" ]; then
        warn "Backups saved to: $BACKUP_DIR"
    fi
}

main "$@"
