-- ~/.config/VelocityNvim/lua/core/init.lua
-- Core Module Loader - Native Neovim Configuration

-- PERFORMANCE: Inline first-run check (avoids loading 580 lines on every start)
-- Check directly if version file exists instead of loading first-run.lua
local version_file = vim.fn.stdpath("data") .. "/velocitynvim_version"
if vim.fn.filereadable(version_file) == 0 then
  -- First installation - load complete first-run system
  local first_run = require("core.first-run")

  -- Interactive start: Show installation UI
  if first_run.is_needed() then
    first_run.run_installation()
    return  -- Exit early - installation will reload config when complete
  end

  -- Headless/script mode with missing plugins: Warning
  if not first_run.quick_check() then
    vim.notify("VelocityNvim: First-run installation required. Start interactively.", vim.log.levels.WARN)
    return
  end
end
-- Normal start - first-run.lua was NOT loaded (~2.2ms saved)

-- Initialize version system (after first-run check)
local version = require("core.version")
version.init()

-- Load base modules (order is important!)
require("core.options")    -- Basic settings

-- ULTIMATE Performance System (after options, before plugins)
require("core.performance").setup()

require("core.keymaps")    -- Keybindings
require("core.autocmds")   -- Event handlers
require("core.commands")   -- User commands

-- Load plugins (after core setup)
require("plugins")

-- Initialize terminal utilities (after plugins for icons)
vim.defer_fn(function()
  local utils = require("utils")
  utils.terminal().setup()
end, 100)