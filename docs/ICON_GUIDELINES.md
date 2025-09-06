# VelocityNvim Consumer Ready: Icon Usage Guidelines

## Overview

VelocityNvim uses **NerdFont icons exclusively** for consistent visual appearance across all terminals and systems. This guide shows how to properly use icons in code and avoid common pitfalls.

## ❌ **NEVER USE EMOJIS**

```lua
-- ❌ WRONG - Never use emojis in code
vim.notify("🚀 Build successful", vim.log.levels.INFO)
vim.notify("✅ Tests passed", vim.log.levels.INFO)
print("⚡ Performance optimized")
```

**Why not emojis?**
- Not all terminals support emojis
- Inconsistent rendering across systems  
- Performance overhead (runtime string processing)
- Not part of NerdFont standard

## ✅ **CORRECT: Use NerdFont Icons**

### Method 1: Direct Icon Reference (Recommended)

```lua
local icons = require("core.icons")

-- ✅ CORRECT - Direct icon usage
vim.notify(icons.status.rocket .. " Build successful", vim.log.levels.INFO)
vim.notify(icons.status.success .. " Tests passed", vim.log.levels.INFO) 
print(icons.misc.flash .. " Performance optimized")
```

### Method 2: Common Patterns (Recommended)

```lua
local icons = require("core.icons")

-- ✅ CORRECT - Direct usage with consistent patterns
vim.notify(icons.status.success .. " Build completed", vim.log.levels.INFO)
vim.notify(icons.misc.flash .. " Optimization applied", vim.log.levels.INFO)
vim.notify(icons.status.error .. " Build failed", vim.log.levels.ERROR)
vim.notify(icons.status.hint .. " System ready", vim.log.levels.INFO)
```

## Icon Categories & Usage

### 📊 **Status Icons**
```lua
local icons = require("core.icons")

icons.status.success    -- ✓ Success, completion, passed tests
icons.status.error      -- ✗ Errors, failures, critical issues  
icons.status.gear       -- ⚙ Settings, configuration, warnings
icons.status.hint       -- 💡 Information, tips, guidance
icons.status.rocket     -- 🚀 Progress, launching, building
icons.status.stats      -- 📊 Statistics, analytics, metrics
```

### 🔧 **Action Icons** 
```lua
icons.misc.flash        -- ⚡ Performance, speed, optimization
icons.misc.build        -- 🔨 Building, compiling, construction
icons.misc.search       -- 🔍 Searching, finding, filtering
icons.misc.folder       -- 📁 Files, directories, organization
icons.misc.star         -- ⭐ Important, featured, achievements
icons.misc.trend_up     -- 📈 Growth, improvement, progress
```

### 💻 **LSP/Development Icons**
```lua
icons.lsp.workspace     -- 🌍 Workspace, project, global scope
icons.lsp.references    -- 🎯 References, targeting, focus
icons.lsp.text          -- 📜 Documentation, text, content
icons.lsp.module        -- 📚 Modules, libraries, imports
```

## Common Usage Patterns

Direct usage with consistent patterns:

```lua
local icons = require("core.icons")

-- Status notifications
vim.notify(icons.status.success .. " Operation completed", vim.log.levels.INFO)
vim.notify(icons.status.error .. " Something went wrong", vim.log.levels.ERROR)  
vim.notify(icons.status.gear .. " Check configuration", vim.log.levels.WARN)
vim.notify(icons.status.hint .. " System information", vim.log.levels.INFO)

-- Action notifications  
vim.notify(icons.misc.flash .. " Speed improved", vim.log.levels.INFO)
vim.notify(icons.misc.build .. " Compilation started", vim.log.levels.INFO)
vim.notify(icons.misc.search .. " Found 5 matches", vim.log.levels.INFO)
vim.notify(icons.status.stats .. " Memory usage: 45MB", vim.log.levels.INFO)

-- Silent success (just print, no popup)
print(icons.status.success .. " Background task completed")

-- Conditional notifications
if debug_mode then
  vim.notify(icons.misc.flash .. " Debug info", vim.log.levels.DEBUG)
end
```

## Adding New Icons

### 1. **Check Existing Icons First**
Always verify if a suitable icon already exists in `lua/core/icons.lua`:

```bash
# Search for existing icons
grep -r "your_use_case" ~/.config/VelocityNvim/lua/core/icons.lua
```

### 2. **Adding to Icon Registry**
If you need a new icon, add it to the appropriate category in `lua/core/icons.lua`:

```lua
-- In lua/core/icons.lua
M.status = {
  success = "",      -- Existing
  error = "",        -- Existing  
  new_status = "",   -- Your new icon
}

M.misc = {
  flash = "",        -- Existing
  your_icon = "",    -- Your new icon
}
```

### 3. **Update Template Functions** 
Add corresponding template function in `lua/utils/notifications.lua`:

```lua
--- Your new notification type
function M.your_type(message, opts)
  opts = opts or {}
  vim.notify(icons.status.your_icon .. " " .. message, vim.log.levels.INFO, opts)
end
```

## Performance Best Practices

### ✅ **DO**
- Cache icon references in local variables for frequent use
- Use template functions for consistency  
- Follow the "minimal notifications" principle (CLAUDE.md)
- Use DEBUG level for progress/internal notifications

### ❌ **DON'T**
- Never use emojis in code
- Don't create runtime string processing
- Avoid excessive INFO level notifications for routine operations
- Don't bypass the icon system with direct Unicode

### Performance Example:
```lua
-- ✅ GOOD - Cache icons for frequent use
local icons = require("core.icons")
local success_icon = icons.status.success
local error_icon = icons.status.error

for i = 1, 1000 do
  if condition then
    vim.notify(success_icon .. " Item " .. i .. " processed", vim.log.levels.DEBUG)
  else
    vim.notify(error_icon .. " Item " .. i .. " failed", vim.log.levels.ERROR)
  end
end

-- ❌ BAD - Repeated require calls
for i = 1, 1000 do
  local icons = require("core.icons")  -- Inefficient!
  vim.notify(icons.status.success .. " Item " .. i, vim.log.levels.INFO)
end
```

## Troubleshooting

### Icons Not Showing
1. **Check NerdFont Installation**:
   ```bash
   # Test NerdFont availability
   echo -e "\ue0b0 \uf00a \uf7f0"  # Should show three icons
   ```

2. **Verify Icon Module**:
   ```lua
   -- In Neovim command line
   :lua print(require("core.icons").status.success)  -- Should print an icon
   ```

3. **Check Terminal Compatibility**:
   - WezTerm: ✅ Full support
   - Alacritty: ✅ Full support  
   - Terminal.app: ⚠️ Partial support
   - TTY: ❌ No support (fallback to ASCII)

### Migration from Emojis

If you have existing code with emojis, use the cleanup script:

```bash
# Run the emoji cleanup script
lua ~/.config/VelocityNvim/scripts/emoji-cleanup.lua
```

## Examples from VelocityNvim

### Health Check System
```lua
local icons = require("core.icons")

-- Status reporting
vim.notify(icons.status.success .. " All systems operational", vim.log.levels.INFO)
vim.notify(icons.status.error .. " LSP server not found", vim.log.levels.ERROR)
vim.notify(icons.status.gear .. " Fallback mode active", vim.log.levels.WARN)
```

### Performance System  
```lua
local notify = require("utils.notifications")

-- Using templates for consistency
notify.performance("Cursor optimization active")
notify.stats("Memory usage optimized: -25%") 
notify.build("Rust binaries compiled successfully")
```

### Plugin Integration
```lua
local icons = require("core.icons")

-- LSP notifications
vim.notify(icons.lsp.workspace .. " Workspace loaded: " .. workspace_name, vim.log.levels.INFO)
vim.notify(icons.lsp.references .. " Found " .. count .. " references", vim.log.levels.INFO)

-- Git integration  
vim.notify(icons.misc.search .. " Delta renderer available", vim.log.levels.INFO)
vim.notify(icons.status.success .. " Git hooks installed", vim.log.levels.INFO)
```

---

**Remember**: Icons make VelocityNvim look professional and consistent. Always prefer NerdFont icons over emojis for the best consumer experience!