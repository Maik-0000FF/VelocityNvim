-- ~/.config/VelocityNvim/lua/core/commands/system.lua
-- System info, health, testing, notifications, and performance commands

local cmd = vim.api.nvim_create_user_command
local icons = require("core.icons")

-- Notification History Commands
cmd("NotifyHistory", function()
  vim.cmd("Noice history")
end, {
  desc = "Show notification history (all messages)",
})

cmd("NotifyLast", function()
  vim.cmd("Noice last")
end, {
  desc = "Show last notification",
})

cmd("NotifyErrors", function()
  vim.cmd("Noice errors")
end, {
  desc = "Show error messages",
})

cmd("NotifyDismiss", function()
  vim.cmd("Noice dismiss")
end, {
  desc = "Dismiss all notifications",
})

-- ULTIMATE Performance Commands
cmd("UltimatePerformanceToggle", function()
  require("core.performance").toggle()
end, {
  desc = "Toggle ULTIMATE Performance Mode for cursor navigation",
})

cmd("UltimatePerformanceStatus", function()
  local perf = require("core.performance")
  local status = perf.status()

  print(icons.status.rocket .. " VelocityNvim Performance Status")
  print(
    "  Ultra Mode: "
      .. (
        status.ultra_active and (icons.status.success .. " ACTIVE")
        or (icons.status.info .. " STANDBY")
      )
  )

  if status.ultra_active then
    print(
      "  "
        .. icons.status.gear
        .. " Performance Boost: "
        .. status.updatetime
        .. "ms (boosted from "
        .. (status.original_updatetime or "unknown")
        .. "ms)"
    )
  else
    print("  " .. icons.status.gear .. " Normal Mode: " .. status.updatetime .. "ms")
    print(
      "  " .. icons.status.hint .. " Ultra Mode activates automatically during cursor navigation"
    )
  end

  print("  " .. icons.status.info .. " Use :UltimatePerformanceToggle to test manual activation")
end, {
  desc = "Show ULTIMATE Performance Mode status with detailed explanation",
})

-- System Commands
cmd("VelocityInfo", function()
  print(icons.status.rocket .. " VelocityNvim Native Configuration")

  -- Neovim version
  local nvim_ver = vim.version()
  print("\n" .. icons.status.info .. " Neovim Information:")
  print("  Version: " .. nvim_ver.major .. "." .. nvim_ver.minor .. "." .. nvim_ver.patch)
  if vim.api.nvim__api_info then
    local ok, api_info = pcall(vim.api.nvim__api_info)
    if ok and api_info then
      print("  API Level: " .. api_info.api_level)
    end
  end

  -- System paths
  print("\n" .. icons.status.folder .. " System Information:")
  local config_path = vim.fn.stdpath("config")
  local data_path = vim.fn.stdpath("data")
  print("  " .. icons.status.folder .. " Config Path: " .. config_path)
  print("  " .. icons.status.folder .. " Data Path: " .. data_path)
  print("  " .. icons.status.colorscheme .. " Colorscheme: " .. (vim.g.colors_name or "default"))
  local leader_display = vim.g.mapleader == " " and "<Space>" or vim.g.mapleader
  print("  " .. icons.status.gear .. " Leader Key: " .. leader_display)

  -- Plugin count
  local manage = require("plugins.manage")
  local core_plugin_count = vim.tbl_count(manage.plugins)
  local all_plugin_count = vim.tbl_count(manage.get_all_plugins())
  print("  " .. icons.misc.plugin .. " Core Plugins: " .. core_plugin_count)
  if all_plugin_count > core_plugin_count then
    print("  " .. icons.misc.plugin .. " Total Plugins (with optional): " .. all_plugin_count)
  end

  -- Optional packages
  local config = manage.load_optional_config()
  if config.selected and #config.selected > 0 then
    print("  " .. icons.status.gear .. " Optional Packages: " .. table.concat(config.selected, ", "))
  end

  -- LSP count
  local lsp_clients = vim.lsp.get_clients()
  print("  " .. icons.status.gear .. " Active LSP Clients: " .. #lsp_clients)
end, {
  desc = "Show VelocityNvim system information",
})

cmd("VelocityMigrations", function()
  local migrations = require("core.migrations")
  migrations.print_migration_history()
end, {
  desc = "Show migration history and changes",
})

cmd("VelocityBackup", function()
  local migrations = require("core.migrations")
  local backup_path = migrations.backup_config()
  if backup_path then
    print(icons.status.success .. " Configuration backed up to: " .. backup_path)
  end
end, {
  desc = "Backup current configuration",
})

cmd("VelocityResetVersion", function()
  local choice = vim.fn.confirm(
    "Reset version tracking? Next restart will show as fresh install.",
    "&Yes\n&No",
    2
  )
  if choice == 1 then
    local migrations = require("core.migrations")
    migrations.reset_version_tracking()
  end
end, {
  desc = "Reset version tracking (for testing)",
})

cmd("VelocityHealth", function()
  vim.api.nvim_command("checkhealth velocitynvim")
end, {
  desc = "Run VelocityNvim health check",
})

-- Test Suite Commands
cmd("VelocityTest", function(opts)
  local test_runner = require("tests.run_tests")
  local test_type = opts.args or "all"

  if test_type == "health" then
    test_runner.health_check()
  elseif test_type == "unit" then
    test_runner.run_unit_tests()
  elseif test_type == "performance" then
    test_runner.run_performance_tests()
  elseif test_type == "integration" then
    test_runner.run_integration_tests()
  else
    test_runner.run_all()
  end
end, {
  nargs = "?",
  complete = function()
    return { "all", "health", "unit", "performance", "integration" }
  end,
  desc = "Run VelocityNvim automated test suite",
})

-- Load system dependency manager (provides :SystemDeps, :SystemDepsInstall, :SystemDepsScript)
-- Deferred to not block startup measurement, but still eager-loaded
vim.defer_fn(function()
  pcall(require, "core.system-deps")
end, 150)  -- After Phase 3 plugins (100ms)
