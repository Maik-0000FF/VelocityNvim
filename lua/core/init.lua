-- ~/.config/VelocityNvim/lua/core/init.lua
-- Core Module Loader - Native Neovim Configuration

-- First-Run Installation Check (MUST be absolute first)
local first_run = require("core.first-run")
if first_run.is_needed() then
  -- Run interactive installation on first start
  first_run.run_installation()
  return  -- Exit early - installation will reload config when complete
elseif not first_run.quick_check() then
  -- Headless/script mode - plugins missing
  vim.notify("VelocityNvim: First-run installation required. Start interactively.", vim.log.levels.WARN)
  return
end

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