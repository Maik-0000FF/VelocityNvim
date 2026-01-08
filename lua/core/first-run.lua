-- ~/.config/VelocityNvim/lua/core/first-run.lua
-- Terminal-based First-Run Installation System for VelocityNvim
-- Clean, simple, everything runs in one terminal

local M = {}

-- Check if first-run installation is needed
function M.is_needed()
  local plugins_dir = vim.fn.stdpath("data") .. "/site/pack/user/start"
  return vim.fn.isdirectory(plugins_dir) == 0
end

-- Generate the complete installation script
local function generate_install_script()
  local data_dir = vim.fn.stdpath("data")
  local pack_dir = data_dir .. "/site/pack/user/start"
  local nvim_appname = vim.fn.getenv("NVIM_APPNAME") or "nvim"

  -- Get plugin list
  local manage_ok, manage = pcall(require, "plugins.manage")
  local plugins = {}
  if manage_ok then
    plugins = manage.get_all_plugins and manage.get_all_plugins() or manage.plugins or {}
  end

  -- Build plugin clone commands
  local plugin_commands = {}
  for name, url in pairs(plugins) do
    table.insert(plugin_commands, string.format(
      '  clone_plugin "%s" "%s"',
      name, url
    ))
  end

  -- Treesitter parsers to install
  local parsers = "lua vim vimdoc markdown markdown_inline python javascript typescript html css json bash rust toml yaml"

  local script = string.format([=[#!/bin/bash
# VelocityNvim First-Run Installation Script
# Generated automatically - runs completely in terminal

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Directories
DATA_DIR="%s"
PACK_DIR="%s"
NVIM_APPNAME="%s"

# Counters
TOTAL_PLUGINS=0
INSTALLED_PLUGINS=0
FAILED_PLUGINS=0
WARNINGS=()

# Print header
print_header() {
  clear
  echo -e "${CYAN}"
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║                                                                              ║"
  echo "║   ██╗   ██╗███████╗██╗      ██████╗  ██████╗██╗████████╗██╗   ██╗            ║"
  echo "║   ██║   ██║██╔════╝██║     ██╔═══██╗██╔════╝██║╚══██╔══╝╚██╗ ██╔╝            ║"
  echo "║   ██║   ██║█████╗  ██║     ██║   ██║██║     ██║   ██║    ╚████╔╝             ║"
  echo "║   ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██║     ██║   ██║     ╚██╔╝              ║"
  echo "║    ╚████╔╝ ███████╗███████╗╚██████╔╝╚██████╗██║   ██║      ██║               ║"
  echo "║     ╚═══╝  ╚══════╝╚══════╝ ╚═════╝  ╚═════╝╚═╝   ╚═╝      ╚═╝               ║"
  echo "║                                                                              ║"
  echo "║                        First-Run Installation                                ║"
  echo "║                                                                              ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo ""
}

# Print section header
section() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

# Success message
success() {
  echo -e "  ${GREEN}✓${NC} $1"
}

# Warning message
warn() {
  echo -e "  ${YELLOW}⚠${NC} $1"
  WARNINGS+=("$1")
}

# Error message
error() {
  echo -e "  ${RED}✗${NC} $1"
}

# Info message
info() {
  echo -e "  ${CYAN}→${NC} $1"
}

# Progress indicator
progress() {
  echo -ne "  ${CYAN}◐${NC} $1\r"
}

# Clone a plugin
clone_plugin() {
  local name="$1"
  local url="$2"
  local path="$PACK_DIR/$name"

  TOTAL_PLUGINS=$((TOTAL_PLUGINS + 1))

  if [ -d "$path" ]; then
    success "$name (cached)"
    INSTALLED_PLUGINS=$((INSTALLED_PLUGINS + 1))
    return 0
  fi

  progress "Installing $name..."
  if git clone --depth 1 --quiet "$url" "$path" 2>/dev/null; then
    success "$name"
    INSTALLED_PLUGINS=$((INSTALLED_PLUGINS + 1))
    return 0
  else
    error "$name (failed)"
    FAILED_PLUGINS=$((FAILED_PLUGINS + 1))
    return 1
  fi
}

# ============================================================================
# PHASE 1: System Detection
# ============================================================================
print_header

section "Phase 1: System Detection"

# Detect OS
OS="unknown"
DISTRO="unknown"
PKG_MANAGER=""

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
  if [ -f /etc/arch-release ]; then
    DISTRO="arch"
    PKG_MANAGER="pacman"
  elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
    PKG_MANAGER="apt"
  elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
    PKG_MANAGER="dnf"
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
  DISTRO="macos"
  if command -v brew &>/dev/null; then
    PKG_MANAGER="brew"
  fi
fi

success "Operating System: $OS ($DISTRO)"
[ -n "$PKG_MANAGER" ] && success "Package Manager: $PKG_MANAGER" || warn "No package manager detected"

# Check Neovim version
NVIM_VERSION=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
success "Neovim Version: $NVIM_VERSION"

# Check required tools
echo ""
info "Checking required tools..."

check_tool() {
  local cmd="$1"
  local name="$2"
  local required="$3"

  if command -v "$cmd" &>/dev/null; then
    success "$name: $(command -v $cmd)"
    return 0
  else
    if [ "$required" = "yes" ]; then
      error "$name: NOT FOUND (required)"
      return 1
    else
      warn "$name: not found (optional)"
      return 0
    fi
  fi
}

check_tool "git" "Git" "yes" || { echo "Git is required. Please install it first."; exit 1; }
check_tool "gcc" "GCC" "no"
check_tool "cargo" "Cargo" "no"
check_tool "rg" "Ripgrep" "no"
check_tool "fzf" "FZF" "no"
check_tool "npm" "npm" "no"

# Clipboard check (platform-specific)
echo ""
info "Checking clipboard support..."

if [[ "$OS" == "macos" ]]; then
  success "pbcopy/pbpaste (macOS built-in)"
else
  # Detect display server
  if [[ -n "$WAYLAND_DISPLAY" ]]; then
    # Wayland
    if command -v wl-copy &>/dev/null; then
      success "wl-clipboard (Wayland)"
    else
      warn "wl-clipboard not found - install: pacman -S wl-clipboard / apt install wl-clipboard"
    fi
  else
    # X11 - prefer xclip (more stable)
    if command -v xclip &>/dev/null; then
      success "xclip (X11) - recommended"
    elif command -v xsel &>/dev/null; then
      success "xsel (X11 fallback)"
      info "  Consider installing xclip for better stability"
    else
      warn "No clipboard tool found!"
      warn "  Install xclip: pacman -S xclip / apt install xclip"
      warn "  System clipboard (yank/paste) will not work without this"
    fi
  fi
fi

# ============================================================================
# PHASE 2: Package Selection
# ============================================================================

section "Phase 2: Package Selection"

echo -e "  Choose your installation profile:\n"
echo -e "  ${BOLD}[1]${NC} Core Installation"
echo -e "      Basic editor with LSP, completion, file explorer, git"
echo ""
echo -e "  ${BOLD}[2]${NC} Extended Installation"
echo -e "      Core + LaTeX, Typst, Strudel (live coding music)"
echo ""
echo -e "  ${BOLD}[3]${NC} Custom Selection"
echo -e "      Choose individual optional packages"
echo ""

SELECTED_PACKAGES=""
while true; do
  echo -ne "  Select [1/2/3]: "
  read -r PROFILE_CHOICE

  case "$PROFILE_CHOICE" in
    1)
      success "Core Installation selected"
      SELECTED_PACKAGES=""
      break
      ;;
    2)
      success "Extended Installation selected"
      SELECTED_PACKAGES="strudel latex typst"
      break
      ;;
    3)
      echo ""
      info "Custom package selection:"
      echo ""

      # Strudel
      echo -ne "  ${BOLD}Strudel${NC} (Live coding music with TidalCycles) [y/N]: "
      read -r CHOICE_STRUDEL
      [[ "$CHOICE_STRUDEL" =~ ^[Yy]$ ]] && SELECTED_PACKAGES="$SELECTED_PACKAGES strudel"

      # LaTeX
      echo -ne "  ${BOLD}LaTeX${NC} (Scientific writing with texlab LSP) [y/N]: "
      read -r CHOICE_LATEX
      [[ "$CHOICE_LATEX" =~ ^[Yy]$ ]] && SELECTED_PACKAGES="$SELECTED_PACKAGES latex"

      # Typst
      echo -ne "  ${BOLD}Typst${NC} (Modern typesetting with tinymist LSP) [y/N]: "
      read -r CHOICE_TYPST
      [[ "$CHOICE_TYPST" =~ ^[Yy]$ ]] && SELECTED_PACKAGES="$SELECTED_PACKAGES typst"

      echo ""
      if [ -z "$SELECTED_PACKAGES" ]; then
        success "No optional packages selected"
      else
        success "Selected:$SELECTED_PACKAGES"
      fi
      break
      ;;
    *)
      warn "Invalid choice, please enter 1, 2, or 3"
      ;;
  esac
done

# Save selection to JSON config file
CONFIG_FILE="$DATA_DIR/optional-features.json"
mkdir -p "$DATA_DIR"

# Build JSON array
JSON_ARRAY="[]"
if [ -n "$SELECTED_PACKAGES" ]; then
  JSON_ITEMS=""
  for pkg in $SELECTED_PACKAGES; do
    [ -n "$JSON_ITEMS" ] && JSON_ITEMS="$JSON_ITEMS,"
    JSON_ITEMS="$JSON_ITEMS\"$pkg\""
  done
  JSON_ARRAY="[$JSON_ITEMS]"
fi

echo "{\"selected\":$JSON_ARRAY,\"configured\":true}" > "$CONFIG_FILE"
info "Configuration saved to $CONFIG_FILE"

# ============================================================================
# PHASE 3: Plugin Installation
# ============================================================================

section "Phase 3: Plugin Installation"

# Create directories
mkdir -p "$PACK_DIR"
info "Plugin directory: $PACK_DIR"
echo ""

# Install core plugins
%s

# Install optional plugins based on selection
if [[ "$SELECTED_PACKAGES" == *"strudel"* ]]; then
  clone_plugin "strudel.nvim" "https://github.com/gruvw/strudel.nvim"
fi

echo ""
if [ $FAILED_PLUGINS -eq 0 ]; then
  success "All $TOTAL_PLUGINS plugins installed successfully!"
else
  warn "$INSTALLED_PLUGINS/$TOTAL_PLUGINS plugins installed ($FAILED_PLUGINS failed)"
fi

# ============================================================================
# PHASE 4: Treesitter Parser Installation
# ============================================================================

section "Phase 4: Treesitter Parser Installation"

PARSERS="%s"
# IMPORTANT: Treesitter installs parsers to data_dir/site/parser, NOT in the plugin folder
PARSER_DIR="$DATA_DIR/site/parser"
TS_INSTALLED=0
TS_FAILED=0
TS_TOTAL=0

# Ensure parser directory exists
mkdir -p "$PARSER_DIR"

# Check for compiler
if ! command -v gcc &>/dev/null && ! command -v clang &>/dev/null; then
  warn "No C compiler found - skipping Treesitter parsers"
  warn "Install with: pacman -S gcc / apt install build-essential / brew install gcc"
else
  info "Installing Treesitter parsers (this takes a few minutes)..."
  info "Parser directory: $PARSER_DIR"
  echo ""

  for parser in $PARSERS; do
    TS_TOTAL=$((TS_TOTAL + 1))

    # Check if already installed
    if [ -f "$PARSER_DIR/${parser}.so" ]; then
      success "$parser (cached)"
      TS_INSTALLED=$((TS_INSTALLED + 1))
      continue
    fi

    printf "  ${CYAN}◐${NC} Compiling $parser..."

    # Run TSInstall synchronously (foreground, wait for completion)
    # sleep 3 gives nvim time to complete the async compilation
    NVIM_APPNAME="$NVIM_APPNAME" nvim --headless \
      -c "TSInstall! $parser" \
      -c "sleep 3" \
      -c "qa!" \
      2>/dev/null

    # Check result
    if [ -f "$PARSER_DIR/${parser}.so" ]; then
      printf "\r  ${GREEN}✓${NC} $parser                              \n"
      TS_INSTALLED=$((TS_INSTALLED + 1))
    else
      printf "\r  ${RED}✗${NC} $parser (failed)                      \n"
      TS_FAILED=$((TS_FAILED + 1))
    fi
  done

  echo ""
  if [ $TS_FAILED -eq 0 ]; then
    success "All $TS_TOTAL parsers compiled successfully!"
  else
    warn "$TS_INSTALLED/$TS_TOTAL parsers compiled ($TS_FAILED failed)"
  fi
fi

# ============================================================================
# PHASE 5: Rust Performance Build (blink.cmp)
# ============================================================================

section "Phase 5: Rust Performance Build"

BLINK_PATH="$PACK_DIR/blink.cmp"

if [ ! -d "$BLINK_PATH" ]; then
  warn "blink.cmp not installed - skipping Rust build"
elif ! command -v cargo &>/dev/null && [ ! -x "$HOME/.cargo/bin/cargo" ]; then
  warn "Cargo not found - skipping Rust build (blink.cmp will use Lua fallback)"
  warn "Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
else
  CARGO_CMD="${HOME}/.cargo/bin/cargo"
  [ -x "$(command -v cargo)" ] && CARGO_CMD="cargo"

  RUSTUP_CMD="${HOME}/.cargo/bin/rustup"
  [ -x "$(command -v rustup)" ] && RUSTUP_CMD="rustup"

  # Check/install nightly
  if ! "$RUSTUP_CMD" run nightly rustc --version &>/dev/null 2>&1; then
    info "Installing Rust nightly toolchain..."
    "$RUSTUP_CMD" install nightly 2>/dev/null || warn "Could not install nightly"
  fi

  if "$RUSTUP_CMD" run nightly rustc --version &>/dev/null 2>&1; then
    info "Building blink.cmp fuzzy matcher..."
    echo ""

    cd "$BLINK_PATH"
    if "$CARGO_CMD" +nightly build --release 2>&1 | tail -5; then
      echo ""
      if [ -f "$BLINK_PATH/target/release/libblink_cmp_fuzzy.so" ] || \
         [ -f "$BLINK_PATH/target/release/libblink_cmp_fuzzy.dylib" ]; then
        success "Rust build successful! Full performance enabled."
      else
        warn "Rust build completed but library not found"
      fi
    else
      echo ""
      warn "Rust build failed - blink.cmp will use Lua fallback"
    fi
  else
    warn "Rust nightly not available - skipping blink.cmp build"
  fi
fi

# ============================================================================
# PHASE 6: Optional Dependencies
# ============================================================================

if [ -n "$SELECTED_PACKAGES" ]; then
  section "Phase 6: Optional Dependencies"

  # Strudel npm dependencies
  if [[ "$SELECTED_PACKAGES" == *"strudel"* ]]; then
    STRUDEL_PATH="$PACK_DIR/strudel.nvim"
    if [ -d "$STRUDEL_PATH" ] && [ -f "$STRUDEL_PATH/package.json" ]; then
      if command -v npm &>/dev/null; then
        info "Installing Strudel npm dependencies..."
        cd "$STRUDEL_PATH" && npm ci --silent 2>/dev/null && success "Strudel dependencies installed" || warn "Strudel npm install failed"
      else
        warn "npm not found - Strudel requires: npm install in $STRUDEL_PATH"
      fi
    fi
  fi

  # LaTeX dependencies check
  if [[ "$SELECTED_PACKAGES" == *"latex"* ]]; then
    info "LaTeX selected - checking dependencies..."
    command -v texlab &>/dev/null && success "texlab LSP found" || warn "texlab not found - install: pacman -S texlab / brew install texlab"
    command -v latexmk &>/dev/null && success "latexmk found" || warn "latexmk not found - install: pacman -S texlive-binextra"

    # PDF viewer check (platform-specific)
    if [[ "$OS" == "macos" ]]; then
      if [ -d "/Applications/Skim.app" ]; then
        success "Skim PDF viewer found (recommended for SyncTeX)"
      else
        warn "Skim not found - install from https://skim-app.sourceforge.io"
        info "  Fallback: Preview will be used"
      fi
    else
      command -v zathura &>/dev/null && success "zathura PDF viewer found" || warn "zathura not found - install: pacman -S zathura zathura-pdf-mupdf"
    fi
  fi

  # Typst dependencies check
  if [[ "$SELECTED_PACKAGES" == *"typst"* ]]; then
    info "Typst selected - checking dependencies..."
    command -v tinymist &>/dev/null && success "tinymist LSP found" || warn "tinymist not found - install: cargo install tinymist"
    command -v typst &>/dev/null && success "typst compiler found" || warn "typst not found - install: cargo install typst-cli"

    # PDF viewer check (if not already checked by LaTeX)
    if [[ "$SELECTED_PACKAGES" != *"latex"* ]]; then
      if [[ "$OS" == "macos" ]]; then
        if [ -d "/Applications/Skim.app" ]; then
          success "Skim PDF viewer found"
        else
          info "PDF viewer: Preview (macOS default)"
        fi
      else
        command -v zathura &>/dev/null && success "zathura PDF viewer found" || warn "zathura not found - install: pacman -S zathura zathura-pdf-mupdf"
      fi
    fi
  fi
fi

# ============================================================================
# Installation Summary
# ============================================================================

section "Installation Summary"

echo -e "  ${BOLD}Plugins:${NC}     $INSTALLED_PLUGINS/$TOTAL_PLUGINS installed"
echo -e "  ${BOLD}Treesitter:${NC}  $TS_INSTALLED/$TS_TOTAL parsers compiled"

if [ -f "$BLINK_PATH/target/release/libblink_cmp_fuzzy.so" ] || \
   [ -f "$BLINK_PATH/target/release/libblink_cmp_fuzzy.dylib" ]; then
  echo -e "  ${BOLD}Rust:${NC}        ${GREEN}✓${NC} blink.cmp optimized"
else
  echo -e "  ${BOLD}Rust:${NC}        ${YELLOW}○${NC} using Lua fallback"
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo ""
  echo -e "  ${BOLD}Warnings (${#WARNINGS[@]}):${NC}"
  for w in "${WARNINGS[@]}"; do
    echo -e "    ${YELLOW}•${NC} $w"
  done
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Installation complete! Press ENTER to start VelocityNvim...${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -r

]=], data_dir, pack_dir, nvim_appname, table.concat(plugin_commands, "\n"), parsers)

  return script
end

-- Run the installation
function M.run_installation()
  -- Check if bash is available
  if vim.fn.executable("bash") ~= 1 then
    vim.notify("Error: bash is required for installation. Please install bash first.", vim.log.levels.ERROR)
    return
  end

  -- Generate script
  local script = generate_install_script()
  local script_path = vim.fn.stdpath("data") .. "/velocity-install.sh"

  -- Ensure data directory exists
  vim.fn.mkdir(vim.fn.stdpath("data"), "p")

  -- Write script
  vim.fn.writefile(vim.split(script, "\n"), script_path)
  vim.fn.setfperm(script_path, "rwxr-xr-x")

  -- Run in terminal (full screen) - explicitly use bash
  vim.cmd("enew")
  vim.cmd("terminal bash " .. vim.fn.shellescape(script_path))

  -- Auto-restart when done
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = function()
      -- Restart Neovim
      vim.defer_fn(function()
        vim.cmd("qall!")
      end, 100)
    end,
  })

  -- Enter terminal mode
  vim.cmd("startinsert")
end

-- Silent check for headless mode
function M.quick_check()
  return not M.is_needed()
end

return M
