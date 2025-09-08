# VelocityNvim ⚡

> Community Preview: Native vim.pack Neovim distribution for developers and enthusiasts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.10+-green.svg)](https://neovim.io)
[![Native](https://img.shields.io/badge/Plugin_Manager-vim.pack-brightgreen.svg)](#-native-architecture-benefits)
[![Performance](https://img.shields.io/badge/Performance-Ultra_Fast-orange.svg)](#-performance-characteristics)
[![Stability](https://img.shields.io/badge/Status-Community_Preview-orange.svg)](#-testing--quality)

## 🎯 What is VelocityNvim?

**A modern Neovim distribution built entirely on native vim.pack architecture.**

VelocityNvim leverages Neovim's built-in plugin system for enhanced performance, stability, and simplicity.

![VelocityNvim Dashboard](./Bildschirmfoto_VelocityNvim.png)

*VelocityNvim's customized dashboard with performance metrics and native vim.pack integration*

## 🎥 Video Demonstrations

### 📦 Installation Demo
> **Coming Soon**: Full installation walkthrough video  
> *Watch the complete VelocityNvim installation process from start to finish*

**Video Content:**
- Prerequisites verification and NerdFont installation
- Backup existing Neovim configuration
- Clone and install VelocityNvim
- Plugin synchronization with `:PluginSync`
- Health checks and system verification
- First startup and basic configuration tour

*Duration: ~5 minutes*

<!-- Installation video placeholder - will be added after recording -->
<!-- [![VelocityNvim Installation](https://img.youtube.com/vi/VIDEO_ID/0.jpg)](https://www.youtube.com/watch?v=VIDEO_ID) -->

### ⚡ Workflow Demo
> **Coming Soon**: VelocityNvim in action - developer workflow showcase  
> *Experience the power and speed of VelocityNvim in real development scenarios*

**Video Content:**
- Lightning-fast file navigation with fzf-lua
- Native LSP integration with Rust/Python/Lua
- Git workflow with enhanced delta previews
- Terminal integration and window management
- Advanced editing features and shortcuts
- Performance optimization in action

*Duration: ~8 minutes*

<!-- Workflow demo video placeholder - will be added after recording -->
<!-- [![VelocityNvim Workflow](https://img.youtube.com/vi/VIDEO_ID/0.jpg)](https://www.youtube.com/watch?v=VIDEO_ID) -->

## ✨ Why Choose Native vim.pack?

### 🎯 Native vim.pack Approach

VelocityNvim is built on Neovim's native plugin architecture:

- **Direct integration**: Works with Neovim's built-in plugin system
- **Minimal dependencies**: Reduces complexity and potential conflicts
- **Standard approach**: Uses established Neovim conventions
- **Transparent operations**: Clear plugin management without abstractions

### ✅ How VelocityNvim Works

```bash
# How plugins are installed - pure Git, no magic:
git clone https://github.com/plugin/repo ~/.local/share/nvim/site/pack/user/start/plugin
```

This approach provides direct control over plugin management using standard Git workflows.

## 🏗️ Native Architecture Benefits

### 🚀 **Performance**

- **Minimal overhead**: Direct integration with Neovim's plugin system
- **Efficient loading**: Plugins load using built-in mechanisms
- **Resource conscious**: Optimized memory and CPU usage
- **Modern tooling**: Rust-based components where beneficial (fuzzy matching)

### 🔒 **Reliability**

- **Stable foundation**: Built on established Neovim APIs
- **Predictable behavior**: Uses standard plugin loading mechanisms
- **Transparent operations**: Standard Git workflows for maintenance
- **Comprehensive testing**: Extensive test coverage for stability

### 📚 **Simplicity**

- **Focus on Neovim**: Learn core editor concepts rather than abstraction layers
- **Clear structure**: Straightforward plugin organization and loading
- **Standard patterns**: Uses familiar Neovim configuration approaches
- **Portable configuration**: Based on standard Neovim conventions

## 🏗️ VelocityNvim Architecture

| Feature                  | Implementation                | Benefit                             |
| ------------------------ | ----------------------------- | ----------------------------------- |
| **Plugin System**        | Native vim.pack               | Direct integration with Neovim core |
| **Dependencies**         | Minimal external dependencies | Reduced complexity and conflicts    |
| **Configuration**        | Standard Lua patterns         | Easy to understand and modify       |
| **Plugin Loading**       | Built-in Neovim mechanisms    | Reliable and consistent behavior    |
| **Maintenance**          | Standard Git operations       | Familiar workflows for developers   |
| **Future Compatibility** | Built on stable Neovim APIs   | Long-term reliability               |

## 📋 Prerequisites

Before installing VelocityNvim, make sure you have:

### Required
- **Neovim >= 0.10.0** - [Installation Guide](https://github.com/neovim/neovim/blob/master/INSTALL.md)
- **Git** - Version control system
- **Terminal** - Modern terminal emulator

### Recommended  
- **NerdFont** - For beautiful icons and symbols
  - [MesloLGS Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/latest) (recommended - download MesloLGS NF)
  - [Nerd Fonts Browser](https://www.nerdfonts.com/font-downloads)
- **WezTerm** - Optimal terminal for VelocityNvim
- **Rust toolchain** - For maximum performance (fzf, ripgrep, delta)

### Performance Tools (Optional)
VelocityNvim works best with these Rust-powered tools:
- `fzf` - Fuzzy finder
- `ripgrep` - Fast text search  
- `fd` - File finder
- `git-delta` - Enhanced Git diffs
- `ruff` - Python formatter

## ⚠️ Important Warnings

> **🚧 PREVIEW STATUS**: VelocityNvim is currently in Community Preview. The repository is private and some features (like the one-click installer) will be available after the public release.

> **🚨 BACKUP WARNING**: VelocityNvim will replace your existing `~/.config/nvim` configuration. Make sure to backup your current setup!

> **⏱️ FIRST RUN**: Initial plugin download may take 2-5 minutes depending on your internet connection.

> **🔧 COMPATIBILITY**: VelocityNvim uses native vim.pack and may not be compatible with other plugin managers.

## 🚀 Installation

Choose your preferred installation method:

### Method 1: One-Click Installer (Coming Soon)

**Automatic installation with dependencies:**

```bash
# Linux & macOS - Installs Neovim, NerdFont, and performance tools
# Coming soon - use Method 2 (Manual Installation) for now
curl -fsSL https://raw.githubusercontent.com/Maik-0000FF/VelocityNvim/main/install.sh | bash
```

**What the installer does:**
- ✅ Detects your OS and installs Neovim if needed
- ✅ Installs MesloLGS Nerd Font automatically  
- ✅ Installs Rust performance tools (fzf, ripgrep, etc.)
- ✅ Creates backup of existing `~/.config/nvim`
- ✅ Clones and initializes VelocityNvim
- ✅ Runs initial plugin sync

### Method 2: Manual Installation

**For users who prefer full control:**

```bash
# 1. Backup existing configuration (IMPORTANT!)
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)

# 2. Clone VelocityNvim
git clone https://github.com/Maik-0000FF/VelocityNvim.git ~/.config/nvim

# 3. Start Neovim and sync plugins
nvim -c "PluginSync" -c "qall"

# 4. Launch VelocityNvim
nvim
```

### Method 3: Parallel Installation (Advanced)

**Install alongside existing config using NVIM_APPNAME:**

```bash
# 1. Clone to separate directory
git clone https://github.com/Maik-0000FF/VelocityNvim.git ~/.config/VelocityNvim

# 2. Create launch alias
echo 'alias velocity="NVIM_APPNAME=VelocityNvim nvim"' >> ~/.bashrc
source ~/.bashrc

# 3. Initialize plugins
NVIM_APPNAME=VelocityNvim nvim -c "PluginSync" -c "qall"

# 4. Launch VelocityNvim
velocity
```

## ✅ Post-Installation

### First Steps
1. **Launch Neovim**: `nvim`
2. **Check health**: `:VelocityHealth` 
3. **Verify plugins**: `:PluginStatus`
4. **Configure terminal font** to your installed NerdFont

### Essential Commands
- `:VelocityHealth` - System health check
- `:PluginSync` - Sync all plugins  
- `:PluginStatus` - Show plugin status
- `:VelocityInfo` - Show version information

### Terminal Configuration
Configure your terminal to use a NerdFont:
- **Font**: MesloLGS Nerd Font (or your preferred NerdFont)
- **Size**: 12-14pt recommended
- **Features**: Enable font ligatures if available

## 🔧 Troubleshooting

### Plugin Issues
```bash
# Force plugin resync
:PluginSync

# Check plugin status  
:PluginStatus

# Manual plugin installation
cd ~/.local/share/nvim/site/pack/user/start/
git clone https://github.com/plugin/repo plugin-name
```

### Performance Issues
```bash
# Check Rust tools status
:RustPerformanceStatus

# Rebuild Rust components
:RustOptimize
```

### Health Check Failed
```bash
# Run comprehensive health check
:checkhealth velocitynvim

# Check Neovim version
nvim --version
```

## 🗑️ Uninstallation

```bash
# Remove VelocityNvim
rm -rf ~/.config/nvim

# Remove plugin data
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Restore backup (if available)
[ -d ~/.config/nvim.backup.* ] && mv ~/.config/nvim.backup.* ~/.config/nvim
```

## 📦 Plugin Management - The Native Way

### Adding a Plugin

```lua
-- 1. Add to plugin registry (lua/plugins/manage.lua)
M.plugins["new-plugin"] = "https://github.com/author/plugin.git"

-- 2. Create configuration (lua/plugins/category/new-plugin.lua)
local ok, plugin = pcall(require, "new-plugin")
if not ok then return end
plugin.setup({})

-- 3. Load in init (lua/plugins/init.lua)
require("plugins.category.new-plugin")
```

### Transparent Plugin Operations

```bash
# VelocityNvim way (you see everything)
cd ~/.local/share/nvim/site/pack/user/start/
git clone https://github.com/author/plugin.git
git -C plugin pull  # Update
rm -rf plugin       # Remove

# Other distributions (hidden magic)
-- require("lazy").setup({ "author/plugin" })  -- What does this actually do?
-- :Lazy update  -- Black box operation
```

### Plugin Management Commands

```vim
:PluginSync     " Install/update all plugins (pure Git)
:PluginStatus   " Show installation status
:PluginClean    " Remove unused plugins
```

## ⚡ Performance Characteristics

| Component           | Implementation               | Characteristics                     |
| ------------------- | ---------------------------- | ----------------------------------- |
| **Startup Time**    | ~1.0s (tested configuration) | Fast initialization with 24 plugins |
| **Plugin Loading**  | Direct vim.pack integration  | No additional abstraction layers    |
| **Memory Usage**    | Optimized settings           | Efficient resource utilization      |
| **Fuzzy Search**    | Rust-native with blink.cmp   | High-performance text matching      |
| **File Operations** | Native Neovim APIs           | Leverages built-in optimizations    |

_Performance tested on modern hardware with Neovim 0.10+_

## 🔧 Included Tools & Plugins

### Core Architecture

- **Plugin Manager**: Native vim.pack (built into Neovim)
- **Completion**: blink.cmp with Rust fuzzy matching
- **File Explorer**: neo-tree.nvim with optimized performance
- **Fuzzy Finder**: fzf-lua with native fzf integration
- **Git Integration**: gitsigns.nvim with delta previews
- **Status Line**: lualine.nvim with Git status
- **Colorscheme**: tokyonight.nvim

### Performance Tools

- **Rust Integration**: Native tools for maximum speed
- **LSP Optimization**: Smart workspace scanning
- **Syntax Highlighting**: nvim-treesitter
- **Code Formatting**: conform.nvim with ruff (Python)

## 🎓 Learn Native Neovim Skills

VelocityNvim teaches you **transferable Neovim knowledge**:

- ✅ **vim.pack** - Core Neovim plugin system (works everywhere)
- ✅ **Direct Git** - Universal version control (no abstraction)
- ✅ **Native APIs** - Pure Neovim functions (future-proof)
- ✅ **Standard Paths** - `~/.local/share/nvim/site/pack/user/start/`
- ❌ **Plugin Manager APIs** - Specific to one tool (becomes outdated)

## 🧪 Testing & Quality

VelocityNvim includes comprehensive testing:

- **Unit Tests**: Core functionality with 100% coverage
- **Integration Tests**: Plugin interactions and loading
- **Performance Tests**: Startup time and memory benchmarks
- **Health Checks**: System diagnostics and dependency validation

```vim
:VelocityHealth    " Comprehensive health check
:VelocityTest      " Run full test suite
:VelocityBench     " Performance benchmarks
```

## 🌍 Cross-Platform Support

### System Requirements

- **Neovim**: >= 0.10.0
- **Git**: For plugin management
- **Font**: NerdFont (MesloLGS recommended)

### Supported Platforms

- ✅ **macOS** 13+ (Intel & Apple Silicon)
- ✅ **Linux** (Arch, Ubuntu 22+, Fedora 38+)
- ✅ **WSL2** (Windows Subsystem for Linux)

### Optional Performance Tools

```bash
# Rust-powered tools for maximum performance
brew install fzf ripgrep fd git-delta ruff  # macOS
sudo pacman -S fzf ripgrep fd git-delta ruff # Arch Linux
```

## 📖 Documentation

- **[Architecture Guide](docs/ARCHITECTURE.md)** - Technical deep dive
- **[Native Advantages](docs/NATIVE-ADVANTAGES.md)** - vim.pack benefits
- **[Migration Guide](docs/MIGRATION.md)** - Moving from other distributions
- **[Plugin Development](docs/PLUGINS.md)** - Adding custom plugins
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues

## 🤝 Contributing

VelocityNvim welcomes contributions! Our native architecture makes contributing simple:

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/yourusername/VelocityNvim.git` (replace with your fork)
3. **Make changes** using standard Neovim patterns
4. **Test** with `:VelocityTest`
5. **Submit** a pull request

No plugin manager knowledge required - just pure Neovim skills!

## ☕ Support VelocityNvim

If you appreciate native, no-nonsense Neovim architecture:

### ₿ Bitcoin Donations Welcome!

```
bc1q6gmpgfn4wx2hx2c3njgpep9tl00etma9k7w6d4
```

> 🚀 **Support open-source development with Bitcoin!**  
> _(Because coffee.exe is a critical dependency for debugging)_

**Other ways to support:**

- ⭐ Star this repository
- 🐛 Report bugs and suggest improvements
- 📢 Share with other developers who value simplicity
- 🤝 Contribute code or documentation

## 📜 License

VelocityNvim is licensed under the [MIT License](LICENSE).

## 🙏 Acknowledgments

VelocityNvim exists thanks to the incredible work of many talented developers and communities. We are deeply grateful to:

### 💎 Neovim Core Team

Special thanks to the [Neovim project](https://neovim.io) and its maintainers for creating an extensible, modern editor that prioritizes performance and user experience. The native vim.pack architecture that powers VelocityNvim is a testament to their excellent design decisions.

### 🔌 Plugin Developers

VelocityNvim integrates carefully selected plugins from talented developers:

**Core Infrastructure:**

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) by **@nvim-lua** - Essential Lua utilities
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) by **@MunifTanjim** - UI component library
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) by **@nvim-tree** - File icons

**User Interface:**

- [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) by **@folke** - Beautiful colorscheme
- [alpha-nvim](https://github.com/goolord/alpha-nvim) by **@goolord** - Customizable dashboard
- [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) by **@akinsho** - Buffer management
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) by **@nvim-lualine** - Status line
- [noice.nvim](https://github.com/folke/noice.nvim) by **@folke** - Enhanced UI messages
- [nvim-notify](https://github.com/rcarriga/nvim-notify) by **@rcarriga** - Notification system

**Editor Features:**

- [which-key.nvim](https://github.com/folke/which-key.nvim) by **@folke** - Keybinding help
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) by **@nvim-neo-tree** - File explorer
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) by **@nvim-treesitter** - Syntax highlighting
- [blink.cmp](https://github.com/Saghen/blink.cmp) by **@Saghen** - Completion engine
- [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) by **@rafamadriz** - Snippet collection

**Development Tools:**

- [fzf-lua](https://github.com/ibhagwan/fzf-lua) by **@ibhagwan** - Fuzzy finder
- [conform.nvim](https://github.com/stevearc/conform.nvim) by **@stevearc** - Code formatting
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) by **@lewis6991** - Git integration
- [hlchunk.nvim](https://github.com/shellRaining/hlchunk.nvim) by **@shellRaining** - Code block highlighting

**Navigation & Utilities:**

- [hop.nvim](https://github.com/phaazon/hop.nvim) by **@phaazon** - Cursor navigation
- [nvim-window-picker](https://github.com/s1n7ax/nvim-window-picker) by **@s1n7ax** - Window selection
- [mini.nvim](https://github.com/echasnovski/mini.nvim) by **@echasnovski** - Utility collection
- [suda.vim](https://github.com/lambdalisue/suda.vim) by **@lambdalisue** - Sudo file editing
- [nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua) by **@norcalli** - Color highlighting
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) by **@MeanderingProgrammer** - Markdown rendering

### 🌟 Open Source Community

- **Contributors** who submit issues, suggestions, and improvements
- **Testers** who help ensure quality across different environments
- **Documentation writers** who help explain complex concepts
- **Plugin ecosystem maintainers** who keep the Neovim world thriving

### 🎯 Philosophy

VelocityNvim's approach of using native vim.pack reflects our respect for the thoughtful architecture decisions made by the Neovim team. By avoiding unnecessary abstractions, we honor both the editor's design and the hard work of plugin authors who create their tools to work seamlessly with Neovim's native systems.

**Native Icons Philosophy**: VelocityNvim uses NerdFont symbols instead of emojis throughout the interface. This ensures consistent visual representation across all terminals and systems, while maintaining the professional appearance that developers expect. NerdFont symbols are designed specifically for code editors and integrate seamlessly with syntax highlighting and terminal color schemes.

Every plugin in VelocityNvim was chosen not just for its functionality, but for the quality and dedication of its maintainers. Their contributions to the Neovim ecosystem make projects like VelocityNvim possible.

---

**VelocityNvim: Native vim.pack. Native performance. Native simplicity.**

_Finally, a Neovim distribution that doesn't fight against Neovim._

