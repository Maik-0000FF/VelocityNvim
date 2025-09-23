-- Native vim.pack Plugin Management

-- Vim global für LSP definieren
---@diagnostic disable-next-line: undefined-global
local vim = vim

-- Lade manage.lua
local manage = require("plugins.manage")

-- Prüfe auf fehlende Plugins
local required_plugins = vim.tbl_keys(manage.plugins)
local missing_plugins = {}
for _, plugin in ipairs(required_plugins) do
  local pack_path = vim.fn.stdpath("data") .. "/site/pack/user/start/" .. plugin

  if vim.fn.isdirectory(pack_path) == 0 then
    table.insert(missing_plugins, plugin)
  end
end

-- Silent plugin check - nur bei expliziter Anfrage melden
-- if #missing_plugins > 0 then
--   print(
--     "Folgende Plugins fehlen: "
--       .. table.concat(missing_plugins, ", ")
--       .. ". Führe :PluginSync aus, um sie zu installieren."
--   )
-- end

-- Funktion zum sicheren Laden von Modulen (SILENT - nur echte Fehler)
local function safe_require(module)
  local ok, err = pcall(require, module)
  if not ok then
    -- Nur kritische Fehler melden, keine Expected-Not-Found Meldungen
    if not string.match(err, "module.*not found") then
      vim.notify("Critical error loading " .. module .. ": " .. err, vim.log.levels.ERROR)
    end
  end
  return ok
end

-- Lade Plugin-Konfigurationen sicher (Performance-optimiert mit Defer-Loading)

-- UI Plugins (Theme + Bufferline + Lualine + Alpha sofort für layout stability)
safe_require("plugins.ui.tokyonight") -- Theme zuerst für konsistente UI
safe_require("plugins.ui.bufferline") -- Bufferline sofort um Alpha-Layout-Shift zu vermeiden
safe_require("plugins.ui.lualine") -- Lualine sofort um Alpha-Layout-Shift zu vermeiden
safe_require("plugins.ui.alpha") -- Dashboard nach bufferline+lualine für korrektes Layout

vim.defer_fn(function()
  safe_require("plugins.ui.noice")
  safe_require("plugins.ui.nvim-colorizer")
end, 10) -- 10ms delay für andere UI-Plugins

-- Editor Enhancement Plugins (Performance-gestaffelt)
safe_require("plugins.editor.nvim-treesitter") -- Treesitter zuerst für Syntax
safe_require("plugins.editor.which-key") -- Which-key sofort für Keybinding-Hilfe

vim.defer_fn(function()
  -- Weniger kritische Editor-Plugins nachgeladen
  safe_require("plugins.editor.neo-tree")
  safe_require("plugins.editor.hlchunk")
  safe_require("plugins.editor.nvim-window-picker")
  safe_require("plugins.editor.hop")
  safe_require("plugins.editor.german-chars")
  safe_require("plugins.editor.mini-pairs")
  safe_require("plugins.editor.render-markdown") -- Markdown-rendering für .md Dateien
end, 50) -- 50ms delay für non-kritische Editor-Features

-- LSP & Completion (Sofortige Verfügbarkeit für Entwicklung)
safe_require("plugins.lsp.blink-cmp")
-- LSP delayed für bessere Startup-Performance
vim.defer_fn(function()
  safe_require("plugins.lsp.native-lsp")
end, 200) -- LSP nach 200ms laden für bessere Startup-Zeit

vim.defer_fn(function()
  -- LSP-Debug und Tools nachgeladen
  safe_require("plugins.lsp.lsp-debug")

  -- Development Tools
  safe_require("plugins.tools.fzf-lua")
  safe_require("plugins.tools.conform")
  safe_require("plugins.tools.gitsigns")
  safe_require("plugins.tools.suda")
end, 100) -- 100ms delay für development tools

-- PluginSync Command wird jetzt in core/commands.lua behandelt

-- Optional: Binde :PluginSync an eine Tastenkombination (z. B. <Leader>ps)
vim.keymap.set("n", "<Leader>ps", "<cmd>PluginSync<CR>", { noremap = true, silent = true })