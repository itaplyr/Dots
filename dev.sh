#!/usr/bin/env bash
# ── Dev Mode ────────────────────────────────────────────────
# Watches dotfiles for changes and auto-reloads.
# Usage: ./dev.sh

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$BASE_DIR/Dots"
CONFIG_DIR="$HOME/.config"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${CYAN}[dev]${NC} $1"; }
ok()   { echo -e "${GREEN}[ok]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }

reload_config() {
    local name="$1"
    local src="$DOTS_DIR/$name/.config"
    if [ -d "$src" ]; then
        find "$src" -type f | while read -r file; do
            local rel="${file#$src/}"
            local target="$CONFIG_DIR/$rel"
            mkdir -p "$(dirname "$target")"
            cp "$file" "$target"
        done
        log "Copied $name configs"
    fi
}

reload_hyprland() {
    for name in hyprland kitty fish fuzzel waybar mako; do
        reload_config "$name"
    done
    log "Reloading Hyprland..."
    hyprctl reload 2>/dev/null && ok "Hyprland reloaded" || warn "hyprctl reload failed"
}

on_change() {
    local file="$1"
    local rel="${file#$DOTS_DIR/}"
    echo ""
    log "Changed: $rel"

    case "$file" in
        */Dots/hyprland/*|*/Dots/kitty/*|*/Dots/fish/*|*/Dots/fuzzel/*|*/Dots/waybar/*|*/Dots/mako/*)
            reload_hyprland
            ;;
    esac
}

main() {
    if ! command -v inotifywait >/dev/null 2>&1; then
        err "inotify-tools not installed. Run: sudo pacman -S inotify-tools"
        exit 1
    fi

    echo "╔══════════════════════════════════════╗"
    echo "║       Dots Dev Mode                  ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    log "Watching for changes..."
    log "Press Ctrl+C to stop"
    echo ""

    while read -r dir event file; do
        [ -z "$file" ] && continue
        on_change "${dir}${file}"
    done < <(inotifywait -m -r \
        -e modify,create,delete,move \
        --include '\.(lua|conf|ini|fish|sh|css|json)$' \
        "$DOTS_DIR")
}

cleanup() {
    echo ""
    log "Stopping dev mode..."
    exit 0
}
trap cleanup SIGINT SIGTERM

main "$@"
