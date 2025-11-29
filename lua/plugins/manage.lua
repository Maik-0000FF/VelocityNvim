-- This script is only executed manually to manage plugins.
-- All plugins are treated as 'start' plugins and always loaded.

local M = {}

-- Safe fs_stat function for cross-version compatibility
local fs_stat_func = rawget(vim.uv, 'fs_stat') or rawget(vim.loop, 'fs_stat')

-- A simple list for all your plugins
M.plugins = {
  ["plenary.nvim"] = "https://github.com/nvim-lua/plenary.nvim",
  ["nvim-web-devicons"] = "https://github.com/nvim-tree/nvim-web-devicons",
  ["nui.nvim"] = "https://github.com/MunifTanjim/nui.nvim",
  ["mini.nvim"] = "https://github.com/echasnovski/mini.nvim",
  ["neo-tree.nvim"] = "https://github.com/nvim-neo-tree/neo-tree.nvim",
  ["tokyonight.nvim"] = "https://github.com/folke/tokyonight.nvim",
  ["which-key.nvim"] = "https://github.com/folke/which-key.nvim",
  ["alpha-nvim"] = "https://github.com/goolord/alpha-nvim",
  ["bufferline.nvim"] = "https://github.com/akinsho/bufferline.nvim",
  ["lualine.nvim"] = "https://github.com/nvim-lualine/lualine.nvim",
  ["noice.nvim"] = "https://github.com/folke/noice.nvim",
  ["nvim-notify"] = "https://github.com/rcarriga/nvim-notify",
  -- Ultra-performant Lua Development
  ["blink.cmp"] = "https://github.com/Saghen/blink.cmp",
  ["friendly-snippets"] = "https://github.com/rafamadriz/friendly-snippets",
  ["nvim-treesitter"] = "https://github.com/nvim-treesitter/nvim-treesitter",
  -- Ultra-fast Fuzzy Finder
  ["fzf-lua"] = "https://github.com/ibhagwan/fzf-lua",
  -- Ultra-fast Autoformatter
  ["conform.nvim"] = "https://github.com/stevearc/conform.nvim",
  -- Code-block Highlighting
  ["hlchunk.nvim"] = "https://github.com/shellRaining/hlchunk.nvim",
  -- Git Integration
  ["gitsigns.nvim"] = "https://github.com/lewis6991/gitsigns.nvim",
  -- Ultra-performant Window Picker (Pure Lua, <300 LoC)
  ["nvim-window-picker"] = "https://github.com/s1n7ax/nvim-window-picker",
  -- LSP File Operations for automatic import updates
  ["nvim-lsp-file-operations"] = "https://github.com/antosha417/nvim-lsp-file-operations",
  -- SudaWrite for sudo privileges when writing
  ["suda.vim"] = "https://github.com/lambdalisue/suda.vim",
  -- Hop for ultra-fast cursor navigation
  ["hop.nvim"] = "https://github.com/phaazon/hop.nvim",
  ["nvim-colorizer.lua"] = "https://github.com/NvChad/nvim-colorizer.lua",
  -- Ultra-performant Markdown Rendering (solves Treesitter performance issues)
  ["render-markdown.nvim"] = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  -- Startup Time Profiling and Benchmark Analysis
  ["vim-startuptime"] = "https://github.com/dstein64/vim-startuptime",
}

-- Automatic blink.cmp Rust compilation after updates
local function auto_build_blink_rust(pack_dir)
  local blink_path = pack_dir .. "blink.cmp"
  if fs_stat_func and fs_stat_func(blink_path .. "/Cargo.toml") then
    local icons = require("core.icons")
    print(icons.status.sync .. " Compiling blink.cmp Rust binaries...")

    -- Cross-platform script detection
    local config_path = vim.fn.stdpath("config") .. "/scripts/setup/"
    local script_name = "blink-cmp-rust-builder-linux.sh"

    -- macOS detection
    if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
      script_name = "blink-cmp-rust-builder-macos.sh"
    end

    local script_path = config_path .. script_name
    if fs_stat_func and fs_stat_func(script_path) then
      vim.fn.system({ "bash", script_path })
      print(icons.status.success .. " blink.cmp Rust performance enabled!")
    else
      print(icons.status.warn .. " Build script not found: " .. script_name)
    end
  end
end

-- Function for installing and updating

function M.sync()
  local pack_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/"
  -- Robuste Verzeichnisprüfung mit Fallback
  local dir_exists = false
  if fs_stat_func then
    local ok, stat = pcall(fs_stat_func, pack_dir)
    dir_exists = ok and stat and stat.type == "directory"
  else
    dir_exists = vim.fn.isdirectory(pack_dir) == 1
  end
  if not dir_exists then
    vim.fn.mkdir(pack_dir, "p") -- Creates directory if it doesn't exist
  end
  local icons = require("core.icons")
  print(icons.status.sync .. " Plugin synchronization starting...")

  local blink_updated = false
  for name, url in pairs(M.plugins) do
    local plugin_path = pack_dir .. name
    -- Robuste Plugin-Prüfung mit Fallback
    local plugin_exists = false
    if fs_stat_func then
      local ok, stat = pcall(fs_stat_func, plugin_path)
      plugin_exists = ok and stat and stat.type == "directory"
    else
      plugin_exists = vim.fn.isdirectory(plugin_path) == 1
    end

    if not plugin_exists then
      print("Installing " .. name .. "...")
      vim.fn.system({ "git", "clone", "--depth", "1", url, plugin_path })
      if name == "blink.cmp" then
        blink_updated = true
      end
    else
      print("Updating " .. name .. "...")
      vim.fn.system({ "git", "-C", plugin_path, "pull" })
      if name == "blink.cmp" then
        blink_updated = true
      end
    end
  end

  vim.cmd.packloadall() -- Optional, as 'start' plugins are automatically loaded on restart

  -- Automatic Rust compilation after blink.cmp updates
  if blink_updated then
    auto_build_blink_rust(pack_dir)
  end

  print(
    icons.status.success
      .. " Plugin synchronization complete! Restart Neovim to load new plugins."
  )
end

return M