-- ~/.config/VelocityNvim/lua/core/health.lua
-- Health checks for VelocityNvim Native Configuration

local health = vim.health or require("health")

local M = {}

-- Helper function for health checks
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

-- Helper function for Lua module checks
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

  -- Neovim version check
  local nvim_ver = vim.version()
  local required = { major = 0, minor = 11, patch = 0 }
  local version_string = string.format("%d.%d.%d", nvim_ver.major, nvim_ver.minor, nvim_ver.patch)

  if nvim_ver.major > required.major or
     (nvim_ver.major == required.major and nvim_ver.minor >= required.minor) then
    health.ok("Neovim version: " .. version_string .. " (compatible)")
  else
    health.error(string.format("Neovim version: %s (requires >= %d.%d.%d)",
      version_string, required.major, required.minor, required.patch))
  end

  -- Configuration paths
  local config_path = vim.fn.stdpath("config")
  local data_path = vim.fn.stdpath("data")

  health.info("Config path: " .. config_path)
  health.info("Data path: " .. data_path)

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

    -- Check installed parsers (compatible with nvim-treesitter and builtin)
    local parser_count = 0
    local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
    local runtime_parser = vim.env.VIMRUNTIME .. "/parser"

    -- Count parsers in data directory
    if vim.fn.isdirectory(parser_dir) == 1 then
      local files = vim.fn.globpath(parser_dir, "*.so", false, true)
      parser_count = parser_count + #files
    end

    -- Count builtin parsers
    if vim.fn.isdirectory(runtime_parser) == 1 then
      local files = vim.fn.globpath(runtime_parser, "*.so", false, true)
      parser_count = parser_count + #files
    end

    health.info(parser_count .. " treesitter parsers available")
  end

  -- System resources
  health.start("System Resources")

  -- Memory usage (rough estimate) - using vim.system() for better performance
  local mem_result = vim.system({ "ps", "-o", "rss=", "-p", tostring(vim.fn.getpid()) }, { text = true }):wait()
  if mem_result.code == 0 and mem_result.stdout then
    local mem_usage = mem_result.stdout:gsub("%s+", "")
    if tonumber(mem_usage) then
      local mem_mb = math.floor(tonumber(mem_usage) / 1024)
      health.info("Current memory usage: ~" .. mem_mb .. " MB")
    end
  end

  -- Check startup time
  if vim.fn.has("startuptime") == 1 then
    health.ok("Startup time measurement available (:StartupTime)")
  end

  -- Web Development Server
  health.start("Web Development Server")

  check_module("utils.webserver", "Web server utilities", false)

  -- Check web server dependencies
  local has_node = check_executable("node", "Node.js", false)
  local has_npm = check_executable("npm", "npm", false)
  local has_live_server = check_executable("live-server", "live-server", false)
  local has_curl = check_executable("curl", "curl (for health checks)", false)
  local has_lsof = check_executable("lsof", "lsof (for port management)", false)

  -- Browser check (OS-specific)
  local is_macos = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
  local has_browser
  if is_macos then
    -- macOS always has 'open' built-in
    has_browser = true
    health.ok("Browser opener: macOS 'open' command (built-in)")
  else
    -- Linux: check for Firefox or xdg-open
    local has_firefox = check_executable("firefox", "Firefox browser", false)
    local has_xdg_open = check_executable("xdg-open", "xdg-open (browser fallback)", false)
    has_browser = has_firefox or has_xdg_open
  end

  -- Summary
  if has_live_server and has_curl and has_lsof and has_browser then
    health.ok("Web server fully functional")
    health.info("Commands: :WebServerStart, :WebServerStop, <leader>ws")
  elseif has_node and has_npm then
    health.warn("Web server partially functional - install live-server: npm install -g live-server")
  else
    health.warn("Web server not available - install Node.js and npm first")
  end

  -- Node.js version check - using vim.system() for better performance
  if has_node then
    local result = vim.system({ "node", "--version" }, { text = true }):wait()
    if result.code == 0 and result.stdout then
      health.info("Node.js version: " .. vim.trim(result.stdout))
    end
  end

  -- npm version check
  if has_npm then
    local result = vim.system({ "npm", "--version" }, { text = true }):wait()
    if result.code == 0 and result.stdout then
      health.info("npm version: " .. vim.trim(result.stdout))
    end
  end

  -- live-server version check
  if has_live_server then
    local result = vim.system({ "live-server", "--version" }, { text = true }):wait()
    if result.code == 0 and result.stdout then
      health.info("live-server version: " .. vim.trim(result.stdout))
    end
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

  if not has_live_server and has_node and has_npm then
    health.info("Install live-server for web development: npm install -g live-server")
  end
end

return M