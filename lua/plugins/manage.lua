-- Dieses Skript wird nur manuell ausgeführt, um Plugins zu verwalten.
-- Alle Plugins werden als 'start'-Plugins behandelt und immer geladen.

local M = {}

-- Sichere fs_stat Funktion für Cross-Version Kompatibilität
local fs_stat_func = rawget(vim.uv, 'fs_stat') or rawget(vim.loop, 'fs_stat')

-- Eine einfache Liste für alle deine Plugins
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
  -- Ultra-performante Lua Development
  ["blink.cmp"] = "https://github.com/Saghen/blink.cmp",
  ["friendly-snippets"] = "https://github.com/rafamadriz/friendly-snippets",
  ["nvim-treesitter"] = "https://github.com/nvim-treesitter/nvim-treesitter",
  -- Ultra-schneller Fuzzy Finder
  ["fzf-lua"] = "https://github.com/ibhagwan/fzf-lua",
  -- Ultra-schneller Autoformatter
  ["conform.nvim"] = "https://github.com/stevearc/conform.nvim",
  -- Code-Block Highlighting
  ["hlchunk.nvim"] = "https://github.com/shellRaining/hlchunk.nvim",
  -- Git Integration
  ["gitsigns.nvim"] = "https://github.com/lewis6991/gitsigns.nvim",
  -- Ultra-performanter Window Picker (Pure Lua, <300 LoC)
  ["nvim-window-picker"] = "https://github.com/s1n7ax/nvim-window-picker",
  -- SudaWrite für Sudo-Berechtigungen beim Schreiben
  ["suda.vim"] = "https://github.com/lambdalisue/suda.vim",
  -- Hop für ultra-schnelle Cursor-Navigation
  ["hop.nvim"] = "https://github.com/phaazon/hop.nvim",
  ["nvim-colorizer.lua"] = "https://github.com/norcalli/nvim-colorizer.lua",
  -- Ultra-performantes Markdown Rendering (löst Treesitter Performance-Probleme)
  ["render-markdown.nvim"] = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
}

-- Funktion zum Installieren und Aktualisieren

function M.sync()
  local pack_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/"
  if not (fs_stat_func and fs_stat_func(pack_dir)) then
    vim.fn.mkdir(pack_dir, "p") -- Erstellt den Ordner, falls er nicht existiert
  end
  local icons = require("core.icons")
  print(icons.status.sync .. " Plugin-Synchronisation wird gestartet...")
  for name, url in pairs(M.plugins) do
    local plugin_path = pack_dir .. name
    if not (fs_stat_func and fs_stat_func(plugin_path)) then
      print("Installiere " .. name .. "...")
      vim.fn.system({ "git", "clone", "--depth", "1", url, plugin_path })
    else
      print("Aktualisiere " .. name .. "...")
      vim.fn.system({ "git", "-C", plugin_path, "pull" })
    end
  end
  vim.cmd.packloadall() -- Optional, da 'start'-Plugins beim Neustart automatisch geladen werden
  print(
    icons.status.success
      .. " Plugin-Synchronisation abgeschlossen! Starte Neovim neu, um neue Plugins zu laden."
  )
end

return M