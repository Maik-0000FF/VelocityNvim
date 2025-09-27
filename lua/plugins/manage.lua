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

-- Automatische blink.cmp Rust-Kompilierung nach Updates
local function auto_build_blink_rust(pack_dir)
  local blink_path = pack_dir .. "blink.cmp"
  if fs_stat_func and fs_stat_func(blink_path .. "/Cargo.toml") then
    local icons = require("core.icons")
    print(icons.status.sync .. " Kompiliere blink.cmp Rust-Binaries...")

    -- Cross-Platform Script Detection
    local config_path = vim.fn.stdpath("config") .. "/scripts/setup/"
    local script_name = "blink-cmp-rust-builder-linux.sh"

    -- macOS Detection
    if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
      script_name = "blink-cmp-rust-builder-macos.sh"
    end

    local script_path = config_path .. script_name
    if fs_stat_func and fs_stat_func(script_path) then
      vim.fn.system({ "bash", script_path })
      print(icons.status.success .. " blink.cmp Rust-Performance aktiviert!")
    else
      print(icons.status.warn .. " Build-Script nicht gefunden: " .. script_name)
    end
  end
end

-- Funktion zum Installieren und Aktualisieren

function M.sync()
  local pack_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/"
  if not (fs_stat_func and fs_stat_func(pack_dir)) then
    vim.fn.mkdir(pack_dir, "p") -- Erstellt den Ordner, falls er nicht existiert
  end
  local icons = require("core.icons")
  print(icons.status.sync .. " Plugin-Synchronisation wird gestartet...")

  local blink_updated = false
  for name, url in pairs(M.plugins) do
    local plugin_path = pack_dir .. name
    if not (fs_stat_func and fs_stat_func(plugin_path)) then
      print("Installiere " .. name .. "...")
      vim.fn.system({ "git", "clone", "--depth", "1", url, plugin_path })
      if name == "blink.cmp" then
        blink_updated = true
      end
    else
      print("Aktualisiere " .. name .. "...")
      vim.fn.system({ "git", "-C", plugin_path, "pull" })
      if name == "blink.cmp" then
        blink_updated = true
      end
    end
  end

  vim.cmd.packloadall() -- Optional, da 'start'-Plugins beim Neustart automatisch geladen werden

  -- Automatische Rust-Kompilierung nach blink.cmp Updates
  if blink_updated then
    auto_build_blink_rust(pack_dir)
  end

  print(
    icons.status.success
      .. " Plugin-Synchronisation abgeschlossen! Starte Neovim neu, um neue Plugins zu laden."
  )
end

return M