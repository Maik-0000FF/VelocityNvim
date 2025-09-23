-- ~/.config/VelocityNvim/lua/plugins/nvim-treesitter.lua
-- Native Treesitter für Syntax Highlighting

-- Prüfe ob Treesitter verfügbar ist
local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not ok then
  print("Treesitter nicht verfügbar. Führe :PluginSync aus und starte Neovim neu.")
  return
end

-- LÖSUNG: Setze Install-Directory BEVOR nvim-treesitter.install geladen wird
vim.g.ts_install_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/nvim-treesitter/parser"

-- KRITISCH: Parser Installation Schutz aktiviert

-- Parser Installation Konfiguration
local install = require("nvim-treesitter.install")
install.prefer_git = true
install.compilers = { "gcc", "clang" }

treesitter.setup({
  -- Manuelle Parser-Installation - keine automatische Installation
  ensure_installed = {},
  auto_install = false,
  sync_install = false,
  ignore_install = {},
  modules = {},

  -- Syntax Highlighting
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    -- Performance: Aggressiveres Disabling für flüssigere Cursor-Bewegungen
    disable = function(lang, bufnr)
      -- Deaktiviere für problematische Dateitypen
      if lang == "csv" or lang == "log" or lang == "txt" then
        return true
      end
      -- Performance: Kleinere Grenze für bessere Responsivität (>1MB statt 10MB)
      local stat_ok, stats = pcall(vim.api.nvim_buf_call, bufnr, function()
        return vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
      end)
      if stat_ok and stats > 1024 * 1024 then -- 1MB statt 10MB
        return true
      end
      -- Performance: Zeilen-basiertes Disabling für lange Dateien
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      if line_count > 5000 then -- >5k Zeilen = disable treesitter
        return true
      end
      return false
    end,
    -- Performance: Syntax-Updates nur wenn nötig
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

-- Treesitter Folding (bessere Code-Struktur) - IMMER alles aufgeklappt
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 -- Immer alles aufgeklappt
vim.opt.foldlevelstart = 99 -- Start immer mit allem aufgeklappt