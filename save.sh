#!/usr/bin/env bash
# ── Save Configs ────────────────────────────────────────────
# Copies configs from ~/.config/ into the project for backup.
# Only saves configs listed in dots.conf.
# Usage: ./save.sh [hyprland|kitty|fish|all|--select|--list]

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

# ── Read config mapping from dots.conf ──────────────────────
# Output: "name config_dir" per line
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

# ── Save a package ──────────────────────────────────────────
save_package() {
    local name="$1"
    local config_dir="$2"
    local src="$CONFIG_DIR/$config_dir"
    local dst="$DOTS_DIR/$name/.config/$config_dir"

    if [ ! -d "$src" ]; then
        warn "System config not found: $src"
        return
    fi

    mkdir -p "$dst"
    cp -r "$src/"* "$dst/" 2>/dev/null || true
    info "Saved: $name → $config_dir"
}

# ── Interactive selection ───────────────────────────────────
select_packages() {
    local names=()
    local dirs=()
    while read -r name config_dir; do
        [ -d "$CONFIG_DIR/$config_dir" ] || continue
        names+=("$name")
        dirs+=("$config_dir")
    done < <(read_configs)

    if [ ${#names[@]} -eq 0 ]; then
        warn "No matching system configs found"
        exit 1
    fi

    local toggled=()
    for i in "${!names[@]}"; do toggled[i]=1; done

    while true; do
        clear
        echo "Select configs to save:"
        echo ""
        for i in "${!names[@]}"; do
            if [ "${toggled[i]}" -eq 1 ]; then
                echo -e "  ${GREEN}✓${NC} ${names[i]} → ${dirs[i]}"
            else
                echo -e "  ${RED}✗${NC} ${names[i]} → ${dirs[i]}"
            fi
        done
        echo ""
        echo "  [1-${#names[@]}] toggle | [a]ll | [n]one | [q]uit | [enter] save"

        read -r -p "> " choice

        case "$choice" in
            q|Q) exit 0 ;;
            a|A) for i in "${!toggled[@]}"; do toggled[i]=1; done ;;
            n|N) for i in "${!toggled[@]}"; do toggled[i]=0; done ;;
            "")
                for i in "${!names[@]}"; do
                    [ "${toggled[i]}" -eq 1 ] && save_package "${names[i]}" "${dirs[i]}"
                done
                return
                ;;
            *)
                local idx=$((choice - 1))
                if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#names[@]}" ]; then
                    toggled[idx]=$(( 1 - toggled[idx] ))
                fi
                ;;
        esac
    done
}

# ── Main ───────────────────────────────────────────────────
main() {
    local target="${1:-all}"

    echo "╔══════════════════════════════════════╗"
    echo "║       Dots Save Configs              ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    [ -f "$CONF" ] || error "Config not found: $CONF"

    case "$target" in
        --list|-l)
            echo "Configs in dots.conf:"
            while read -r name config_dir; do
                echo "  - $name → $config_dir"
            done < <(read_configs)
            ;;
        --select|-s)
            select_packages
            ;;
        all)
            while read -r name config_dir; do
                save_package "$name" "$config_dir"
            done < <(read_configs)
            ;;
        *)
            local config_dir
            config_dir=$(grep "^${target} *=" "$CONF" | head -1 | sed 's/^[^=]*= *//' | tr -d ' ')
            [ -z "$config_dir" ] && error "Package '$target' not found in dots.conf"
            save_package "$target" "$config_dir"
            ;;
    esac

    echo ""
    info "Done!"
}

main "$@"
