# VelocityNvim Installation Guide

## 🚀 One-Click Installation (Recommended)

**For new installations, only ONE command is needed:**

```bash
NVIM_APPNAME=VelocityNvim nvim
```

That's it! ✨ The complete installation runs automatically:

- ✅ All plugins are automatically installed
- ✅ Rust performance optimizations are compiled  
- ✅ Health checks are performed
- ✅ Welcome setup is configured

## 📋 Installation with Helper Script

For additional system checks, use the installation script:

```bash
# Check and automatically install system dependencies
./install.sh

# Only check dependencies (no installation)
./install.sh --check

# Show manual installation steps
./install.sh --manual
```

## 🔧 Manual Installation (If Desired)

If you want to control the installation manually:

```bash
# 1. Start VelocityNvim
NVIM_APPNAME=VelocityNvim nvim

# 2. In Neovim - if automatic installation doesn't start:
:VelocityFirstRun

# 3. Alternative manual commands:
:PluginSync              # Install plugins
:VelocityHealth           # Check system health
:VelocityReinstall        # Force reinstallation
```

## 📊 Installation Phases

The automatic installation runs in 5 phases:

1. **Compatibility Check** - Neovim Version & System Tools
2. **Plugin Installation** - Automatic plugin installation via Git
3. **Rust Performance Build** - blink.cmp Rust optimizations (if Cargo available)
4. **Health Verification** - Automatic system health checks
5. **Welcome Setup** - Finalization & Welcome screen

## 🎯 Prerequisites

### Required
- **Neovim >= 0.10.0** (tested up to 0.11.4)
- **Git** (for plugin installation)

### Recommended (for optimal performance)
- **Rust/Cargo** (for blink.cmp Rust performance)
- **Ripgrep (rg)** (for faster search)
- **FZF** (for fuzzy finding)
- **fd** (for faster file finding)
- **delta** (for enhanced Git diffs)

## 🔍 System Check

Check your system before installation:

```bash
# Using the helper script
./install.sh --check

# Manually
nvim --version              # Check Neovim version
git --version              # Git available?
cargo --version            # Rust/Cargo available?
rg --version               # Ripgrep available?
```

## 🏆 macOS-Specific Installation

On macOS (including M1/M2):

```bash
# 1. Homebrew Tools (recommended)
brew install ripgrep fd fzf git-delta

# 2. Rust (optional for performance)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 3. Start VelocityNvim
NVIM_APPNAME=VelocityNvim nvim
```

## ⚡ After Installation

After successful installation:

```bash
# Start VelocityNvim normally
NVIM_APPNAME=VelocityNvim nvim

# Check system health
:VelocityHealth

# Show version & features
:VelocityInfo

# Check performance status
:PerformanceStatus
```

## 🛠️ Troubleshooting

### Installation Fails

```bash
# Force reinstallation
NVIM_APPNAME=VelocityNvim nvim -c "VelocityReinstall"

# Manually synchronize plugins
NVIM_APPNAME=VelocityNvim nvim -c "PluginSync"

# Diagnose system health
NVIM_APPNAME=VelocityNvim nvim -c "VelocityHealth"
```

### Rust Build Errors

```bash
# Check Rust tools
cargo --version

# Manually compile blink.cmp
cd ~/.local/share/VelocityNvim/site/pack/user/start/blink.cmp
cargo build --release
```

### Permission Issues

```bash
# Make installation script executable
chmod +x install.sh

# Check plugin directory permissions
ls -la ~/.local/share/VelocityNvim/
```

## 📈 Performance Optimization

For maximum performance:

1. **Install all recommended tools** (rg, fd, fzf, delta)
2. **Enable Rust builds** (install Cargo)
3. **Optimize terminal** (WezTerm recommended)
4. **Regular health checks** (`:VelocityHealth`)

## 🎪 Features After Installation

After successful installation, available features:

- **Ultra-responsive cursor navigation** (< 2ms)
- **Rust-optimized fuzzy matching** (5-10x faster)
- **Automatic plugin updates** (`:PluginSync`)
- **Advanced LSP integration** (multiple servers)
- **Terminal management** (Alt+i/+/-/\\ keys)
- **Git integration** (Delta diff viewer)
- **Performance monitoring** (`:PerformanceStatus`)

---

**🚀 Enjoy VelocityNvim - World-Class Neovim Configuration!**