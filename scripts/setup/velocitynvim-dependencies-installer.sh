#!/bin/bash

# VelocityNvim Dependencies Installer for Arch Linux
# Interactive installation script for all VelocityNvim dependencies
# Allows selective installation of tool categories

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Installation counters
INSTALLED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0

# Banner
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}    VelocityNvim Dependencies Installer        ${NC}"
echo -e "${BLUE}           For Arch Linux Systems              ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# =============================================================================
# SYSTEM VALIDATION
# =============================================================================

echo -e "${BLUE}=== System Validation ===${NC}"

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}✗ This script is designed for Arch Linux systems${NC}"
    echo "  pacman package manager not found"
    exit 1
fi

# Check if user has sudo privileges
if ! sudo -n true 2>/dev/null; then
    echo -e "${YELLOW}⚠ Sudo access required for package installation${NC}"
    echo "  You may be prompted for your password"
fi

echo -e "${GREEN}✓ Arch Linux detected${NC}"
echo -e "${GREEN}✓ System validation passed${NC}"
echo ""

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

install_package() {
    local package="$1"
    local description="$2"
    local installer="${3:-pacman}"
    
    case "$installer" in
        "pacman")
            if pacman -Qi "$package" &> /dev/null; then
                echo -e "  ${GREEN}✓ $package${NC} (already installed)"
                ((SKIPPED_COUNT++))
                return 0
            fi
            
            echo -e "  ${YELLOW}Installing $package...${NC}"
            if sudo pacman -S --noconfirm "$package"; then
                echo -e "  ${GREEN}✓ $package${NC} installed successfully"
                ((INSTALLED_COUNT++))
            else
                echo -e "  ${RED}✗ $package${NC} installation failed"
                ((FAILED_COUNT++))
                return 1
            fi
            ;;
            
        "npm")
            if npm list -g "$package" &> /dev/null; then
                echo -e "  ${GREEN}✓ $package${NC} (already installed via npm)"
                ((SKIPPED_COUNT++))
                return 0
            fi
            
            echo -e "  ${YELLOW}Installing $package via npm...${NC}"
            if npm install -g "$package"; then
                echo -e "  ${GREEN}✓ $package${NC} installed successfully"
                ((INSTALLED_COUNT++))
            else
                echo -e "  ${RED}✗ $package${NC} npm installation failed"
                ((FAILED_COUNT++))
                return 1
            fi
            ;;
            
        "cargo")
            if cargo install --list | grep -q "^$package "; then
                echo -e "  ${GREEN}✓ $package${NC} (already installed via cargo)"
                ((SKIPPED_COUNT++))
                return 0
            fi
            
            echo -e "  ${YELLOW}Installing $package via cargo...${NC}"
            if cargo install "$package"; then
                echo -e "  ${GREEN}✓ $package${NC} installed successfully"
                ((INSTALLED_COUNT++))
            else
                echo -e "  ${RED}✗ $package${NC} cargo installation failed"
                ((FAILED_COUNT++))
                return 1
            fi
            ;;
            
        "pip")
            if pip show "$package" &> /dev/null; then
                echo -e "  ${GREEN}✓ $package${NC} (already installed via pip)"
                ((SKIPPED_COUNT++))
                return 0
            fi
            
            echo -e "  ${YELLOW}Installing $package via pip...${NC}"
            if pip install --user "$package"; then
                echo -e "  ${GREEN}✓ $package${NC} installed successfully"
                ((INSTALLED_COUNT++))
            else
                echo -e "  ${RED}✗ $package${NC} pip installation failed"
                ((FAILED_COUNT++))
                return 1
            fi
            ;;
    esac
}

ask_category() {
    local category="$1"
    local description="$2"
    
    echo ""
    echo -e "${CYAN}=== $category ===${NC}"
    echo -e "${YELLOW}$description${NC}"
    echo ""
    
    while true; do
        read -p "Install $category? [Y/n/s] (Yes/No/Show details): " choice
        case "$choice" in
            [Yy]*|"") return 0 ;;  # Install
            [Nn]*) return 1 ;;     # Skip
            [Ss]*) return 2 ;;     # Show details first
            *) echo "Please answer Y, n, or s" ;;
        esac
    done
}

show_details() {
    local category="$1"
    shift
    local packages=("$@")
    
    echo -e "${BLUE}Packages in $category:${NC}"
    for pkg in "${packages[@]}"; do
        echo "  - $pkg"
    done
    echo ""
}

# =============================================================================
# INSTALLATION CATEGORIES
# =============================================================================

# Core System Tools
install_core_tools() {
    echo -e "${PURPLE}Installing Core System Tools...${NC}"
    
    install_package "git" "Version control system"
    install_package "curl" "HTTP client tool"
    install_package "wget" "File download utility"
    install_package "unzip" "Archive extraction tool"
    install_package "base-devel" "Development tools (make, gcc, etc.)"
}

# Clipboard Tools
install_clipboard() {
    echo -e "${PURPLE}Installing Clipboard Tools...${NC}"
    
    install_package "wl-clipboard" "Modern Wayland clipboard manager"
    install_package "xclip" "X11 clipboard interface"
    install_package "xsel" "X11 selection tool (fallback)"
}

# Rust Performance Tools
install_rust_tools() {
    echo -e "${PURPLE}Installing Rust Performance Tools...${NC}"
    
    install_package "rust" "Rust programming language"
    install_package "fd" "Fast file finder (rust-based)"
    install_package "ripgrep" "Fast text search (rust-based)"
    install_package "bat" "Enhanced cat with syntax highlighting"
    install_package "git-delta" "Enhanced git diff viewer"
    install_package "fzf" "Fuzzy finder"
    install_package "eza" "Enhanced ls command"
}

# Formatters (Hybrid System: Ultra-fast where possible)
install_formatters() {
    echo -e "${PURPLE}Installing Code Formatters (Hybrid Performance System)...${NC}"
    
    # System packages
    install_package "stylua" "Lua formatter"
    install_package "shfmt" "Shell script formatter"
    
    # Hybrid JavaScript/TypeScript formatting system
    install_package "biome" "Ultra-fast JS/TS/JSON/CSS formatter (Rust-based)"
    install_package "prettier" "Fallback formatter for Vue/Svelte/Markdown/YAML/HTML"
    
    # Python formatter (Ruff does everything: formatting + import sorting + linting)
    if command -v pip &> /dev/null; then
        install_package "ruff" "Fast Python linter, formatter, and import organizer" "pip"
    else
        echo -e "  ${YELLOW}⚠ pip not found, skipping Python formatter${NC}"
        echo "  Install with: sudo pacman -S python-pip"
    fi
    
    # Rust-based formatters  
    if command -v cargo &> /dev/null; then
        install_package "taplo-cli" "TOML formatter" "cargo"
    fi
    
    echo -e "  ${CYAN}ℹ Hybrid System: Biome for JS/TS/JSON/CSS (~20x faster), Prettier for others${NC}"
}

# LSP Servers (Performance Optimized)
install_lsp_servers() {
    echo -e "${PURPLE}Installing LSP Servers (Performance Optimized)...${NC}"
    
    # System packages
    install_package "lua-language-server" "Lua LSP server"
    install_package "rust-analyzer" "Rust LSP server"
    install_package "gopls" "Go LSP server"
    install_package "typescript-language-server" "TypeScript/JavaScript LSP server"
    
    # npm-based servers (performance optimized)
    if command -v npm &> /dev/null; then
        install_package "pyright" "Fast Python LSP server (TypeScript-based)" "npm"
        install_package "@volar/vue-language-server" "Vue.js LSP server" "npm"
        install_package "svelte-language-server" "Svelte LSP server" "npm"
        install_package "yaml-language-server" "YAML LSP server" "npm"
    else
        echo -e "  ${YELLOW}⚠ npm not found, install with: sudo pacman -S npm${NC}"
        echo "  Fallback: sudo pacman -S python-lsp-server (slower alternative)"
        install_package "python-lsp-server" "Python LSP server (fallback)"
    fi
    
    echo -e "  ${CYAN}ℹ Performance: Pyright (faster) preferred over python-lsp-server${NC}"
}

# LaTeX Suite (Optimized for Size and Performance)
install_latex() {
    echo -e "${PURPLE}Installing LaTeX Suite (Size Optimized)...${NC}"
    
    # Ask for LaTeX installation size preference
    echo ""
    echo -e "${YELLOW}LaTeX Installation Options:${NC}"
    echo "1. ${GREEN}Minimal${NC} (~500MB) - texlive-basic + essentials (recommended)"
    echo "2. ${BLUE}Complete${NC} (~4GB) - texlive-meta (full distribution)"
    echo ""
    
    while true; do
        read -p "Choose LaTeX installation [1/2]: " latex_choice
        case "$latex_choice" in
            1|"")
                echo -e "  ${GREEN}Installing minimal LaTeX distribution...${NC}"
                install_package "texlive-basic" "Basic TeX Live distribution"
                install_package "texlive-latex-recommended" "Recommended LaTeX packages"
                install_package "texlive-latex-extra" "Extra LaTeX packages"
                break
                ;;
            2)
                echo -e "  ${BLUE}Installing complete LaTeX distribution...${NC}"
                install_package "texlive-meta" "Complete TeX Live distribution"
                break
                ;;
            *)
                echo "Please choose 1 or 2"
                ;;
        esac
    done
    
    # Common packages for both options
    install_package "tectonic" "Modern LaTeX engine (Rust-based, fast)"
    install_package "zathura" "Lightweight document viewer"
    install_package "zathura-pdf-poppler" "PDF support for Zathura"
    install_package "zathura-pdf-mupdf" "Alternative PDF renderer"
    install_package "poppler" "PDF rendering library"
    install_package "biber" "Bibliography processor"
    
    echo -e "  ${CYAN}ℹ Tectonic provides modern, fast LaTeX compilation${NC}"
}

# Development Tools
install_dev_tools() {
    echo -e "${PURPLE}Installing Development Tools...${NC}"
    
    install_package "nodejs" "JavaScript runtime"
    install_package "npm" "Node.js package manager"  
    install_package "python" "Python programming language"
    install_package "python-pip" "Python package installer"
    install_package "go" "Go programming language"
    install_package "gcc" "GNU Compiler Collection"
    install_package "make" "Build automation tool"
    install_package "cmake" "Cross-platform build system"
    install_package "lldb" "LLVM Debugger"
    install_package "gdb" "GNU Debugger"
}

# =============================================================================
# INTERACTIVE MENU
# =============================================================================

echo -e "${BLUE}=== Installation Categories ===${NC}"
echo ""
echo "VelocityNvim can benefit from various external tools."
echo "You can choose which categories to install:"
echo ""

# Category definitions
declare -A categories
categories["Core Tools"]="git, curl, wget, unzip, base-devel"
categories["Clipboard"]="wl-clipboard, xclip, xsel (essential for copy/paste)"
categories["Rust Tools"]="fd, ripgrep, bat, delta, fzf, eza (performance boost)"  
categories["Formatters"]="biome, prettier, stylua, ruff, shfmt, taplo (hybrid performance system)"
categories["LSP Servers"]="lua-language-server, rust-analyzer, pyright, gopls (performance optimized)"
categories["LaTeX Suite"]="texlive, zathura, tectonic (document editing)"
categories["Dev Tools"]="nodejs, python, go, gcc, cmake (programming languages)"

# Show available categories
echo -e "${CYAN}Available Categories:${NC}"
for category in "${!categories[@]}"; do
    echo -e "  ${YELLOW}$category${NC}: ${categories[$category]}"
done
echo ""

# Category installation prompts
install_categories=()

# Core Tools (recommended)
choice=$(ask_category "Core Tools" "Essential system tools (highly recommended)")
case $choice in
    0) install_categories+=("core") ;;
    1) echo "Skipping Core Tools" ;;
    2) 
        show_details "Core Tools" "git" "curl" "wget" "unzip" "base-devel"
        choice=$(ask_category "Core Tools" "Install after seeing details?")
        [[ $choice -eq 0 ]] && install_categories+=("core")
        ;;
esac

# Clipboard (essential)
choice=$(ask_category "Clipboard Tools" "Essential for copy/paste functionality")
case $choice in
    0) install_categories+=("clipboard") ;;
    1) echo "Skipping Clipboard Tools" ;;
    2) 
        show_details "Clipboard Tools" "wl-clipboard" "xclip" "xsel"
        choice=$(ask_category "Clipboard Tools" "Install after seeing details?")
        [[ $choice -eq 0 ]] && install_categories+=("clipboard")
        ;;
esac

# Rust Tools (performance)
choice=$(ask_category "Rust Performance Tools" "High-performance replacements for standard tools")
case $choice in
    0) install_categories+=("rust") ;;
    1) echo "Skipping Rust Tools" ;;
    2) 
        show_details "Rust Tools" "rust" "fd" "ripgrep" "bat" "git-delta" "fzf" "eza"
        choice=$(ask_category "Rust Performance Tools" "Install after seeing details?")
        [[ $choice -eq 0 ]] && install_categories+=("rust")
        ;;
esac

# Formatters
choice=$(ask_category "Code Formatters" "Automatic code formatting for various languages")
case $choice in
    0) install_categories+=("formatters") ;;
    1) echo "Skipping Formatters" ;;
    2) 
        show_details "Formatters" "biome" "prettier" "stylua" "ruff" "shfmt" "taplo-cli"
        choice=$(ask_category "Code Formatters" "Install after seeing details?")
        [[ $choice -eq 0 ]] && install_categories+=("formatters")
        ;;
esac

# LSP Servers
choice=$(ask_category "LSP Servers" "Language servers for autocompletion and diagnostics")
case $choice in
    0) install_categories+=("lsp") ;;
    1) echo "Skipping LSP Servers" ;;
    2) 
        show_details "LSP Servers" "lua-language-server" "rust-analyzer" "pyright" "gopls" "typescript-language-server"
        choice=$(ask_category "LSP Servers" "Install after seeing details?")
        [[ $choice -eq 0 ]] && install_categories+=("lsp")
        ;;
esac

# LaTeX Suite
choice=$(ask_category "LaTeX Suite" "Complete LaTeX environment with Zathura PDF viewer")
case $choice in
    0) install_categories+=("latex") ;;
    1) echo "Skipping LaTeX Suite" ;;
    2) 
        show_details "LaTeX Suite" "texlive-meta" "tectonic" "zathura" "zathura-pdf-poppler" "poppler" "biber"
        choice=$(ask_category "LaTeX Suite" "Install after seeing details?")
        [[ $choice -eq 0 ]] && install_categories+=("latex")
        ;;
esac

# Development Tools
choice=$(ask_category "Development Tools" "Programming languages and build tools")
case $choice in
    0) install_categories+=("dev") ;;
    1) echo "Skipping Development Tools" ;;
    2) 
        show_details "Development Tools" "nodejs" "npm" "python" "python-pip" "go" "gcc" "cmake" "lldb" "gdb"
        choice=$(ask_category "Development Tools" "Install after seeing details?")
        [[ $choice -eq 0 ]] && install_categories+=("dev")
        ;;
esac

# =============================================================================
# INSTALLATION EXECUTION
# =============================================================================

echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}           STARTING INSTALLATION               ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

if [ ${#install_categories[@]} -eq 0 ]; then
    echo -e "${YELLOW}No categories selected for installation${NC}"
    echo "Exiting..."
    exit 0
fi

echo -e "${CYAN}Selected categories: ${install_categories[*]}${NC}"
echo ""
echo -e "${YELLOW}Starting installation in 3 seconds...${NC}"
sleep 3

# Execute installations
for category in "${install_categories[@]}"; do
    case "$category" in
        "core") install_core_tools ;;
        "clipboard") install_clipboard ;;
        "rust") install_rust_tools ;;
        "formatters") install_formatters ;;
        "lsp") install_lsp_servers ;;
        "latex") install_latex ;;
        "dev") install_dev_tools ;;
    esac
    echo ""
done

# =============================================================================
# POST-INSTALLATION SETUP
# =============================================================================

echo -e "${BLUE}=== Post-Installation Setup ===${NC}"

# Update package database
echo -e "${YELLOW}Updating package database...${NC}"
sudo pacman -Sy

# Rust binary compilation reminder
if [[ " ${install_categories[*]} " =~ " rust " ]]; then
    echo ""
    echo -e "${CYAN}📋 Rust Performance Setup Required:${NC}"
    echo "  Run: bash ./scripts/setup/blink-cmp-rust-builder-linux.sh"
    echo ""
fi

# =============================================================================
# SUMMARY
# =============================================================================

echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}            INSTALLATION COMPLETED             ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo -e "${GREEN}Summary:${NC}"
echo "  ✅ Installed: $INSTALLED_COUNT packages"
echo "  ⏭️  Skipped: $SKIPPED_COUNT packages (already installed)"
if [ $FAILED_COUNT -gt 0 ]; then
    echo "  ❌ Failed: $FAILED_COUNT packages"
fi
echo ""

echo -e "${CYAN}Next Steps:${NC}"
echo "1. Start VelocityNvim: ${YELLOW}NVIM_APPNAME=VelocityNvim nvim${NC}"
echo "2. Run: ${YELLOW}:PluginSync${NC}"
echo "3. Build Rust binaries: ${YELLOW}bash ./scripts/setup/blink-cmp-rust-builder-linux.sh${NC}"
echo "4. Test health: ${YELLOW}:VelocityHealth${NC}"
echo ""
echo -e "${BLUE}🎉 VelocityNvim is now fully equipped!${NC}"

exit 0