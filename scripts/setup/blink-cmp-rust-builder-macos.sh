#!/bin/bash
# VelocityNvim macOS M1 Setup Script
# Automatic setup for blink.cmp Rust performance

echo "󰅹 VelocityNvim macOS M1 Setup"
echo "================================"

# =============================================================================
# DYNAMIC PATH DETECTION
# =============================================================================

echo "🔍 Path Detection"
echo "------------------"

# Possible VelocityNvim installation paths on macOS
POSSIBLE_PATHS=(
    # Installation Method 1: Separate NVIM_APPNAME directory
    ~/.local/share/VelocityNvim/site/pack/user/start/blink.cmp
    
    # Installation Method 2: Copied to ~/.config/nvim
    ~/.local/share/nvim/site/pack/user/start/blink.cmp
    
    # Fallback: Current config directory based
    ~/.config/nvim/plugins/blink.cmp
    ~/.config/VelocityNvim/../nvim/site/pack/user/start/blink.cmp
)

# Search for blink.cmp plugin
BLINK_DIR=""
for path in "${POSSIBLE_PATHS[@]}"; do
    expanded_path=$(eval echo "$path")
    if [ -f "$expanded_path/Cargo.toml" ]; then
        BLINK_DIR="$expanded_path"
        echo "✓ blink.cmp found: $BLINK_DIR"
        break
    else
        echo "◦ Not found: $expanded_path"
    fi
done

# Fallback: Automatic search in all pack directories
if [ -z "$BLINK_DIR" ]; then
    echo "⚠ Standard paths not found - searching automatically..."
    
    # Search in all possible Neovim data directories
    for base_dir in ~/.local/share/VelocityNvim ~/.local/share/nvim ~/.config/nvim; do
        if [ -d "$base_dir" ]; then
            found_path=$(find "$base_dir" -name "blink.cmp" -type d -path "*/pack/*/start/*" 2>/dev/null | head -1)
            if [ -n "$found_path" ] && [ -f "$found_path/Cargo.toml" ]; then
                BLINK_DIR="$found_path"
                echo "✓ Automatically found: $BLINK_DIR"
                break
            fi
        fi
    done
fi

# Validate path
if [ -z "$BLINK_DIR" ]; then
    echo "󰅚 blink.cmp plugin could not be found!"
    echo ""
    echo "Possible solutions:"
    echo "1. Run ':PluginSync' in Neovim"
    echo "2. Check VelocityNvim installation"  
    echo "3. Start VelocityNvim first: NVIM_APPNAME=VelocityNvim nvim"
    echo ""
    echo "Tested paths:"
    for path in "${POSSIBLE_PATHS[@]}"; do
        echo "  - $(eval echo "$path")"
    done
    exit 1
fi

echo "🎯 Using plugin path: $BLINK_DIR"
echo ""

# =============================================================================
# SYSTEM VALIDATION
# =============================================================================

echo "🔧 System Validation"
echo "--------------------"

# 1. Check if rustup is installed
if ! command -v rustup &> /dev/null; then
    echo "󰅚 rustup not found. Installation required:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
else
    rust_version=$(rustc --version 2>/dev/null || echo "unknown")
    echo "✓ Rust available: $rust_version"
fi

# 2. Install nightly if not present
if ! rustup toolchain list | grep -q "nightly"; then
    echo "📦 Installing Rust nightly toolchain..."
    rustup install nightly
else
    echo "✓ Rust nightly toolchain available"
fi

echo ""

# =============================================================================
# BUILD PROCESS
# =============================================================================

echo "🔨 Build Process"
echo "----------------"
# Change to plugin directory (already validated above)
cd "$BLINK_DIR"
echo "📍 Working directory: $(pwd)"

# Set nightly toolchain for blink.cmp
echo "🔧 Setting nightly toolchain for blink.cmp..."
rustup override set nightly

# Build with correct PATH
echo "🔨 Compiling blink.cmp Rust binaries..."
export PATH="$HOME/.cargo/bin:$PATH"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
cargo clean

# Start compilation
echo "⚙️  Starting compilation (this may take several minutes)..."
if cargo build --release --verbose; then
    echo ""
    # Verify build success
    if [ -f "target/release/libblink_cmp_fuzzy.dylib" ]; then
        echo "󰄴 blink.cmp Rust binary successfully compiled!"
        echo "📦 Binary details:"
        ls -la target/release/libblink_cmp_fuzzy.dylib
        
        # Show target directory size
        target_size=$(du -sh target 2>/dev/null | cut -f1 || echo "?")
        echo "📊 Total target directory: $target_size"
    else
        echo "󰅚 Build completed but binary not found!"
        echo "Expected: target/release/libblink_cmp_fuzzy.dylib"
        exit 1
    fi
else
    echo ""
    echo "󰅚 Build failed!"
    echo ""
    echo "Common solutions:"
    echo "1. Update Rust toolchain: rustup update"
    echo "2. Check Xcode tools: xcode-select --install"
    echo "3. Verify nightly: rustup toolchain list"
    exit 1
fi

echo ""

# =============================================================================
# ENVIRONMENT SETUP
# =============================================================================

echo "🔧 Environment Setup"
echo "--------------------"

# Add PATH to shell profile if not present
SHELL_PROFILE=""
if [ -f ~/.zshrc ]; then
    SHELL_PROFILE="~/.zshrc"
elif [ -f ~/.bash_profile ]; then
    SHELL_PROFILE="~/.bash_profile"
elif [ -f ~/.profile ]; then
    SHELL_PROFILE="~/.profile"
fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' "$SHELL_PROFILE"; then
        echo "📝 Adding Cargo PATH to $SHELL_PROFILE..."
        echo '# VelocityNvim Rust PATH (required for blink.cmp)' >> "$SHELL_PROFILE"
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$SHELL_PROFILE"
        echo "⚠️  IMPORTANT: Start a new terminal or run:"
        echo "   source $SHELL_PROFILE"
    else
        echo "✓ Cargo PATH already configured in $SHELL_PROFILE"
    fi
else
    echo "⚠️  Could not find shell profile. Please manually add to your shell:"
    echo "   export PATH=\"\$HOME/.cargo/bin:\$PATH\""
fi

echo ""

# =============================================================================
# COMPLETION
# =============================================================================

echo "================================================="
echo "🎉 SETUP COMPLETED SUCCESSFULLY!"
echo "================================================="
echo ""
echo "📋 Summary:"
echo "✓ Plugin found: $BLINK_DIR"
echo "✓ Rust nightly toolchain configured"
echo "✓ blink.cmp Rust binary compiled"
echo "✓ Environment PATH configured"
echo ""
echo "🚀 Next steps:"
echo "1. Start new terminal or run: source $SHELL_PROFILE"
echo "2. Test VelocityNvim: NVIM_APPNAME=VelocityNvim nvim"
echo "3. Check Rust performance: :RustPerformanceStatus"
echo "4. Verify completion works in Insert mode"
echo ""
echo "🎯 blink.cmp Rust performance is now active!"
echo ""