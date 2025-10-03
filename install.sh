#!/bin/bash
# VelocityNvim Cross-Platform Installer
# VelocityNvim Stable Beta - Native vim.pack Neovim distribution

set -e  # Exit on any error

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# VelocityNvim branding
echo -e "${PURPLE}"
echo "██    ██ ███████ ██       ██████   ██████ ██ ████████ ██    ██ "
echo "██    ██ ██      ██      ██    ██ ██      ██    ██     ██  ██  "
echo "██    ██ █████   ██      ██    ██ ██      ██    ██      ████   "
echo " ██  ██  ██      ██      ██    ██ ██      ██    ██       ██    "
echo "  ████   ███████ ███████  ██████   ██████ ██    ██       ██    "
echo -e "${NC}"
echo -e "${CYAN}        Ultra-Responsive • Rust-Powered • Native vim.pack${NC}"
echo "=================================================================="
echo -e "${BLUE}🚀 VelocityNvim Stable Beta - Native vim.pack distribution${NC}"
echo ""

# Detect OS and architecture
OS="unknown"
ARCH=$(uname -m)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if command -v lsb_release &> /dev/null; then
        DISTRO=$(lsb_release -si 2>/dev/null)
    elif [ -f /etc/os-release ]; then
        DISTRO=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
    else
        DISTRO="unknown"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    DISTRO="macos"
fi

echo -e "${YELLOW}🔍 Detected: $OS ($DISTRO) on $ARCH${NC}"
echo ""

# Function to print section headers
print_section() {
    echo -e "${BLUE}$1${NC}"
    echo "----------------------------------------"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to print info messages
print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check Neovim version compatibility
check_neovim() {
    print_section "📦 Checking Neovim Installation"
    
    if ! command_exists nvim; then
        print_error "Neovim not found"
        install_neovim
        return
    fi
    
    # Get Neovim version
    NVIM_VERSION=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    REQUIRED_VERSION="0.10.0"
    
    # Simple version comparison (works for most cases)
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NVIM_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
        print_success "Neovim $NVIM_VERSION found (>= $REQUIRED_VERSION required)"
    else
        print_error "Neovim $NVIM_VERSION found, but >= $REQUIRED_VERSION required"
        install_neovim
    fi
}

# Install Neovim based on OS
install_neovim() {
    print_section "📥 Installing Neovim"
    
    case $OS in
        "macos")
            if ! command_exists brew; then
                print_info "Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            print_info "Installing Neovim via Homebrew..."
            brew install neovim
            ;;
        "linux")
            case $DISTRO in
                "arch"|"archlinux"|"manjaro")
                    print_info "Installing Neovim via pacman..."
                    sudo pacman -S --noconfirm neovim
                    ;;
                "ubuntu"|"debian"|"linuxmint"|"pop")
                    print_info "Installing Neovim via apt..."
                    sudo apt update && sudo apt install -y neovim
                    ;;
                "fedora"|"rhel"|"centos")
                    print_info "Installing Neovim via dnf..."
                    sudo dnf install -y neovim
                    ;;
                *)
                    print_error "Unsupported Linux distribution: $DISTRO"
                    print_info "Please install Neovim >= 0.11.0 manually"
                    exit 1
                    ;;
            esac
            ;;
        *)
            print_error "Unsupported operating system: $OS"
            exit 1
            ;;
    esac
    
    print_success "Neovim installation completed"
}

# Install performance tools (Rust-powered)
install_performance_tools() {
    print_section "⚡ Installing Rust Performance Tools"
    
    case $OS in
        "macos")
            print_info "Installing performance tools via Homebrew..."
            brew install fzf ripgrep fd git rust || true
            if command_exists cargo; then
                print_info "Installing git-delta via cargo..."
                cargo install git-delta || true
            fi
            # Try ruff via brew, fallback to pip
            if ! brew install ruff 2>/dev/null; then
                print_info "Installing ruff via pip3..."
                pip3 install ruff || true
            fi
            ;;
        "linux")
            case $DISTRO in
                "arch"|"archlinux"|"manjaro")
                    print_info "Installing performance tools via pacman..."
                    sudo pacman -S --noconfirm fzf ripgrep fd git rust git-delta ruff || true
                    ;;
                "ubuntu"|"debian"|"linuxmint"|"pop")
                    print_info "Installing performance tools via apt..."
                    sudo apt install -y fzf ripgrep fd-find git || true
                    # Install Rust if not present
                    if ! command_exists rustup; then
                        print_info "Installing Rust toolchain..."
                        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                        source "$HOME/.cargo/env"
                    fi
                    # Install additional tools via cargo
                    if command_exists cargo; then
                        cargo install git-delta || true
                    fi
                    pip3 install ruff || true
                    ;;
                "fedora"|"rhel"|"centos")
                    print_info "Installing performance tools via dnf..."
                    sudo dnf install -y fzf ripgrep fd-find git || true
                    # Install Rust if not present
                    if ! command_exists rustup; then
                        print_info "Installing Rust toolchain..."
                        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                        source "$HOME/.cargo/env"
                    fi
                    if command_exists cargo; then
                        cargo install git-delta || true
                    fi
                    pip3 install ruff || true
                    ;;
            esac
            ;;
    esac
    
    print_success "Performance tools installation completed"
}

# Install MesloLGS Nerd Font
install_nerd_font() {
    print_section "🔤 Installing MesloLGS Nerd Font"
    
    case $OS in
        "macos")
            if command_exists brew; then
                print_info "Installing MesloLGS Nerd Font via Homebrew..."
                brew tap homebrew/cask-fonts 2>/dev/null || true
                brew install font-meslo-lg-nerd-font || print_warning "Font installation failed, continuing..."
            else
                install_font_manual
            fi
            ;;
        "linux")
            install_font_manual
            ;;
    esac
    
    print_success "Font installation completed"
}

# Manual font installation
install_font_manual() {
    FONT_DIR="$HOME/.local/share/fonts"
    print_info "Installing font manually to $FONT_DIR..."
    
    mkdir -p "$FONT_DIR"
    cd /tmp
    
    # Download MesloLGS Nerd Font
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.0/MesloLGNF.zip"
    if command_exists wget; then
        wget -O MesloLGNF.zip "$FONT_URL" || print_warning "Font download failed"
    elif command_exists curl; then
        curl -L -o MesloLGNF.zip "$FONT_URL" || print_warning "Font download failed"
    else
        print_warning "Neither wget nor curl found, skipping font installation"
        return
    fi
    
    if [ -f MesloLGNF.zip ]; then
        unzip -o MesloLGNF.zip -d "$FONT_DIR/" || print_warning "Font extraction failed"
        rm MesloLGNF.zip
        
        # Refresh font cache on Linux
        if command_exists fc-cache; then
            fc-cache -f -v || true
        fi
    fi
}

# Backup existing Neovim configuration
backup_existing_config() {
    print_section "💾 Backing Up Existing Configuration"
    
    if [ -d "$HOME/.config/nvim" ]; then
        BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backing up existing config to $BACKUP_DIR"
        mv "$HOME/.config/nvim" "$BACKUP_DIR"
        print_success "Backup created: $BACKUP_DIR"
    else
        print_info "No existing Neovim configuration found"
    fi
}

# Install VelocityNvim
install_velocity_nvim() {
    print_section "🚀 Installing VelocityNvim"
    
    print_info "Cloning VelocityNvim repository..."
    if ! git clone https://github.com/Maik-0000FF/VelocityNvim.git "$HOME/.config/nvim"; then
        print_error "Failed to clone VelocityNvim repository"
        print_info "Please check your internet connection and try again"
        exit 1
    fi
    
    print_success "VelocityNvim cloned successfully"
}

# Initialize plugins
initialize_plugins() {
    print_section "🔌 Initializing Native vim.pack Plugins"
    
    print_info "Running initial plugin sync..."
    if nvim --headless -c "PluginSync" -c "qall"; then
        print_success "Plugin sync completed"
    else
        print_warning "Plugin sync failed, but you can run ':PluginSync' manually later"
    fi
}

# Show terminal recommendations
show_terminal_recommendations() {
    print_section "🖥️  Terminal Recommendations"
    
    print_info "For optimal VelocityNvim experience:"
    echo ""
    
    case $OS in
        "macos")
            echo -e "  ${CYAN}Recommended Terminal:${NC} WezTerm"
            echo -e "  ${YELLOW}Install:${NC} brew install --cask wezterm"
            echo ""
            echo -e "  ${CYAN}Alternative Terminals:${NC} iTerm2, Terminal.app"
            ;;
        "linux")
            echo -e "  ${CYAN}Recommended Terminal:${NC} WezTerm"
            echo -e "  ${YELLOW}Install:${NC} https://wezfurlong.org/wezterm/installation.html"
            echo ""
            echo -e "  ${CYAN}Alternative Terminals:${NC} Alacritty, Kitty, GNOME Terminal"
            ;;
    esac
    
    echo ""
    print_info "Configure your terminal with MesloLGS Nerd Font for perfect icons!"
}

# Show next steps
show_next_steps() {
    print_section "🎯 Next Steps"
    
    echo -e "${GREEN}🎉 VelocityNvim installation completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}How to start:${NC}"
    echo -e "  ${YELLOW}nvim${NC}  # Launch VelocityNvim"
    echo ""
    echo -e "${CYAN}Essential commands:${NC}"
    echo -e "  ${YELLOW}:VelocityHealth${NC}    # Check system health"
    echo -e "  ${YELLOW}:PluginSync${NC}       # Sync all plugins (pure Git)"
    echo -e "  ${YELLOW}:PluginStatus${NC}     # Show plugin status"
    echo ""
    echo -e "${CYAN}Key features to explore:${NC}"
    echo -e "  • ${GREEN}Native vim.pack${NC} - No plugin manager overhead"
    echo -e "  • ${GREEN}Rust-powered performance${NC} - Ultra-fast fuzzy search"
    echo -e "  • ${GREEN}Transparent operations${NC} - Pure Git, no magic"
    echo -e "  • ${GREEN}Future-proof design${NC} - Will work with any Neovim version"
    echo ""
    echo -e "${PURPLE}🚀 Welcome to the native vim.pack revolution!${NC}"
    echo -e "${CYAN}   Learn more: https://github.com/Maik-0000FF/VelocityNvim${NC}"
}

# Main installation flow
main() {
    # Check prerequisites
    if ! command_exists git; then
        print_error "Git is required but not installed"
        print_info "Please install Git and try again"
        exit 1
    fi
    
    # Installation steps
    check_neovim
    install_performance_tools
    install_nerd_font
    backup_existing_config
    install_velocity_nvim
    initialize_plugins
    show_terminal_recommendations
    show_next_steps
    
    echo ""
    echo -e "${GREEN}✨ Installation complete! Enjoy VelocityNvim! ✨${NC}"
}

# Run main installation
main "$@"