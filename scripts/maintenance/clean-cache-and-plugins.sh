#!/bin/bash

# VelocityNvim Clean Installation Script
# Removes ALL VelocityNvim data except configuration itself
# For a completely clean reinstallation with dynamic path detection

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}        VelocityNvim Clean Installation        ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# =============================================================================
# DYNAMIC PATH DETECTION
# =============================================================================

echo -e "${BLUE}=== Path Detection ===${NC}"

# Detect VelocityNvim installation method
VELOCITYNVIM_DATA=""
VELOCITYNVIM_STATE=""  
VELOCITYNVIM_CACHE=""
VELOCITYNVIM_CONFIG=""

# Method 1: Separate NVIM_APPNAME directory
if [ -d ~/.local/share/VelocityNvim ]; then
    VELOCITYNVIM_DATA=~/.local/share/VelocityNvim
    VELOCITYNVIM_STATE=~/.local/state/VelocityNvim
    VELOCITYNVIM_CACHE=~/.cache/VelocityNvim
    VELOCITYNVIM_CONFIG=~/.config/VelocityNvim
    echo -e "${GREEN}✓ Installation Method 1: Separate NVIM_APPNAME directory${NC}"
    
# Method 2: Copied to ~/.config/nvim (check for VelocityNvim-specific files)
elif [ -d ~/.config/nvim ] && [ -f ~/.config/nvim/lua/core/version.lua ]; then
    VELOCITYNVIM_DATA=~/.local/share/nvim
    VELOCITYNVIM_STATE=~/.local/state/nvim
    VELOCITYNVIM_CACHE=~/.cache/nvim
    VELOCITYNVIM_CONFIG=~/.config/nvim
    echo -e "${GREEN}✓ Installation Method 2: Copied to ~/.config/nvim${NC}"
    echo -e "${YELLOW}⚠ Will clean standard nvim directories (may affect other configs)${NC}"
    
else
    echo -e "${RED}✗ No VelocityNvim installation found!${NC}"
    echo ""
    echo "Searched for:"
    echo "  - ~/.local/share/VelocityNvim/"
    echo "  - ~/.config/nvim/lua/core/version.lua (VelocityNvim marker)"
    echo ""
    echo "Please ensure VelocityNvim is installed before running this script."
    exit 1
fi

echo ""
echo -e "${BLUE}Detected paths:${NC}"
echo "  Data:   $VELOCITYNVIM_DATA"
echo "  State:  $VELOCITYNVIM_STATE"
echo "  Cache:  $VELOCITYNVIM_CACHE"
echo "  Config: $VELOCITYNVIM_CONFIG (PROTECTED)"
echo ""

# =============================================================================
# SAFETY CHECK
# =============================================================================

echo -e "${YELLOW}WARNING: This script will delete ALL VelocityNvim data!${NC}"
echo -e "${YELLOW}Configuration will be preserved.${NC}"
echo ""
echo "The following directories will be DELETED:"
echo "  - $VELOCITYNVIM_DATA (Plugins, Site-Packages)"
echo "  - $VELOCITYNVIM_STATE (Undo-History, Shada)"
echo "  - $VELOCITYNVIM_CACHE (Cache, Temp files)"
echo ""

# Require confirmation
read -p "Are you sure? Type 'YES' to continue: " confirm
if [ "$confirm" != "YES" ]; then
    echo -e "${RED}Aborted: Confirmation not received${NC}"
    exit 1
fi

echo -e "${GREEN}Start Cleanup...${NC}"
echo ""

# =============================================================================
# CLEANUP FUNKTIONEN
# =============================================================================

cleanup_directory() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}Deleting: $description${NC}"
        echo "  Path: $dir"
        
        # Show size before deletion
        local size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "?")
        echo "  Size: $size"
        
        # Delete directory
        rm -rf "$dir"
        
        if [ ! -d "$dir" ]; then
            echo -e "${GREEN}  ✓ Successfully deleted${NC}"
            return 0
        else
            echo -e "${RED}  ✗ Failed to delete${NC}"
            return 1
        fi
    else
        echo -e "${BLUE}Skipped: $description (not found)${NC}"
        echo "  Path: $dir"
        return 0
    fi
    echo ""
}

# =============================================================================
# MAIN CLEANUP
# =============================================================================

cleanup_count=0

echo -e "${BLUE}=== Plugin & Data Cleanup ===${NC}"

# 1. Plugin directory (largest space savings)
if cleanup_directory "$VELOCITYNVIM_DATA" "Plugin directory & Site-packages"; then
    ((cleanup_count++))
fi

# 2. State directory (Undo, Shada, Logs)
if cleanup_directory "$VELOCITYNVIM_STATE" "State files (Undo-history, Shada)"; then
    ((cleanup_count++))
fi

# 3. Cache directory (Treesitter, LSP Cache)
if cleanup_directory "$VELOCITYNVIM_CACHE" "Cache files"; then
    ((cleanup_count++))
fi

# =============================================================================
# ADDITIONAL VERSION FILE (if present)
# =============================================================================

echo -e "${BLUE}=== Additional Files ===${NC}"

version_file="$VELOCITYNVIM_DATA/velocitynvim_version"
if [ -f "$version_file" ]; then
    echo -e "${YELLOW}Deleting: Version tracking file${NC}"
    echo "  Path: $version_file"
    rm -f "$version_file"
    echo -e "${GREEN}  ✓ Version file deleted${NC}"
    ((cleanup_count++))
else
    echo -e "${BLUE}Skipped: Version file (not found)${NC}"
fi

echo ""

# =============================================================================
# CONFIGURATION PRESERVATION (PROTECTION)
# =============================================================================

echo -e "${BLUE}=== Configuration (PROTECTED) ===${NC}"
if [ -d "$VELOCITYNVIM_CONFIG" ]; then
    config_size=$(du -sh "$VELOCITYNVIM_CONFIG" 2>/dev/null | cut -f1 || echo "?")
    echo -e "${GREEN}Preserved: VelocityNvim Configuration${NC}"
    echo "  Path: $VELOCITYNVIM_CONFIG"
    echo "  Size: $config_size"
    echo -e "${GREEN}  ✓ Configuration remains unchanged${NC}"
else
    echo -e "${RED}WARNING: Configuration not found!${NC}"
    echo "  Path: $VELOCITYNVIM_CONFIG"
fi

echo ""

# =============================================================================
# SUMMARY
# =============================================================================

echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}              CLEANUP COMPLETED                 ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo "Processed areas: $cleanup_count"
echo ""
echo -e "${GREEN}For complete reinstallation:${NC}"
if [[ "$VELOCITYNVIM_CONFIG" == *"VelocityNvim"* ]]; then
    # Method 1: Separate NVIM_APPNAME
    echo "1. Start Neovim: ${YELLOW}NVIM_APPNAME=VelocityNvim nvim${NC}"
else
    # Method 2: Standard nvim
    echo "1. Start Neovim: ${YELLOW}nvim${NC}"
fi
echo "2. Run: ${YELLOW}:PluginSync${NC}"
echo "3. Close Neovim"
echo "4. IMPORTANT for blink.cmp:"
if [[ "$VELOCITYNVIM_CONFIG" == *"VelocityNvim"* ]]; then
    echo "   ${YELLOW}bash ./scripts/setup/blink-cmp-rust-builder-linux.sh${NC}"
else
    echo "   ${YELLOW}bash ./scripts/setup/blink-cmp-rust-builder-linux.sh${NC}"
fi
echo "5. Restart Neovim"
echo "6. Test: ${YELLOW}:VelocityHealth${NC}"
echo ""
echo -e "${BLUE}All VelocityNvim data has been cleaned!${NC}"
echo -e "${BLUE}Configuration is ready for fresh install.${NC}"

exit 0