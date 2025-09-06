# VelocityNvim Hybrid Formatter Configuration

## Overview

VelocityNvim uses a hybrid formatter system combining **Biome** (ultra-fast Rust-based) and **Prettier** (comprehensive language support) for optimal performance and complete language coverage.

## Performance Benefits

- **JS/TS/JSON/CSS**: ~20x faster with Biome
- **Vue/Svelte/Markdown/YAML/HTML**: Same speed with Prettier
- **Overall**: ~15x faster for typical web development projects

## Conform.lua Configuration

Update your `lua/plugins/tools/conform.lua` to use the hybrid system:

```lua
-- ~/.config/VelocityNvim/lua/plugins/tools/conform.lua
-- Hybrid Performance Formatter System

require("conform").setup({
  -- Formatter per file type (Performance Optimized)
  formatters_by_ft = {
    -- Lua
    lua = { "stylua" },

    -- Python (Ruff does everything: format + imports + lint)
    python = { "ruff_organize_imports", "ruff_format" },

    -- JavaScript/TypeScript (Ultra-fast with Biome)
    javascript = { "biome" },
    typescript = { "biome" },
    javascriptreact = { "biome" },
    typescriptreact = { "biome" },

    -- JSON/CSS (Ultra-fast with Biome)
    json = { "biome" },
    jsonc = { "biome" },
    css = { "biome" },
    scss = { "biome" },  -- Note: Biome CSS support includes SCSS

    -- Fallback to Prettier for unsupported languages
    html = { "prettier" },
    vue = { "prettier" },
    svelte = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
    less = { "prettier" },

    -- Shell scripts
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    fish = { "fish_indent" },

    -- Other languages
    toml = { "taplo" },
    xml = { "xmlformat" },
    sql = { "sqlformat" },
    go = { "goimports", "gofmt" },
    rust = { "rustfmt" },
    c = { "clang-format" },
    cpp = { "clang-format" },
  },

  -- Custom formatter definitions
  formatters = {
    -- Biome configuration (optimized for speed)
    biome = {
      command = "biome",
      args = { "format", "--stdin-file-path", "$FILENAME" },
      stdin = true,
    },

    -- Ruff formatters (Python)
    ruff_format = {
      command = "ruff",
      args = { "format", "--line-length=88", "--stdin-filename", "$FILENAME", "-" },
      stdin = true,
    },
    ruff_organize_imports = {
      command = "ruff",
      args = { "check", "--select=I", "--fix", "--stdin-filename", "$FILENAME", "-" },
      stdin = true,
    },

    -- Taplo for TOML
    taplo = {
      command = "taplo",
      args = { "format", "-" },
      stdin = true,
    },
  },

  -- Format on save configuration
  format_on_save = {
    timeout_ms = 2000,
    lsp_fallback = true,
  },

  -- Notify on format errors
  notify_on_error = true,

  -- Log level (for debugging)
  log_level = vim.log.levels.ERROR,
})

-- Performance monitoring (optional)
vim.api.nvim_create_user_command("FormatBenchmark", function()
  local start_time = vim.fn.reltime()
  require("conform").format({ bufnr = 0 })
  local elapsed = vim.fn.reltimestr(vim.fn.reltime(start_time))
  vim.notify("Format completed in " .. elapsed .. "s", vim.log.levels.INFO)
end, {})
```

## Installation Verification

After running the dependency installer, verify both formatters are available:

```bash
# Check Biome installation
biome --version

# Check Prettier installation (fallback)
prettier --version

# Check Ruff (Python)
ruff --version

# Test Biome performance
echo 'const x={a:1,b:2}' | biome format --stdin-file-path=test.js
```

## Language Support Matrix

| Language   | Formatter | Performance       | Notes                |
| ---------- | --------- | ----------------- | -------------------- |
| JavaScript | Biome     | 🚀 20x faster     | Rust-based           |
| TypeScript | Biome     | 🚀 20x faster     | Rust-based           |
| JSX/TSX    | Biome     | 🚀 20x faster     | Rust-based           |
| JSON       | Biome     | 🚀 20x faster     | Rust-based           |
| CSS        | Biome     | 🚀 20x faster     | Rust-based           |
| Vue        | Prettier  | ⚡ Standard       | Full feature support |
| Svelte     | Prettier  | ⚡ Standard       | Full feature support |
| Markdown   | Prettier  | ⚡ Standard       | Full feature support |
| YAML       | Prettier  | ⚡ Standard       | Full feature support |
| HTML       | Prettier  | ⚡ Standard       | Full feature support |
| Python     | Ruff      | 🚀 10-100x faster | Rust-based           |
| Lua        | StyLua    | 🚀 Fast           | Rust-based           |
| TOML       | Taplo     | 🚀 Fast           | Rust-based           |

## Troubleshooting

### Biome not found

```bash
# Install via package manager
sudo pacman -S biome

# Or via npm (if package not available)
npm install -g @biomejs/biome
```

### Prettier fallback not working

```bash
# Ensure prettier is installed
sudo pacman -S prettier
```

### Python formatting issues

```bash
# Ruff should handle everything
pip install --user ruff

# Check ruff configuration
ruff check --select=I  # Import sorting
ruff format           # Code formatting
```

## Migration from Pure Prettier

If migrating from a pure Prettier setup:

1. **Backup current configuration**
2. **Install Biome**: `sudo pacman -S biome`
3. **Update conform.lua** with the hybrid configuration above
4. **Test formatting** on a JavaScript file to verify Biome works
5. **Keep Prettier** for unsupported file types

## Performance Tips

- **Use Biome first** for supported languages (JS/TS/JSON/CSS)
- **Prettier remains** for comprehensive language support
- **Ruff replaces** black + isort for Python (single tool, much faster)
- **Consider file size** - Biome shines with larger files where the performance difference is most noticeable

