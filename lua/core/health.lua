-- ~/.config/VelocityNvim/lua/core/health.lua
-- Health checks für VelocityNvim Native Configuration

local health = vim.health or require("health")

local M = {}

-- Helper function für health checks
local function check_executable(cmd, name, required)
  if vim.fn.executable(cmd) == 1 then
    health.ok(name .. " is installed")
    return true
  else
    local level = required and health.error or health.warn
    level(name .. " is not installed")
    return false
  end
end

-- Helper function für Lua module checks
local function check_module(module_name, description, required)
  local ok, _ = pcall(require, module_name)
  if ok then
    health.ok(description .. " is available")
    return true
  else
    local level = required and health.error or health.warn
    level(description .. " is not available")
    return false
  end
end

-- Core Health Check
function M.check()
  health.start("VelocityNvim Native Configuration")

  -- Version information
  local version_mod = require("core.version")
  health.info("Configuration version: " .. version_mod.config_version)
  health.info("Last updated: " .. version_mod.last_updated)

  -- Neovim compatibility check
  local compat, compat_msg = version_mod.check_nvim_compatibility()
  if compat then
    health.ok("Neovim compatibility: " .. compat_msg)
  else
    health.error("Neovim compatibility: " .. compat_msg)
  end

  -- Version change detection
  local change_type = version_mod.check_version_change()
  if change_type == "fresh_install" then
    health.info("Installation status: Fresh installation")
  elseif change_type == "upgrade" then
    local stored = version_mod.get_stored_version()
    if stored then
      health.ok("Installation status: Upgraded from " .. stored.version)
    else
      health.ok("Installation status: Upgraded (no previous version found)")
    end
  elseif change_type == "downgrade" then
    local stored = version_mod.get_stored_version()
    if stored then
      health.warn("Installation status: Downgraded from " .. stored.version)
    else
      health.warn("Installation status: Downgraded (no previous version found)")
    end
  else
    health.ok("Installation status: Up to date")
  end

  -- Configuration paths
  local config_path = vim.fn.stdpath("config")
  local data_path = vim.fn.stdpath("data")

  health.info("Config path: " .. config_path)
  health.info("Data path: " .. data_path)

  -- Version file check
  local version_file = data_path .. "/velocitynvim_version"
  if vim.fn.filereadable(version_file) == 1 then
    health.ok("Version tracking file exists")
  else
    health.warn("Version tracking file missing (will be created on next start)")
  end

  -- Check core modules
  health.start("Core Modules")
  check_module("core.options", "Core options", true)
  check_module("core.keymaps", "Core keymaps", true)
  check_module("core.icons", "Core icons", true)
  check_module("core.autocmds", "Core autocommands", false)
  check_module("core.commands", "Core commands", false)

  -- Check utility modules
  health.start("Utility Modules")
  check_module("utils", "Utils main module", true)
  check_module("utils.buffer", "Buffer utilities", false)
  check_module("utils.window", "Window utilities", false)
  check_module("utils.git", "Git utilities", false)
  check_module("utils.lsp", "LSP utilities", false)
  check_module("utils.file", "File utilities", false)

  -- Plugin system check
  health.start("Plugin System")
  check_module("plugins.manage", "Plugin manager", true)

  local manage_ok, manage = pcall(require, "plugins.manage")
  if manage_ok then
    local plugin_count = vim.tbl_count(manage.plugins)
    health.ok("Plugin manager loaded (" .. plugin_count .. " plugins configured)")

    -- Check plugin installation
    local pack_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/"
    local installed = 0
    local missing = {}

    for name, _ in pairs(manage.plugins) do
      local plugin_path = pack_dir .. name
      if vim.fn.isdirectory(plugin_path) == 1 then
        installed = installed + 1
      else
        table.insert(missing, name)
      end
    end

    if #missing == 0 then
      health.ok("All " .. plugin_count .. " plugins are installed")
    else
      health.warn(#missing .. " plugins missing: " .. table.concat(missing, ", "))
      health.info("Run :PluginSync to install missing plugins")
    end
  end

  -- LSP Health Check
  health.start("LSP Configuration")

  -- Check if LSP module loads
  check_module("plugins.lsp.native-lsp", "Native LSP configuration", true)

  -- Check LSP servers
  local lsp_servers = {
    { name = "lua-language-server", cmd = "lua-language-server", desc = "Lua LSP" },
    { name = "pyright-langserver", cmd = "pyright-langserver", desc = "Python LSP" },
    { name = "typescript-language-server", cmd = "typescript-language-server", desc = "TypeScript LSP" },
    { name = "vscode-html-language-server", cmd = "vscode-html-language-server", desc = "HTML LSP" },
    { name = "vscode-css-language-server", cmd = "vscode-css-language-server", desc = "CSS LSP" },
    { name = "vscode-json-language-server", cmd = "vscode-json-language-server", desc = "JSON LSP" },
    { name = "texlab", cmd = "texlab", desc = "LaTeX LSP" },
  }

  local lsp_available = 0
  for _, server in ipairs(lsp_servers) do
    if check_executable(server.cmd, server.desc, false) then
      lsp_available = lsp_available + 1
    end
  end

  health.info(lsp_available .. "/" .. #lsp_servers .. " LSP servers available")

  -- Check active LSP clients
  local active_clients = vim.lsp.get_clients()
  if #active_clients > 0 then
    health.ok(#active_clients .. " LSP clients currently active")
    for _, client in ipairs(active_clients) do
      health.info("  • " .. client.name)
    end
  else
    health.info("No LSP clients currently active")
  end

  -- Completion system
  health.start("Completion System")
  check_module("plugins.lsp.blink-cmp", "Blink completion", true)

  -- Check if blink.cmp is actually available
  local blink_ok, _ = pcall(require, "blink.cmp")
  if blink_ok then
    health.ok("Blink.cmp is loaded and ready")
  else
    health.error("Blink.cmp failed to load")
  end

  -- Tools Health Check
  health.start("Development Tools")

  -- Essential tools
  check_executable("git", "Git", true)
  check_executable("fzf", "FZF (fuzzy finder)", false)
  check_executable("rg", "Ripgrep (for searching)", false)
  check_executable("fd", "fd (for file finding)", false)

  -- Formatters
  local formatters = {
    { cmd = "stylua", name = "StyLua (Lua formatter)" },
    { cmd = "ruff", name = "Ruff (Python formatter)" },
    { cmd = "prettier", name = "Prettier (JS/TS/HTML/CSS formatter)" },
    { cmd = "shfmt", name = "shfmt (Shell script formatter)" },
  }

  local formatter_count = 0
  for _, fmt in ipairs(formatters) do
    if check_executable(fmt.cmd, fmt.name, false) then
      formatter_count = formatter_count + 1
    end
  end

  health.info(formatter_count .. "/" .. #formatters .. " formatters available")

  -- Treesitter
  health.start("Treesitter")
  check_module("plugins.editor.nvim-treesitter", "Treesitter configuration", true)

  local ts_ok, _ = pcall(require, "nvim-treesitter")
  if ts_ok then
    health.ok("nvim-treesitter is available")

    -- Check installed parsers
    local parsers = require("nvim-treesitter.parsers")
    local installed_parsers = parsers.get_parser_configs()
    local parser_count = 0
    for _ in pairs(installed_parsers) do
      parser_count = parser_count + 1
    end
    health.info(parser_count .. " treesitter parsers installed")
  end

  -- System resources
  health.start("System Resources")

  -- Memory usage (rough estimate)
  local mem_usage = vim.fn.system("ps -o rss= -p " .. vim.fn.getpid()):gsub("%s+", "")
  if mem_usage and tonumber(mem_usage) then
    local mem_mb = math.floor(tonumber(mem_usage) / 1024)
    health.info("Current memory usage: ~" .. mem_mb .. " MB")
  end

  -- Check startup time
  if vim.fn.has("startuptime") == 1 then
    health.ok("Startup time measurement available (:StartupTime)")
  end

  -- Recommendations
  health.start("Recommendations")

  if formatter_count < 2 then
    health.info("Install more formatters for better code formatting support")
  end

  if not check_executable("rg", "", false) then
    health.info("Install ripgrep (rg) for faster file searching")
  end

  if not check_executable("fd", "", false) then
    health.info("Install fd for faster file finding")
  end
end

return M