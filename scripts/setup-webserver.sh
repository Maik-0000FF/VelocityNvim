#!/bin/bash
# VelocityNvim Web Development Server Setup Script
# Installs all required dependencies for the web server feature

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  VelocityNvim Web Server Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Detect OS
if [ -f /etc/arch-release ]; then
    OS="arch"
elif [ -f /etc/debian_version ]; then
    OS="debian"
elif [ "$(uname)" == "Darwin" ]; then
    OS="macos"
else
    echo "❌ Unsupported OS. This script supports: Arch Linux, Debian/Ubuntu, macOS"
    exit 1
fi

echo "✓ Detected OS: $OS"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Node.js
echo "━━━ Checking Node.js... ━━━"
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo "✓ Node.js already installed: $NODE_VERSION"
else
    echo "⚠ Node.js not found. Installing..."
    case $OS in
        arch)
            sudo pacman -S --noconfirm nodejs npm
            ;;
        debian)
            sudo apt update
            sudo apt install -y nodejs npm
            ;;
        macos)
            brew install node
            ;;
    esac
    echo "✓ Node.js installed: $(node --version)"
fi
echo

# Check npm
echo "━━━ Checking npm... ━━━"
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo "✓ npm already installed: $NPM_VERSION"
else
    echo "❌ npm not found but Node.js is installed. This should not happen."
    exit 1
fi
echo

# Install live-server
echo "━━━ Installing live-server... ━━━"
if command_exists live-server; then
    LS_VERSION=$(live-server --version)
    echo "✓ live-server already installed: $LS_VERSION"
else
    echo "⚠ live-server not found. Installing globally..."
    npm install -g live-server
    echo "✓ live-server installed: $(live-server --version)"
fi
echo

# Check curl
echo "━━━ Checking curl... ━━━"
if command_exists curl; then
    CURL_VERSION=$(curl --version | head -1 | cut -d' ' -f2)
    echo "✓ curl already installed: $CURL_VERSION"
else
    echo "⚠ curl not found. Installing..."
    case $OS in
        arch)
            sudo pacman -S --noconfirm curl
            ;;
        debian)
            sudo apt install -y curl
            ;;
        macos)
            brew install curl
            ;;
    esac
    echo "✓ curl installed"
fi
echo

# Check lsof
echo "━━━ Checking lsof... ━━━"
if command_exists lsof; then
    echo "✓ lsof already installed"
else
    echo "⚠ lsof not found. Installing..."
    case $OS in
        arch)
            sudo pacman -S --noconfirm lsof
            ;;
        debian)
            sudo apt install -y lsof
            ;;
        macos)
            echo "✓ lsof is pre-installed on macOS"
            ;;
    esac
    echo "✓ lsof installed"
fi
echo

# Check Firefox
echo "━━━ Checking Firefox... ━━━"
if command_exists firefox; then
    echo "✓ Firefox already installed"
elif command_exists xdg-open; then
    echo "✓ xdg-open available (fallback browser opener)"
else
    echo "⚠ No browser opener found. Installing Firefox..."
    case $OS in
        arch)
            sudo pacman -S --noconfirm firefox
            ;;
        debian)
            sudo apt install -y firefox
            ;;
        macos)
            brew install --cask firefox
            ;;
    esac
    echo "✓ Firefox installed"
fi
echo

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "✓ Node.js:     $(node --version)"
echo "✓ npm:         $(npm --version)"
echo "✓ live-server: $(live-server --version)"
echo "✓ curl:        $(curl --version | head -1 | cut -d' ' -f2)"
echo "✓ lsof:        Installed"
echo "✓ Browser:     $(command_exists firefox && echo "Firefox" || echo "xdg-open")"
echo

# Test setup
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Testing Installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Create test HTML file
TEST_DIR="/tmp/velocitynvim-webserver-test"
mkdir -p "$TEST_DIR"
cat > "$TEST_DIR/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VelocityNvim Web Server Test</title>
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        h1 {
            font-size: 3em;
            text-align: center;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .success {
            background: rgba(255,255,255,0.1);
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            font-size: 1.2em;
        }
    </style>
</head>
<body>
    <h1>🚀 VelocityNvim Web Server</h1>
    <div class="success">
        ✅ Installation successful!<br><br>
        The web server is ready to use.
    </div>
</body>
</html>
EOF

echo "✓ Test HTML file created: $TEST_DIR/index.html"
echo

# Verify in Neovim
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "1. Open Neovim with VelocityNvim configuration:"
echo "   NVIM_APPNAME=VelocityNvim nvim $TEST_DIR/index.html"
echo
echo "2. Start the web server:"
echo "   Press: <leader>ws"
echo "   OR run: :WebServerStart"
echo
echo "3. Browser should open automatically with the test page"
echo
echo "4. Verify health check:"
echo "   :checkhealth velocitynvim"
echo
echo "5. See documentation:"
echo "   ~/.config/VelocityNvim/docs/WEB_SERVER.md"
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
