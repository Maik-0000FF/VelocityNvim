-- ~/.config/VelocityNvim/lua/core/init.lua
-- Core Module Loader - Native Neovim Configuration

-- PERFORMANCE: Inline first-run check (vermeidet 580-Zeilen-Load bei jedem Start)
-- Prüfe direkt ob Version-Datei existiert, statt first-run.lua zu laden
local version_file = vim.fn.stdpath("data") .. "/velocitynvim_version"
if vim.fn.filereadable(version_file) == 0 then
  -- Erste Installation - lade vollständiges first-run System
  local first_run = require("core.first-run")

  -- Interaktiver Start: Zeige Installation UI
  if first_run.is_needed() then
    first_run.run_installation()
    return  -- Exit early - installation will reload config when complete
  end

  -- Headless/script mode mit fehlenden Plugins: Warnung
  if not first_run.quick_check() then
    vim.notify("VelocityNvim: First-run installation required. Start interactively.", vim.log.levels.WARN)
    return
  end
end
-- Normaler Start - first-run.lua wurde NICHT geladen (~2.2ms gespart)

-- Version-System initialisieren (nach first-run check)
local version = require("core.version")
version.init()

-- Lade Basis-Module (Reihenfolge wichtig!)
require("core.options")    -- Grundlegende Einstellungen

-- ULTIMATE Performance System (nach options, vor plugins)
require("core.performance").setup()

require("core.keymaps")    -- Tastenkürzel
require("core.autocmds")   -- Event-Handler
require("core.commands")   -- Benutzerbefehle

-- Lade Plugins (nach Core-Setup)
require("plugins")

-- Terminal-Utilities initialisieren (nach Plugins für Icons)
vim.defer_fn(function()
  local utils = require("utils")
  utils.terminal().setup()
end, 100)