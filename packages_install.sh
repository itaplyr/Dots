#!/usr/bin/env bash
# ── Package Installer ───────────────────────────────────────
# Installs required system packages from dots.conf.
# Usage: ./packages_install.sh

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

# ── Main ───────────────────────────────────────────────────
main() {
    echo "╔══════════════════════════════════════╗"
    echo "║       Package Installer              ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    [ -f "$CONF" ] || error "Config not found: $CONF"

    local SUDO=""
    [ "$EUID" -ne 0 ] && SUDO="sudo"

    # Official packages
    local official_str
    official_str=$(read_conf "official")
    if [ -n "$official_str" ]; then
        IFS=',' read -ra official_pkgs <<< "$official_str"
        info "Installing official packages..."
        $SUDO pacman -S --needed --noconfirm "${official_pkgs[@]}" || error "Failed to install official packages"
        info "Official packages installed"
    fi

    # AUR packages
    local aur_str
    aur_str=$(read_conf "aur")
    if [ -n "$aur_str" ]; then
        IFS=',' read -ra aur_pkgs <<< "$aur_str"

        local aur_helper=""
        if command -v yay >/dev/null 2>&1; then
            aur_helper="yay"
        elif command -v paru >/dev/null 2>&1; then
            aur_helper="paru"
        else
            error "No AUR helper found. Install yay or paru first."
        fi

        info "Installing AUR packages with $aur_helper..."
        $aur_helper -S --needed --noconfirm "${aur_pkgs[@]}" || error "Failed to install AUR packages"
        info "AUR packages installed"
    fi

    echo ""
    info "All packages installed!"
}

main "$@"
