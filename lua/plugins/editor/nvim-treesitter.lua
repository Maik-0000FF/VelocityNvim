-- ~/.config/VelocityNvim/lua/plugins/nvim-treesitter.lua
-- Native Treesitter for Syntax Highlighting

-- Check if Treesitter is available (nvim-treesitter renamed 'configs' to 'config' in recent versions)
local ok, treesitter = pcall(require, "nvim-treesitter.config")
if not ok then
  -- Fallback for older versions
  ok, treesitter = pcall(require, "nvim-treesitter.configs")
  if not ok then
    print("Treesitter not available. Run :PluginSync and restart Neovim.")
    return
  end
end

-- SOLUTION: Set install directory BEFORE nvim-treesitter.install is loaded
vim.g.ts_install_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/nvim-treesitter/parser"

-- CRITICAL: Parser installation protection enabled

-- Parser installation configuration
local install = require("nvim-treesitter.install")
install.prefer_git = true
install.compilers = { "gcc", "clang" }

-- PERFORMANCE OPTIMIZATION: Cache buffer metadata to avoid repeated expensive checks
local buffer_metadata_cache = {}

-- Clear cache when buffer is deleted
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(event)
    buffer_metadata_cache[event.buf] = nil
  end
})

-- Clear entire cache on VimLeavePre (memory cleanup for long sessions)
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    buffer_metadata_cache = {}
  end
})

-- Optimized disable function with caching
local function should_disable_treesitter(lang, bufnr)
  -- Problematic file types - quick check first
  if lang == "csv" or lang == "log" or lang == "txt" then
    return true
  end

  -- Check cache first
  if buffer_metadata_cache[bufnr] ~= nil then
    return buffer_metadata_cache[bufnr]
  end

  -- Expensive checks only once per buffer
  local should_disable = false

  -- File size check (>1MB)
  local stat_ok, stats = pcall(vim.api.nvim_buf_call, bufnr, function()
    return vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
  end)
  if stat_ok and stats > 1024 * 1024 then
    should_disable = true
  end

  -- Line count check (>5k lines)
  if not should_disable then
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count > 5000 then
      should_disable = true
    end
  end

  -- Cache result
  buffer_metadata_cache[bufnr] = should_disable
  return should_disable
end

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
    -- Performance: Cached disable function
    disable = should_disable_treesitter,
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

-- Treesitter Folding (Neovim 0.11+ async API - 10x faster!)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- New async Lua API
vim.opt.foldlevel = 99 -- Always everything unfolded
vim.opt.foldlevelstart = 99 -- Always start with everything unfolded