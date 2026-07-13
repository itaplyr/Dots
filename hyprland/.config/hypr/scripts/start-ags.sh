#!/usr/bin/env bash
# Bundle and start AGS v3 shell

AGS_DIR="$HOME/.config/ags"
BUNDLE="/tmp/ags-bundle.js"

cd "$AGS_DIR" || exit 1

# Kill existing AGS instance
pkill -f "ags-bundle\|gjs.*ags" 2>/dev/null
sleep 0.5

# Bundle TypeScript to JS
ags bundle app.ts "$BUNDLE" --gtk 4 || {
    echo "AGS bundle failed"
    exit 1
}

# Run the bundled app
exec bash "$BUNDLE"
