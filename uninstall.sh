#!/usr/bin/env bash
# ── Dots Uninstaller ───────────────────────────────────────
# Removes dotfiles from system config directories.
# Usage: ./uninstall.sh [hyprland|kitty|fish|--packages|all]

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$BASE_DIR/Dots"
CONFIG_DIR="$HOME/.config"
CONF="$BASE_DIR/dots.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ── Read value from dots.conf ───────────────────────────────
read_conf() {
    local key="$1"
    local value
    value=$(grep "^${key} *=" "$CONF" 2>/dev/null | head -1 | sed 's/^[^=]*= *//' | tr -d ' ')
    echo "$value"
}

# ── Uninstall a dotfile package ────────────────────────────
uninstall_package() {
    local name="$1"
    local config_dir
    config_dir=$(read_conf "$name")

    if [ -z "$config_dir" ]; then
        warn "Package '$name' not found in dots.conf"
        return
    fi

    local src="$DOTS_DIR/$name/.config/$config_dir"

    if [ ! -d "$src" ]; then
        warn "Package '$name' config not found at $src"
        return
    fi

    info "Uninstalling $name ($config_dir)..."

    local target="$CONFIG_DIR/$config_dir"
    if [ -d "$target" ]; then
        rm -rf "$target"
        info "  Removed: $config_dir/"
    fi
}

# ── Uninstall system packages from dots.conf ───────────────
uninstall_packages() {
    [ -f "$CONF" ] || error "Config not found: $CONF"

    local SUDO=""
    [ "$EUID" -ne 0 ] && SUDO="sudo"

    local pkgs=()
    local official_str aur_str
    official_str=$(read_conf "official")
    aur_str=$(read_conf "aur")

    [ -n "$official_str" ] && IFS=',' read -ra pkgs <<< "$official_str"
    [ -n "$aur_str" ] && { IFS=',' read -ra aur_pkgs <<< "$aur_str"; pkgs+=("${aur_pkgs[@]}"); }

    if [ ${#pkgs[@]} -eq 0 ]; then
        warn "No packages found in dots.conf"
        return
    fi

    info "Uninstalling system packages..."
    $SUDO pacman -Rns --noconfirm "${pkgs[@]}" 2>/dev/null || warn "Some packages could not be removed"
    info "System packages uninstalled"
}

# ── List packages from dots.conf ───────────────────────────
list_packages() {
    [ -f "$CONF" ] || error "Config not found: $CONF"

    echo "Configs (from dots.conf):"
    while IFS= read -r line; do
        local name config_dir
        name=$(echo "$line" | cut -d'=' -f1 | tr -d ' ')
        config_dir=$(echo "$line" | cut -d'=' -f2 | tr -d ' ')
        echo "  - $name → $config_dir"
    done < <(sed -n '/^\[configs\]/,/^\[/p' "$CONF" | grep '=')

    echo ""
    echo "Packages (from dots.conf):"
    local official_str aur_str
    official_str=$(read_conf "official")
    aur_str=$(read_conf "aur")
    [ -n "$official_str" ] && echo "  official: $official_str"
    [ -n "$aur_str" ] && echo "  aur: $aur_str"
}

# ── Main ───────────────────────────────────────────────────
main() {
    local target="${1:-all}"

    echo "╔══════════════════════════════════════╗"
    echo "║       Dots Uninstaller               ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    if [ "$target" = "--list" ] || [ "$target" = "-l" ]; then
        list_packages
        exit 0
    fi

    if [ "$target" = "--packages" ]; then
        uninstall_packages
        echo ""
        info "Uninstallation complete!"
        exit 0
    fi

    if [ "$target" = "all" ]; then
        # Read config names from dots.conf
        while IFS= read -r line; do
            local name
            name=$(echo "$line" | cut -d'=' -f1 | tr -d ' ')
            uninstall_package "$name"
        done < <(sed -n '/^\[configs\]/,/^\[/p' "$CONF" | grep '=')
        uninstall_packages
    else
        uninstall_package "$target"
    fi

    echo ""
    info "Uninstallation complete!"
}

main "$@"
