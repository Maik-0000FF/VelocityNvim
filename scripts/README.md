# VelocityNvim Scripts Documentation

Utility scripts for VelocityNvim setup and maintenance.

## 🛠️ Available Scripts

### 🚀 Setup Scripts (`scripts/setup/`)
- **`velocitynvim-dependencies-installer.sh`** - Interactive installer for all VelocityNvim dependencies (Arch Linux)
- **`blink-cmp-rust-builder-linux.sh`** - Linux/Unix Rust builder with dynamic path detection
- **`blink-cmp-rust-builder-macos.sh`** - macOS Rust builder with nightly toolchain management

Dependency installer features:
- 🎯 **Interactive selection** - Choose which tool categories to install
- 📦 **Multi-package-manager support** - pacman, npm, cargo, pip integration  
- 🔍 **Smart detection** - Skips already installed packages
- 📊 **Detailed reporting** - Shows installation progress and summary
- ⚡ **Performance optimized** - Hybrid systems for maximum speed

Performance optimizations:
- 🐍 **Pyright over python-lsp-server** - Faster Python LSP
- 🐍 **Ruff for Python** - Fast formatting, import sorting, and linting
- 📄 **LaTeX size options** - Choose minimal (~500MB) or complete (~4GB) installation

Rust builder scripts feature:
- 🔍 **Dynamic path detection** - Works with any VelocityNvim installation method
- 🛡️ **Robust error handling** - Clear troubleshooting guidance
- ⚡ **Performance validation** - Automatic build verification

### 🔧 Maintenance Scripts (`scripts/maintenance/`)
- **`clean-cache-and-plugins.sh`** - Clean VelocityNvim data with dynamic path detection

Maintenance script features:
- 🔍 **Dynamic path detection** - Automatically detects installation method
- 🛡️ **Configuration protection** - Never deletes configuration files
- ⚠️ **Safety confirmation** - Requires explicit 'YES' confirmation
- 📊 **Clear reporting** - Shows what will be deleted before action

### 📊 Benchmark Scripts (`scripts/benchmarks/`)
- **`collect_benchmark_data.sh`** - Automated benchmark data collection with CPU/RAM tracking

Benchmark script features:
- 📈 **20 metrics collected** - Startup, LSP, memory, plugin count, CPU, RAM
- 🎯 **10-run methodology** - Mean and median tracking (outlier resistant)
- 🔄 **Auto-CSV export** - Direct append to `docs/benchmark_results.csv`
- 🖥️ **Hardware tracking** - CPU model and RAM size for comparisons
- 🐍 **Python formatting** - Guaranteed leading zeros in all numbers

## 🚀 Usage

### Complete VelocityNvim Setup (Recommended)

#### 1. Install Dependencies (Arch Linux)
```bash
bash ./scripts/setup/velocitynvim-dependencies-installer.sh
```
Interactive installer that allows you to choose:
- **Core Tools** - git, curl, wget, unzip, base-devel
- **Clipboard Tools** - wl-clipboard, xclip (essential for copy/paste) 
- **Rust Performance Tools** - fd, ripgrep, bat, delta, fzf
- **Code Formatters** - prettier, stylua, ruff (replaces black+isort), shfmt  
- **LSP Servers** - lua-language-server, rust-analyzer, pyright (faster than python-lsp-server)
- **LaTeX Suite** - texlive, zathura, tectonic, poppler
- **Development Tools** - nodejs, python, go, gcc, cmake

#### 2. Build Rust Performance Binaries

##### Linux/Unix
```bash
bash ./scripts/setup/blink-cmp-rust-builder-linux.sh
```

##### macOS (Intel + Apple Silicon)
```bash
bash ./scripts/setup/blink-cmp-rust-builder-macos.sh
```

#### 3. Benchmark Performance
```bash
bash ./scripts/benchmarks/collect_benchmark_data.sh
```

#### 4. Maintenance
```bash
bash ./scripts/maintenance/clean-cache-and-plugins.sh
```

## 🔧 Installation Methods Supported

The Rust builder scripts automatically detect and work with:

1. **Method 1**: Separate NVIM_APPNAME directory
   - `~/.local/share/VelocityNvim/site/pack/user/start/blink.cmp`

2. **Method 2**: Copied to ~/.config/nvim
   - `~/.local/share/nvim/site/pack/user/start/blink.cmp`

3. **Fallback**: Automatic search in all Neovim data directories

## 📋 Prerequisites

- **Rust toolchain** installed (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`)
- **blink.cmp plugin** installed (run `:PluginSync` in VelocityNvim first)
- **macOS only**: Xcode command line tools (`xcode-select --install`)

## ✅ Verification

After running a Rust builder script, verify performance is active:

```bash
NVIM_APPNAME=VelocityNvim nvim
:RustPerformanceStatus
```

## 🛠️ Troubleshooting

If compilation fails:

1. **Update Rust**: `rustup update`
2. **Clean cache**: `cargo clean` (in blink.cmp directory)
3. **Verify installation**: Check that `:PluginSync` completed successfully
4. **macOS**: Ensure Xcode tools are installed

## 📊 Script Overview

| Category | Scripts | Purpose |
|----------|---------|---------|
| Setup | 3 | Dependencies + Rust performance optimization |
| Benchmarks | 1 | Performance data collection with hardware tracking |
| Maintenance | 1 | Cache cleaning with path detection |

**Total**: 5 scripts for complete VelocityNvim setup, benchmarking, and maintenance.

## 🎯 Performance Impact

The Rust builder scripts provide:
- **5-10x faster** fuzzy matching compared to Lua fallback
- **Native performance** with Rust-compiled binaries
- **Responsive completion** even in large codebases