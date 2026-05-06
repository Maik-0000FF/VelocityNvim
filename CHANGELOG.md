# VelocityNvim Changelog

## [Unreleased]

### Added
- **nvim-lsp-file-operations** - Automatic import updates when renaming/moving files via LSP
  - Transparent Neo-tree integration for rename/move/delete operations
  - Language-agnostic support (TypeScript, Python, Rust, Go, etc.)
  - Zero-configuration background operation
  - Plugin count: 25 → 26
- First-run version guard — aborts with a clear, copy-pasteable tarball
  install hint when launched on a Neovim version below the minimum
  (`lua/core/first-run.lua:assert_minimum_nvim_version`)
- README note for Debian / Ubuntu / Kali users — apt typically ships
  outdated Neovim; tarball install steps included

### Changed
- **Minimum Neovim version raised to 0.12.0** (was 0.11.0). The CI install
  matrix has been pulling the `stable` Neovim tarball — currently the 0.12
  line — since `ea34129`, so 0.11 was no longer being verified. Bumping
  the requirement makes the documented baseline match what is actually
  tested. README badge, requirements, bug-report template, and the
  first-run version check were updated accordingly.

### Removed
- **`install.sh`** — orphaned bootstrap script from the initial commit.
  Never referenced by README, CI, the website repo, or any other code path
  since `lua/core/first-run.lua` took over the installation flow.

---

## v1.0.1 - Security Enhancements (October 1, 2025)

### 🔒 **Security Improvements**
- Multi-layer protection system for donation information
- GitHub CODEOWNERS implementation for critical files
- Branch protection rules with code owner reviews
- Public security policy with responsible disclosure guidelines

### 📋 **Protected Files**
- Landing page and documentation requiring owner approval
- Core configuration files under review protection
- CI/CD workflows with security controls
- Security policy and gitignore files protected

### 📖 **Documentation**
- Add public SECURITY.md with disclosure policy
- Security badges in README
- Enhanced protection documentation

---

## v1.0.0 - Stable Beta Release (September 28, 2025)

### 🚀 **Status Update: Public Stable Beta**
- **IMPORTANT**: VelocityNvim is now in **Stable Beta** status, no longer "Community Preview"
- Repository is **fully public** and accessible to all users
- Core features are **production-ready** and stable for daily use
- Community support available through GitHub Discussions and Issues

### ✨ **New Features**
- Native vim.pack architecture (no plugin manager required)
- Modern LSP integration with vim.lsp.config API (Neovim 0.11+)
- Rust-powered performance tools (fzf, ripgrep, delta)
- 0.16s average startup time
- 25 curated plugins for complete IDE experience
- Cross-platform support (Linux, macOS, WSL2)

### 🔧 **Technical Improvements**
- Global LSP configuration with enhanced capabilities
- Semantic tokens disabled for responsive navigation
- Performance-first Treesitter parser management
- Comprehensive health check system (`:VelocityHealth`)
- Professional documentation and installation guides

### 🏗️ **Architecture Highlights**
- Native vim.pack plugin management (transparent Git operations)
- No external dependencies or plugin manager abstractions
- Eager loading approach - all plugins available at startup
- Stable and predictable plugin loading mechanisms

### 🌐 **Community Features**
- GitHub Discussions for community interaction
- Professional issue templates for better support
- Sponsor button with Bitcoin donation support
- Success story template for community testimonials

### 📚 **Documentation**
- Comprehensive README with installation guides
- FAQ section addressing common questions
- Performance benchmarks and comparisons
- Migration guides from other distributions

---

## Previous Releases

### v0.9.x - Community Preview (December 2024)
- Initial development and testing phase
- Private repository for early feedback
- Core architecture development

---

**Note**: This changelog clarifies VelocityNvim's evolution from Community Preview to Stable Beta status. Any references to "Community Preview" in external content are outdated as of September 2025.