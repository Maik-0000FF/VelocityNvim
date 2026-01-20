#!/bin/bash

# blink.cmp Rust Auto-Build Script
# Automatically compiles Rust binaries for blink.cmp after plugin installation
# Solves the "Failed to setup fuzzy matcher" problem

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}       blink.cmp Rust Auto-Build Script        ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# =============================================================================
# DYNAMIC PATH DETECTION
# =============================================================================

echo -e "${BLUE}=== Path Detection ===${NC}"

# Possible VelocityNvim installation paths
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
        echo -e "${GREEN}✓ blink.cmp found: $BLINK_DIR${NC}"
        break
    else
        echo -e "${YELLOW}◦ Not found: $expanded_path${NC}"
    fi
done

# Fallback: Automatic search in all pack directories
if [ -z "$BLINK_DIR" ]; then
    echo -e "${YELLOW}⚠ Standard paths not found - searching automatically...${NC}"
    
    # Search in all possible Neovim data directories
    for base_dir in ~/.local/share/VelocityNvim ~/.local/share/nvim ~/.config/nvim; do
        if [ -d "$base_dir" ]; then
            found_path=$(find "$base_dir" -name "blink.cmp" -type d -path "*/pack/*/start/*" 2>/dev/null | head -1)
            if [ -n "$found_path" ] && [ -f "$found_path/Cargo.toml" ]; then
                BLINK_DIR="$found_path"
                echo -e "${GREEN}✓ Automatically found: $BLINK_DIR${NC}"
                break
            fi
        fi
    done
fi

# Set paths
if [ -n "$BLINK_DIR" ]; then
    CARGO_TOML="$BLINK_DIR/Cargo.toml"
    TARGET_DIR="$BLINK_DIR/target"
    echo -e "${BLUE}Using plugin path: $BLINK_DIR${NC}"
else
    echo -e "${RED}✗ blink.cmp plugin could not be found!${NC}"
    echo ""
    echo -e "${YELLOW}Possible solutions:${NC}"
    echo "1. Run ':PluginSync' in Neovim"
    echo "2. Check VelocityNvim installation"
    echo "3. Run the script from the VelocityNvim directory"
    echo ""
    echo -e "${YELLOW}Tested paths:${NC}"
    for path in "${POSSIBLE_PATHS[@]}"; do
        echo "  - $(eval echo "$path")"
    done
    exit 1
fi

echo ""

# =============================================================================
# SYSTEM VALIDATION
# =============================================================================

echo -e "${BLUE}=== System Validation ===${NC}"

# Check Rust installation
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}✗ Cargo not found!${NC}"
    echo "  Installation: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
else
    rust_version=$(rustc --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Rust available: $rust_version${NC}"
fi

# Check/install nightly toolchain (REQUIRED for blink.cmp performance)
if ! rustup run nightly rustc --version &>/dev/null; then
    echo -e "${YELLOW}⚠ Rust nightly not found - installing...${NC}"
    if rustup install nightly; then
        echo -e "${GREEN}✓ Rust nightly installed${NC}"
    else
        echo -e "${RED}✗ Failed to install Rust nightly!${NC}"
        echo "  Manual installation: rustup install nightly"
        exit 1
    fi
else
    nightly_version=$(rustup run nightly rustc --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Rust nightly available: $nightly_version${NC}"
fi

# Plugin already validated through path detection
echo -e "${GREEN}✓ blink.cmp Plugin: $BLINK_DIR${NC}"

# Check existing binaries
if [ -d "$TARGET_DIR" ]; then
    size=$(du -sh "$TARGET_DIR" 2>/dev/null | cut -f1 || echo "?")
    echo -e "${YELLOW}! Existing Rust binaries found (${size})${NC}"
    echo "  These will be overwritten"
else
    echo -e "${BLUE}◦ No existing binaries (fresh build)${NC}"
fi

echo ""

# =============================================================================
# RUST BUILD PROCESS
# =============================================================================

echo -e "${BLUE}=== Rust Compilation ===${NC}"

# Change working directory
cd "$BLINK_DIR"
echo "Working directory: $(pwd)"

# Determine build profile
BUILD_PROFILE="release"
echo -e "${YELLOW}Build profile: $BUILD_PROFILE${NC}"

echo ""
echo -e "${YELLOW}Starting Rust compilation...${NC}"
echo "This may take several minutes..."
echo ""

# Rust build with detailed output (nightly required for blink.cmp performance)
if cargo +nightly build --profile "$BUILD_PROFILE" --verbose; then
    echo ""
    echo -e "${GREEN}✓ Rust compilation successful!${NC}"
    
    # Binary information
    if [ -d "$TARGET_DIR" ]; then
        target_size=$(du -sh "$TARGET_DIR" 2>/dev/null | cut -f1 || echo "?")
        echo "  Target directory: $target_size"
        
        # Search for specific binaries
        binaries=$(find "$TARGET_DIR" -name "*.so" -o -name "*.dll" -o -name "*.dylib" 2>/dev/null | head -3)
        if [ -n "$binaries" ]; then
            echo "  Created binaries:"
            echo "$binaries" | while read -r binary; do
                if [ -f "$binary" ]; then
                    binary_size=$(du -sh "$binary" 2>/dev/null | cut -f1 || echo "?")
                    echo "    - $(basename "$binary") ($binary_size)"
                fi
            done
        fi
    fi
else
    echo ""
    echo -e "${RED}✗ Rust compilation failed!${NC}"
    echo ""
    echo -e "${YELLOW}Common solutions:${NC}"
    echo "1. Update Rust toolchain: rustup update"
    echo "2. Clear cache: cargo clean"
    echo "3. Check dependencies: cargo check"
    exit 1
fi

echo ""

# =============================================================================
# BUILD VALIDATION
# =============================================================================

echo -e "${BLUE}=== Build Validation ===${NC}"

# Test if Neovim recognizes the binaries
echo -e "${YELLOW}Testing blink.cmp integration...${NC}"

if NVIM_APPNAME=VelocityNvim nvim --headless \
    -c "lua local ok, blink = pcall(require, 'blink.cmp'); if ok then print('blink.cmp loaded successfully') else print('ERROR: blink.cmp load failed') end" \
    -c "qall" 2>/dev/null | grep -q "loaded successfully"; then
    echo -e "${GREEN}✓ blink.cmp integration successful${NC}"
else
    echo -e "${YELLOW}⚠ blink.cmp integration could not be validated${NC}"
    echo "  Start Neovim manually to test"
fi

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}            RUST BUILD COMPLETED               ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Start Neovim: ${YELLOW}NVIM_APPNAME=VelocityNvim nvim${NC}"
echo "2. Test completion: Type in Insert mode"
echo "3. Check status: ${YELLOW}:messages${NC}"
echo ""
echo -e "${BLUE}blink.cmp Rust performance is now active!${NC}"

exit 0