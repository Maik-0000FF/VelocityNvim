#!/bin/bash
# Quick verification script for web server dependencies

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  VelocityNvim Web Server Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        VERSION=$("$@" 2>&1 | head -1)
        echo "✓ $1: $VERSION"
        return 0
    else
        echo "✗ $1: NOT FOUND"
        return 1
    fi
}

MISSING=0

# Check Node.js
check_cmd node --version || MISSING=$((MISSING + 1))

# Check npm
check_cmd npm --version || MISSING=$((MISSING + 1))

# Check live-server
check_cmd live-server --version || MISSING=$((MISSING + 1))

# Check curl
if command -v curl >/dev/null 2>&1; then
    VERSION=$(curl --version 2>&1 | head -1 | cut -d' ' -f2)
    echo "✓ curl: $VERSION"
else
    echo "✗ curl: NOT FOUND"
    MISSING=$((MISSING + 1))
fi

# Check lsof
if command -v lsof >/dev/null 2>&1; then
    echo "✓ lsof: Installed"
else
    echo "✗ lsof: NOT FOUND"
    MISSING=$((MISSING + 1))
fi

# Check browser (OS-specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS always has 'open' command
    echo "✓ Browser: macOS 'open' (built-in)"
elif command -v firefox >/dev/null 2>&1; then
    echo "✓ Browser: Firefox"
elif command -v xdg-open >/dev/null 2>&1; then
    echo "✓ Browser: xdg-open (fallback)"
else
    echo "✗ Browser: NOT FOUND"
    MISSING=$((MISSING + 1))
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $MISSING -eq 0 ]; then
    echo "✅ All dependencies installed!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "Usage in Neovim:"
    echo "  1. Open HTML file: nvim index.html"
    echo "  2. Press: <leader>ws"
    echo "  3. Browser opens with auto-reload"
    exit 0
else
    echo "⚠️  $MISSING dependencies missing!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "Run setup script to install:"
    echo "  bash ~/.config/VelocityNvim/scripts/setup-webserver.sh"
    exit 1
fi
