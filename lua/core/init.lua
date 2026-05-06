-- ~/.config/VelocityNvim/lua/core/init.lua
-- Core Module Loader - Native Neovim Configuration

-- PERFORMANCE: Inline first-run check (avoids loading 580 lines on every start)
-- Check if plugins directory exists to detect first installation
local plugins_dir = vim.fn.stdpath("data") .. "/site/pack/user/start"
if vim.fn.isdirectory(plugins_dir) == 0 then
  -- First installation - load complete first-run system
  local first_run = require("core.first-run")

  if first_run.is_needed() then
    -- Abort early when Neovim is too old; nothing else will work and the
    -- installer can't bootstrap nvim itself.
    local version_ok, version_msg = first_run.assert_minimum_nvim_version()
    if not version_ok then
      if vim.env.VELOCITY_CI == "1" then
        io.stderr:write(version_msg)
        vim.cmd("cquit 1")
        return
      end
      vim.api.nvim_echo({ { version_msg, "ErrorMsg" } }, true, {})
      return
    end

    -- CI / unattended mode: run bash installer non-interactively, propagate exit code
    if vim.env.VELOCITY_CI == "1" then
      first_run.run_installation_ci()
      return
    end

    -- Interactive start: Show installation UI
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

-- Load base modules (order is important!)
require("core.options")    -- Basic settings
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