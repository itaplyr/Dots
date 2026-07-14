#!/usr/bin/env bash
# ── Dev Mode ────────────────────────────────────────────────
# Watches dotfiles for changes and auto-reloads.
# Usage: ./dev.sh

set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
AGS_DIR="$DOTS_DIR/ags/.config/ags"
BUNDLE="/tmp/ags-bundle.js"
PIDFILE="/tmp/ags-dev.pid"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${CYAN}[dev]${NC} $1"; }
ok()   { echo -e "${GREEN}[ok]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }

kill_ags() {
    if [ -f "$PIDFILE" ]; then
        local pid
        pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            log "Killing AGS (PID: $pid)..."
            kill -- -"$pid" 2>/dev/null || true
            sleep 0.3
            kill -9 -- -"$pid" 2>/dev/null || true
        fi
        rm -f "$PIDFILE"
    fi
    pkill -9 -E "gjs.*ags" 2>/dev/null || true
    sleep 0.5
}

start_ags() {
    log "Bundling AGS..."
    if (cd "$AGS_DIR" && ags bundle app.ts "$BUNDLE" --gtk 4); then
        log "Starting AGS..."
        setsid bash "$BUNDLE" &
        echo $! > "$PIDFILE"
        ok "AGS running (PID: $!)"
    else
        err "AGS bundle failed — fix errors and save again"
        return 1
    fi
}

reload_hyprland() {
    for name in hyprland kitty fish fuzzel; do
        local src="$DOTS_DIR/$name/.config"
        if [ -d "$src" ]; then
            find "$src" -type f | while read -r file; do
                local rel="${file#$src/}"
                local target="$CONFIG_DIR/$rel"
                mkdir -p "$(dirname "$target")"
                cp "$file" "$target"
            done
        fi
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
        */ags/.config/ags/*)
            kill_ags
            start_ags
            ;;
        */hyprland/*|*/kitty/*|*/fish/*|*/fuzzel/*)
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

    kill_ags
    start_ags

    log "Watching for changes..."
    log "Press Ctrl+C to stop"
    echo ""

    while read -r dir event file; do
        [ -z "$file" ] && continue
        on_change "${dir}${file}"
    done < <(inotifywait -m -r \
        -e modify,create,delete,move \
        --include '\.(ts|tsx|lua|conf|ini|fish|sh|css)$' \
        "$DOTS_DIR")
}

cleanup() {
    echo ""
    log "Stopping dev mode..."
    kill_ags 2>/dev/null
    rm -f "$PIDFILE"
    exit 0
}
trap cleanup SIGINT SIGTERM

main "$@"
