#!/bin/bash
# VelocityNvim macOS M1 Setup Script
# Automatisches Setup für blink.cmp Rust Performance

echo "󰅹 VelocityNvim macOS M1 Setup"
echo "================================"

# 1. Check if rustup is installed
if ! command -v rustup &> /dev/null; then
    echo "󰅚 rustup nicht gefunden. Installation erforderlich:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# 2. Install nightly if not present
if ! rustup toolchain list | grep -q "nightly"; then
    echo "📦 Installiere Rust nightly toolchain..."
    rustup install nightly
fi

# 3. Set nightly for blink.cmp directory
BLINK_DIR="$HOME/.local/share/VelocityNvim/site/pack/user/start/blink.cmp"
if [ -d "$BLINK_DIR" ]; then
    cd "$BLINK_DIR"
    echo "🔧 Setze nightly toolchain für blink.cmp..."
    rustup override set nightly
    
    # 4. Build with correct PATH
    echo "🔨 Kompiliere blink.cmp Rust binaries..."
    export PATH="$HOME/.cargo/bin:$PATH"
    cargo clean
    cargo build --release
    
    # 5. Verify build
    if [ -f "target/release/libblink_cmp_fuzzy.dylib" ]; then
        echo "󰄴 blink.cmp Rust binary erfolgreich kompiliert!"
        ls -la target/release/libblink_cmp_fuzzy.dylib
    else
        echo "󰅚 Build fehlgeschlagen!"
        exit 1
    fi
else
    echo "󰅚 blink.cmp Plugin-Verzeichnis nicht gefunden!"
    echo "   Starten Sie zuerst: NVIM_APPNAME=VelocityNvim nvim"
    exit 1
fi

# 6. Add PATH to .zshrc if not present
if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.zshrc; then
    echo "📝 Füge Cargo PATH zu ~/.zshrc hinzu..."
    echo '# VelocityNvim Rust PATH (required for blink.cmp)' >> ~/.zshrc
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
    echo "⚠️  WICHTIG: Starten Sie ein neues Terminal oder führen Sie aus:"
    echo "   source ~/.zshrc"
fi

echo ""
echo "🎉 Setup abgeschlossen!"
echo ""
echo "󰄴 Nächste Schritte:"
echo "1. Neues Terminal starten oder: source ~/.zshrc"
echo "2. VelocityNvim testen: NVIM_APPNAME=VelocityNvim nvim"
echo "3. Rust Performance prüfen: :RustPerformanceStatus"
echo ""