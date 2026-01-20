-- ~/.config/VelocityNvim/lua/plugins/nvim-treesitter.lua
-- Native Treesitter for Syntax Highlighting

-- Check if Treesitter is available
local ok, treesitter = pcall(require, "nvim-treesitter.config")
if not ok then
  vim.notify("Treesitter not available. Run :PluginSync and restart Neovim.", vim.log.levels.WARN)
  return
end

-- Parsers are installed to stdpath("data")/site/parser/ by default

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

-- Core parsers to install automatically on first start
local core_parsers = {
  "lua", "vim", "vimdoc", "markdown", "markdown_inline",
  "python", "javascript", "typescript", "html", "css",
  "json", "bash", "rust", "toml", "yaml"
}

treesitter.setup({
  -- Auto-install core parsers on first start (works with UI, not headless)
  ensure_installed = core_parsers,
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

-- Auto-install missing parsers on first start (runs once, minimal overhead)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
    local missing = {}

    for _, parser in ipairs(core_parsers) do
      local parser_file = parser_dir .. "/" .. parser .. ".so"
      if vim.fn.filereadable(parser_file) == 0 then
        -- Also check Neovim's built-in parsers
        local builtin = vim.fn.globpath(vim.o.runtimepath, "parser/" .. parser .. ".so", false, true)
        if #builtin == 0 then
          table.insert(missing, parser)
        end
      end
    end

    if #missing > 0 then
      vim.notify(
        "Installing " .. #missing .. " Treesitter parsers: " .. table.concat(missing, ", "),
        vim.log.levels.INFO
      )
      vim.schedule(function()
        for _, parser in ipairs(missing) do
          vim.cmd("TSInstall " .. parser)
        end
      end)
    end
  end,
  once = true,
})