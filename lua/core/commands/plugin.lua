-- ~/.config/VelocityNvim/lua/core/commands/plugin.lua
-- Plugin management and optional packages commands

local cmd = vim.api.nvim_create_user_command
local icons = require("core.icons")

-- Plugin Management Commands
cmd("PluginSync", function()
  require("plugins.manage").sync()
end, {
  desc = "Synchronize all plugins",
})

-- First-Run Installation Commands
cmd("VelocityFirstRun", function()
  local first_run = require("core.first-run")
  if first_run.is_needed() then
    first_run.run_installation()
  else
    vim.notify(icons.status.info .. " VelocityNvim is already installed", vim.log.levels.INFO)
  end
end, {
  desc = "Run first-time installation setup",
})

cmd("VelocityReinstall", function()
  local first_run = require("core.first-run")
  -- Force reinstallation by running installation regardless
  first_run.run_installation()
end, {
  desc = "Force reinstall VelocityNvim (useful for updates)",
})

cmd("PluginStatus", function()
  local manage = require("plugins.manage")
  local all_plugins = manage.get_all_plugins()
  print(icons.status.search .. " Plugin Status:")
  for name, _ in pairs(all_plugins) do
    local pack_path = vim.fn.stdpath("data") .. "/site/pack/user/start/" .. name
    local status = vim.fn.isdirectory(pack_path) == 1 and icons.status.success .. " Installed"
      or icons.status.error .. " Missing"
    print("  " .. name .. ": " .. status)
  end
end, {
  desc = "Show plugin installation status",
})

-- Optional Package Management
cmd("OptionalPackages", function()
  local manage = require("plugins.manage")
  local config = manage.load_optional_config()

  print(icons.status.gear .. " Optional Packages Configuration:")
  print("")

  for key, pkg in pairs(manage.optional_packages) do
    local is_enabled = manage.is_feature_enabled(key)
    local status = is_enabled and (icons.status.success .. " Enabled") or (icons.status.error .. " Disabled")
    print("  " .. pkg.name .. ": " .. status)
    print("    " .. pkg.description)
    print("    Dependencies: " .. table.concat(pkg.dependencies, ", "))
    print("")
  end

  print(icons.status.hint .. " Use :OptionalPackagesToggle <name> to toggle a package")
  print(icons.status.hint .. " Use :OptionalPackagesReset to re-run package selection")
end, {
  desc = "Show optional packages status",
})

cmd("OptionalPackagesToggle", function(opts)
  local manage = require("plugins.manage")
  local package_name = opts.args

  if not package_name or package_name == "" then
    vim.notify(icons.status.error .. " Usage: :OptionalPackagesToggle <package_name>", vim.log.levels.ERROR)
    return
  end

  if not manage.optional_packages[package_name] then
    vim.notify(icons.status.error .. " Unknown package: " .. package_name, vim.log.levels.ERROR)
    print("Available packages: " .. table.concat(vim.tbl_keys(manage.optional_packages), ", "))
    return
  end

  local config = manage.load_optional_config()
  local selected = config.selected or {}
  local is_enabled = manage.is_feature_enabled(package_name)

  if is_enabled then
    -- Remove from selected
    local new_selected = {}
    for _, name in ipairs(selected) do
      if name ~= package_name then
        table.insert(new_selected, name)
      end
    end
    config.selected = new_selected
    vim.notify(icons.status.error .. " " .. package_name .. " disabled. Restart Neovim to apply.", vim.log.levels.INFO)
  else
    -- Add to selected
    table.insert(selected, package_name)
    config.selected = selected
    vim.notify(icons.status.success .. " " .. package_name .. " enabled. Run :PluginSync then restart.", vim.log.levels.INFO)
  end

  manage.save_optional_config(config)
end, {
  nargs = 1,
  complete = function()
    local manage = require("plugins.manage")
    return vim.tbl_keys(manage.optional_packages)
  end,
  desc = "Toggle an optional package",
})

cmd("OptionalPackagesReset", function()
  local manage = require("plugins.manage")
  local config = { selected = {}, configured = false }
  manage.save_optional_config(config)
  vim.notify(icons.status.sync .. " Optional packages reset. Run :VelocityReinstall to re-select.", vim.log.levels.INFO)
end, {
  desc = "Reset optional packages selection",
})
