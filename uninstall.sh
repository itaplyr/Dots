#!/usr/bin/env bash
# ── Dots Uninstaller ───────────────────────────────────────
# Removes dotfiles from system config directories.
# Usage: ./uninstall.sh [hyprland|kitty|fish|all]

set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# ── Colors ─────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ── Uninstall a dotfile package ────────────────────────────
uninstall_package() {
    local name="$1"
    local src="$DOTS_DIR/$name/.config"

    if [ ! -d "$src" ]; then
        error "Package '$name' not found at $src"
    fi

    info "Uninstalling $name..."

    # Remove files that exist in our dotfiles
    find "$src" -type f | while read -r file; do
        local rel="${file#$src/}"
        local target="$CONFIG_DIR/$rel"

        if [ -f "$target" ]; then
            rm "$target"
            info "  Removed: $rel"
        fi
    done

    # Remove empty directories left behind
    find "$src" -type d -mindepth 1 | sort -r | while read -r dir; do
        local rel="${dir#$src/}"
        local target="$CONFIG_DIR/$rel"

        if [ -d "$target" ] && [ -z "$(ls -A "$target")" ]; then
            rmdir "$target"
            info "  Removed empty dir: $rel"
        fi
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
    echo "║       Dots Uninstaller v1.0          ║"
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
                uninstall_package "$name"
            fi
        done
    else
        uninstall_package "$target"
    fi

    echo ""
    info "Uninstallation complete!"
}

main "$@"
