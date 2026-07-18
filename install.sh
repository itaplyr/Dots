#!/usr/bin/env bash
# ── Dots Installer ─────────────────────────────────────────
# Copies dotfiles to their corresponding system locations.
# Only installs configs listed in dots.conf.
# Usage: ./install.sh [hyprland|kitty|fish|all]

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$BASE_DIR/Dots"
BACKUP_DIR="$HOME/.dots-backup/$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config"
CONF="$BASE_DIR/dots.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ── Read config mapping from dots.conf ──────────────────────
read_configs() {
    local in_section=false
    while IFS= read -r line; do
        line="${line%%#*}"
        line="$(echo "$line" | xargs)"
        [[ "$line" == "[configs]" ]] && in_section=true && continue
        [[ "$line" == "["* ]] && in_section=false && continue
        if $in_section && [[ -n "$line" ]]; then
            local key="${line%%=*}"
            local val="${line#*=}"
            echo "$(echo "$key" | xargs) $(echo "$val" | xargs)"
        fi
    done < "$CONF"
}

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
    local config_dir="$2"
    local src="$DOTS_DIR/$name/.config/$config_dir"
    local dst="$CONFIG_DIR/$config_dir"

    if [ ! -d "$src" ]; then
        warn "Package '$name' config not found at $src"
        return
    fi

    info "Installing $name → $config_dir..."

    backup_config "$dst"
    mkdir -p "$dst"
    cp -r "$src/"* "$dst/" 2>/dev/null || true
    info "  Copied: $config_dir/"
}

# ── List packages from dots.conf ───────────────────────────
list_packages() {
    [ -f "$CONF" ] || error "Config not found: $CONF"

    echo "Configs in dots.conf:"
    while IFS=' ' read -r name config_dir; do
        echo "  - $name → $config_dir"
    done < <(read_configs)
}

# ── Main ───────────────────────────────────────────────────
main() {
    local target="${1:-all}"

    echo "╔══════════════════════════════════════╗"
    echo "║       Dots Installer                 ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    [ -f "$CONF" ] || error "Config not found: $CONF"

    if [ "$target" = "--list" ] || [ "$target" = "-l" ]; then
        list_packages
        exit 0
    fi

    if [ "$target" = "all" ]; then
        while IFS=' ' read -r name config_dir; do
            install_package "$name" "$config_dir"
        done < <(read_configs)
    else
        # Find config_dir for the given package name
        local config_dir
        config_dir=$(grep "^${target} *=" "$CONF" | head -1 | sed 's/^[^=]*= *//' | tr -d ' ')
        if [ -z "$config_dir" ]; then
            error "Package '$target' not found in dots.conf"
        fi
        install_package "$target" "$config_dir"
    fi

    echo ""
    info "Installation complete!"
    if [ -d "$BACKUP_DIR" ]; then
        warn "Backups saved to: $BACKUP_DIR"
    fi

    if command -v hyprctl >/dev/null 2>&1; then
        info "Reloading Hyprland..."
        hyprctl reload
    fi
}

main "$@"
