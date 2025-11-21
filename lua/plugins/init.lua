-- Native vim.pack Plugin Management

-- Define Vim global for LSP
---@diagnostic disable-next-line: undefined-global
local vim = vim

-- Load manage.lua
local manage = require("plugins.manage")

-- Check for missing plugins (optimized with cached base path)
local required_plugins = vim.tbl_keys(manage.plugins)
local missing_plugins = {}
local pack_base = vim.fn.stdpath("data") .. "/site/pack/user/start/"
for _, plugin in ipairs(required_plugins) do
  if vim.fn.isdirectory(pack_base .. plugin) == 0 then
    table.insert(missing_plugins, plugin)
  end
end

-- Silent plugin check - only report on explicit request
-- if #missing_plugins > 0 then
--   print(
--     "Missing plugins: "
--       .. table.concat(missing_plugins, ", ")
--       .. ". Run :PluginSync to install them."
--   )
-- end

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

-- UI Plugins (Theme + Bufferline + Lualine + Alpha immediately for layout stability)
safe_require("plugins.ui.tokyonight") -- Theme first for consistent UI
safe_require("plugins.ui.bufferline") -- Bufferline immediately to avoid Alpha layout shift
safe_require("plugins.ui.lualine") -- Lualine immediately to avoid Alpha layout shift
safe_require("plugins.ui.alpha") -- Dashboard after bufferline+lualine for correct layout

vim.defer_fn(function()
  safe_require("plugins.ui.noice")
  safe_require("plugins.ui.nvim-colorizer")
end, 10) -- 10ms delay for other UI plugins

-- Editor Enhancement Plugins (Performance-staggered)
safe_require("plugins.editor.nvim-treesitter") -- Treesitter first for syntax
safe_require("plugins.editor.which-key") -- Which-key immediately for keybinding help

vim.defer_fn(function()
  -- Less critical editor plugins loaded later
  safe_require("plugins.editor.neo-tree")
  safe_require("plugins.editor.lsp-file-operations") -- LSP File Ops after Neo-tree
  safe_require("plugins.editor.hlchunk")
  safe_require("plugins.editor.nvim-window-picker")
  safe_require("plugins.editor.hop")
  safe_require("plugins.editor.mini-pairs")
  safe_require("plugins.editor.render-markdown") -- Markdown rendering for .md files
end, 50) -- 50ms delay for non-critical editor features

-- LSP & Completion (Immediate availability for development)
safe_require("plugins.lsp.blink-cmp")
-- LSP delayed for better startup performance
vim.defer_fn(function()
  safe_require("plugins.lsp.native-lsp")
end, 200) -- Load LSP after 200ms for better startup time

vim.defer_fn(function()
  -- LSP-Debug and tools loaded later
  safe_require("plugins.lsp.lsp-debug")

  -- Development Tools
  safe_require("plugins.tools.fzf-lua")
  safe_require("plugins.tools.conform")
  safe_require("plugins.tools.gitsigns")
  safe_require("plugins.tools.suda")
  safe_require("plugins.tools.vim-startuptime")
end, 100) -- 100ms delay for development tools

-- PluginSync command is now handled in core/commands.lua

-- Optional: Bind :PluginSync to a key combination (e.g. <Leader>ps)
vim.keymap.set("n", "<Leader>ps", "<cmd>PluginSync<CR>", { noremap = true, silent = true })