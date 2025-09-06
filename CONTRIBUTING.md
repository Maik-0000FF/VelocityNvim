# Contributing to VelocityNvim ⚡

Thank you for your interest in contributing to VelocityNvim! As a community preview of a native vim.pack Neovim distribution, we welcome contributions that align with our core philosophy of simplicity, performance, and native architecture.

## 🎯 Our Philosophy

Before contributing, please understand VelocityNvim's core principles:

- **Native First**: We use only vim.pack, no external plugin managers
- **Transparent Operations**: Every operation should be understandable
- **Performance Focused**: Rust-powered tools and zero overhead
- **Future-Proof**: Only use stable Neovim APIs
- **Simplicity**: Learn Neovim, not plugin manager abstractions
- **NerdFont Icons**: We use NerdFont symbols instead of emojis for consistent terminal compatibility and professional appearance

## 🚀 Quick Start for Contributors

### Prerequisites
- **Neovim**: >= 0.10.0
- **Git**: For repository management
- **Rust/Cargo**: For performance optimizations (optional)
- **Basic Neovim knowledge**: Understanding of vim.pack and native APIs

### Development Setup
```bash
# Fork and clone
git clone https://github.com/yourusername/VelocityNvim.git  # Replace with your fork
cd VelocityNvim

# Test your changes
nvim -c "VelocityTest" -c "qall"
nvim -c "VelocityHealth" -c "qall"
```

## 🔧 Types of Contributions

### 1. **Plugin Integration**
Adding new plugins using native vim.pack architecture:

```lua
-- 1. Add to lua/plugins/manage.lua
M.plugins["new-plugin"] = "https://github.com/author/plugin.git"

-- 2. Create configuration file
-- lua/plugins/category/new-plugin.lua
local ok, plugin = pcall(require, "new-plugin")
if not ok then return end
plugin.setup({})

-- 3. Add to loader
-- lua/plugins/init.lua  
require("plugins.category.new-plugin")
```

**Requirements:**
- Must use `pcall()` for safe loading
- No lazy loading abstractions
- Follow existing file structure
- Include health check registration if applicable

### 2. **Performance Improvements**
- Rust tool integrations
- Native API optimizations
- Startup time improvements
- Memory usage reductions

### 3. **Documentation**
- Code comments explaining WHY decisions were made
- Architecture documentation
- Native vim.pack guides
- Troubleshooting guides

### 4. **Bug Fixes**
- Edge case handling
- Cross-platform compatibility
- Native API compatibility issues

## 📋 Contribution Guidelines

### **Code Standards**

#### Native vim.pack Architecture
```lua
-- ✅ CORRECT: Native vim.pack approach
local pack_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/"
vim.fn.system({"git", "clone", url, pack_dir .. name})

-- ❌ WRONG: Plugin manager abstraction
require("lazy").setup({ "plugin/name" })
```

#### Safe Module Loading
```lua
-- ✅ CORRECT: Always use pcall
local ok, plugin = pcall(require, "plugin-name")
if not ok then
  vim.notify("Plugin not available: plugin-name", vim.log.levels.WARN)
  return
end

-- ❌ WRONG: Direct require
local plugin = require("plugin-name")
```

#### Native API Usage
```lua
-- ✅ CORRECT: Use modern, stable APIs
local uv = vim.uv or vim.loop
local diagnostics = vim.diagnostic.get()

-- ❌ WRONG: Deprecated or unstable APIs
local diagnostics = vim.lsp.diagnostic.get_all()
```

### **Documentation Requirements**

#### Code Comments
Focus on **WHY**, not what:
```lua
-- ✅ CORRECT: Explains reasoning
-- Use gestaffelt loading to prioritize critical plugins first
-- Critical: UI components (0ms) → Editor tools (50ms) → Conveniences (100ms)
vim.defer_fn(function() require("plugins.tools") end, 100)

-- ❌ WRONG: States the obvious
-- Load tools after 100ms
vim.defer_fn(function() require("plugins.tools") end, 100)
```

#### Architecture Documentation
- Explain design decisions
- Document native vim.pack benefits
- Include migration guides from other distributions

### **Testing Requirements**

All contributions must include appropriate tests:
```bash
# Run full test suite
nvim -c "VelocityTest all" -c "qall"

# Run specific test categories
nvim -c "VelocityTest health" -c "qall"
nvim -c "VelocityTest performance" -c "qall"
```

#### Test Categories
- **Health Tests**: System compatibility and dependencies
- **Unit Tests**: Individual function testing
- **Performance Tests**: Startup time and memory benchmarks
- **Integration Tests**: Plugin interaction testing

## 🔄 Contribution Workflow

### 1. **Issues First**
- Check existing issues before starting work
- Create an issue to discuss significant changes
- Use issue templates for bugs and feature requests

### 2. **Branch Strategy**
```bash
git checkout -b feature/native-plugin-name
git checkout -b fix/plugin-loading-issue
git checkout -b docs/vim-pack-guide
```

### 3. **Commit Standards**
```bash
git commit -m "feat(plugins): add neo-tree native vim.pack integration

- Configure neo-tree with native loading pattern
- Add health check for file system dependencies  
- Include cross-platform path handling
- Document native advantages over abstract managers

Closes #123"
```

#### Commit Types
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `perf`: Performance improvements
- `test`: Test additions or modifications
- `refactor`: Code restructuring without feature changes

### 4. **Pull Request Process**

#### Before Submitting
- [ ] All tests pass locally
- [ ] Code follows native vim.pack patterns
- [ ] Documentation updated if needed
- [ ] Health checks pass
- [ ] Performance regression tested

#### PR Template
```markdown
## Summary
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix
- [ ] New plugin integration  
- [ ] Performance improvement
- [ ] Documentation update

## Native vim.pack Compliance
- [ ] Uses only native vim.pack architecture
- [ ] No external plugin manager dependencies
- [ ] Safe loading with pcall()
- [ ] Follows existing file structure

## Testing
- [ ] Health checks pass
- [ ] Performance tests pass
- [ ] Cross-platform tested (if applicable)

## Breaking Changes
List any breaking changes and migration path.
```

## 🛡️ Code Review Criteria

### **Must Pass**
- ✅ Uses native vim.pack architecture exclusively
- ✅ No external plugin manager dependencies
- ✅ Safe error handling with pcall()
- ✅ Performance regression tests pass
- ✅ Health checks pass
- ✅ Cross-platform compatibility

### **Good to Have**
- 🎯 Performance improvements
- 📚 Clear documentation
- 🧪 Comprehensive tests
- 🔍 Edge case handling

### **Will Be Rejected**
- ❌ Any use of lazy.nvim, packer, or similar
- ❌ Breaking native vim.pack philosophy  
- ❌ Performance regressions
- ❌ Undocumented complex changes
- ❌ Missing error handling

## 🎓 Learning Native vim.pack

### **Essential Concepts**
- `~/.local/share/nvim/site/pack/user/start/` - Plugin directory
- `git clone` - Plugin installation
- `git pull` - Plugin updates
- `rm -rf` - Plugin removal
- No abstractions, no magic

### **Helpful Resources**
- `:help vim.pack` - Official Neovim documentation
- `docs/NATIVE-ADVANTAGES.md` - Our philosophy guide
- `docs/ARCHITECTURE.md` - Technical deep dive
- `lua/plugins/manage.lua` - Reference implementation

## 💬 Community Guidelines

### **Be Respectful**
- Respect the native vim.pack philosophy
- Provide constructive feedback
- Help newcomers learn native approaches

### **Be Patient**  
- Code reviews focus on education
- We explain WHY native approaches are better
- Learning curve is part of the process

### **Be Collaborative**
- Share knowledge about native vim.pack
- Document lessons learned
- Help improve the native ecosystem

## 🐛 Reporting Issues

### **Bug Reports**
Use the bug report template and include:
- VelocityNvim version (`:VelocityVersion`)
- Neovim version (`nvim --version`)
- Operating system
- Steps to reproduce
- Expected vs actual behavior
- Health check output (`:VelocityHealth`)

### **Feature Requests**
- Explain how it fits native vim.pack philosophy
- Provide use case and motivation  
- Consider if it belongs in VelocityNvim vs separate plugin
- Check if it can be achieved with existing tools

## 🏆 Recognition

Contributors who help advance the native vim.pack ecosystem will be:
- Listed in our contributors section
- Mentioned in release notes
- Invited to help guide project direction

## ❓ Questions?

- **General Questions**: Open a discussion
- **Architecture Questions**: See `docs/ARCHITECTURE.md`
- **Native vim.pack Help**: See `docs/NATIVE-ADVANTAGES.md`

---

**Thank you for helping advance the native vim.pack revolution!** 🚀

*Together, we're proving that simplicity and transparency beat abstraction and complexity.*