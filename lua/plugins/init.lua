-- Native vim.pack Plugin Management

-- Function for safely loading modules (SILENT - only real errors)
local function safe_require(module)
  local ok, err = pcall(require, module)
  if not ok then
    -- Only report critical errors, no expected-not-found messages
    if not string.match(err, "module.*not found") then
      vim.notify("Critical error loading " .. module .. ": " .. err, vim.log.levels.ERROR)
    end
  end
  return ok
end

-- Load plugin configurations safely (Performance-optimized with defer-loading)

-- UI Plugins (immediately - for layout stability)
safe_require("plugins.ui.tokyonight") -- Theme first for consistent UI
safe_require("plugins.ui.bufferline") -- Bufferline immediately to avoid Alpha layout shift
safe_require("plugins.ui.lualine") -- Lualine immediately to avoid Alpha layout shift
safe_require("plugins.ui.alpha") -- Dashboard after bufferline+lualine for correct layout

-- Completion + Core Editor (sofort - for development)
safe_require("plugins.lsp.blink-cmp")
safe_require("plugins.editor.nvim-treesitter") -- Treesitter first for syntax
safe_require("plugins.editor.which-key") -- Which-key immediately for keybinding help
safe_require("plugins.editor.hop") -- Hop immediately for health check compatibility

-- Batch 1: Editor + LSP (50ms delay - optimiert for faster Startup)
vim.defer_fn(function()
  safe_require("plugins.ui.noice")
  safe_require("plugins.ui.nvim-colorizer")
  safe_require("plugins.lsp.native-lsp")
  safe_require("plugins.editor.neo-tree")
  safe_require("plugins.editor.lsp-file-operations")
  safe_require("plugins.editor.hlchunk")
  safe_require("plugins.editor.nvim-window-picker")
  safe_require("plugins.editor.mini-pairs")
  safe_require("plugins.editor.render-markdown")
end, 50)

-- Batch 2: Tools (100ms delay - optimiert for faster Startup)
vim.defer_fn(function()
  safe_require("plugins.lsp.lsp-debug")
  safe_require("plugins.tools.fzf-lua")
  safe_require("plugins.tools.conform")
  safe_require("plugins.tools.gitsigns")
  safe_require("plugins.tools.suda")
  safe_require("plugins.tools.vim-startuptime")

  -- Optional: Strudel (only load if enabled in optional features)
  local manage_ok, manage = pcall(require, "plugins.manage")
  if manage_ok and manage.is_feature_enabled("strudel") then
    safe_require("plugins.tools.strudel")
  end
end, 100)

-- PluginSync command is now handled in core/commands.lua

-- Optional: Bind :PluginSync to a key combination (e.g. <Leader>ps)
vim.keymap.set("n", "<Leader>ps", "<cmd>PluginSync<CR>", { noremap = true, silent = true })