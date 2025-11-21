-- ~/.config/VelocityNvim/lua/plugins/nvim-treesitter.lua
-- Native Treesitter for Syntax Highlighting

-- Check if Treesitter is available
local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not ok then
  print("Treesitter not available. Run :PluginSync and restart Neovim.")
  return
end

-- SOLUTION: Set install directory BEFORE nvim-treesitter.install is loaded
vim.g.ts_install_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/nvim-treesitter/parser"

-- CRITICAL: Parser installation protection enabled

-- Parser installation configuration
local install = require("nvim-treesitter.install")
install.prefer_git = true
install.compilers = { "gcc", "clang" }

treesitter.setup({
  -- Manual parser installation - no automatic installation
  ensure_installed = {},
  auto_install = false,
  sync_install = false,
  ignore_install = {},
  modules = {},

  -- Syntax Highlighting
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    -- Performance: More aggressive disabling for smoother cursor movement
    disable = function(lang, bufnr)
      -- Disable for problematic file types
      if lang == "csv" or lang == "log" or lang == "txt" then
        return true
      end
      -- Performance: Smaller limit for better responsiveness (>1MB instead of 10MB)
      local stat_ok, stats = pcall(vim.api.nvim_buf_call, bufnr, function()
        return vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
      end)
      if stat_ok and stats > 1024 * 1024 then -- 1MB instead of 10MB
        return true
      end
      -- Performance: Line-based disabling for long files
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      if line_count > 5000 then -- >5k lines = disable treesitter
        return true
      end
      return false
    end,
    -- Performance: Syntax updates only when needed
    use_languagetree = true,
  },

  -- Indentation
  indent = {
    enable = true,
  },

  -- Incremental Selection
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },

  -- Textobjects (basic)
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
})

-- Treesitter Folding (better code structure) - ALWAYS everything unfolded
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 -- Always everything unfolded
vim.opt.foldlevelstart = 99 -- Always start with everything unfolded