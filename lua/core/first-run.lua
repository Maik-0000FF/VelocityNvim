-- ~/.config/VelocityNvim/lua/core/first-run.lua
-- Automated First-Run Installation System for VelocityNvim
-- Handles complete setup on fresh installations

local M = {}
local icons = require("core.icons")

-- Installation phases
local PHASES = {
  { name = "Compatibility Check", key = "compat" },
  { name = "Plugin Installation", key = "plugins" },
  { name = "Rust Performance Build", key = "rust" },
  { name = "Health Verification", key = "health" },
  { name = "Welcome Setup", key = "welcome" },
}

-- State tracking
local state = {
  current_phase = 1,
  total_phases = #PHASES,
  errors = {},
  start_time = nil,
  is_running = false,
}

-- Progress display (stable, no flickering)
local function show_progress(message, phase_num, is_error)
  local phase_num = phase_num or state.current_phase
  local total = state.total_phases
  local icon = is_error and icons.status.error or icons.status.gear

  -- Fixed width progress bar for stable display
  local progress = phase_num / total
  local bar_width = 20 -- Fixed width
  local filled = math.floor(progress * bar_width)
  local bar = string.rep("█", filled) .. string.rep("░", bar_width - filled)

  -- NEUE ANORDNUNG: Progress bar NACH der Nachricht für stabile Position
  local progress_line = string.format(
    "%s Phase %d/%d [%s] %.0f%% - %s",
    icon,
    phase_num,
    total,
    bar,
    progress * 100,
    message
  )

  -- Use vim.schedule to avoid flickering and reduce redraws
  vim.schedule(function()
    -- Make message persistent and visible
    print(progress_line)

    -- Only show errors if they exist
    if #state.errors > 0 then
      print(icons.status.warning .. " Issues: " .. #state.errors)
    end
    
    -- Force redraw to ensure visibility
    vim.cmd("redraw")
  end)
end

-- Phase 1: Compatibility Check
local function phase_compatibility()
  show_progress("Checking Neovim compatibility...", 1)
  vim.cmd("redraw!")
  
  -- Force visible pause for Phase 1
  local start_time = vim.fn.reltime()
  while vim.fn.reltimefloat(vim.fn.reltime(start_time)) < 2.0 do
    vim.cmd("sleep 100m") -- 100ms steps
  end
  
  local version_mod = require("core.version")
  local compat, msg = version_mod.check_nvim_compatibility()

  if not compat then
    table.insert(state.errors, "Neovim " .. msg .. " required")
    return false
  end

  -- Check essential tools
  local tools = {
    { cmd = "git", name = "Git", required = true },
    { cmd = "cargo", name = "Rust/Cargo", required = false },
    { cmd = "rg", name = "Ripgrep", required = false },
    { cmd = "fzf", name = "FZF", required = false },
  }

  for _, tool in ipairs(tools) do
    local available = vim.fn.executable(tool.cmd) == 1
    if tool.required and not available then
      table.insert(state.errors, tool.name .. " is required but not installed")
      return false
    elseif not available then
      table.insert(state.errors, tool.name .. " not available (optional)")
    end
  end

  vim.defer_fn(function()
    state.current_phase = 2
  end, 100)
  return true
end

-- Phase 2: Plugin Installation
local function phase_plugins()
  show_progress("Installing plugins...", 2)

  local manage_ok, manage = pcall(require, "plugins.manage")
  if not manage_ok then
    table.insert(state.errors, "Plugin manager not found")
    return false
  end

  -- Count plugins for progress  
  local plugin_count = vim.tbl_count(manage.plugins)

  -- Install plugins (using the existing PluginSync logic)
  local success_count = 0
  local pack_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/"

  -- Ensure pack directory exists
  vim.fn.mkdir(pack_dir, "p")

  local current_num = 0
  for name, url in pairs(manage.plugins) do
    local plugin_path = pack_dir .. name
    current_num = current_num + 1

    if vim.fn.isdirectory(plugin_path) == 0 then
      -- Show Phase 2 with real plugin being installed
      show_progress(string.format("Installing plugin %d/%d: %s", current_num, plugin_count, name), 2)
      vim.cmd("redraw!")  -- Force display before git clone
      vim.cmd("sleep 200m")  -- 200ms sichtbar
      
      local cmd = string.format(
        "git clone --depth 1 %s %s",
        vim.fn.shellescape(url),
        vim.fn.shellescape(plugin_path)
      )
      local result = vim.fn.system(cmd)

      if vim.v.shell_error == 0 then
        success_count = success_count + 1
      else
        table.insert(
          state.errors,
          string.format("Failed to install %s: %s", name, result:gsub("\n", " "))
        )
      end
    else
      -- Show Phase 2 even for already installed plugins
      show_progress(string.format("Plugin %d/%d already installed: %s", current_num, plugin_count, name), 2)
      vim.cmd("redraw!")  -- Force display
      vim.cmd("sleep 100m")  -- 100ms sichtbar für bereits installierte
      success_count = success_count + 1 -- Already installed
    end
  end

  if success_count < plugin_count then
    table.insert(
      state.errors,
      string.format("Only %d/%d plugins installed successfully", success_count, plugin_count)
    )
  end

  -- Klare Rückmeldung dass Phase 2 abgeschlossen ist
  show_progress(string.format("Phase 2 complete: %d/%d plugins installed", success_count, plugin_count), 2)
  vim.cmd("redraw!")
  vim.cmd("sleep 800m")
  
  show_progress("Moving to Phase 3: Rust Performance Build...", 2)
  vim.cmd("redraw!")
  vim.cmd("sleep 600m")

  state.current_phase = 3
  return success_count > 0
end

-- Phase 3: Rust Performance Build
local function phase_rust()
  show_progress("Phase 3: Checking Rust availability...", 3)
  vim.cmd("redraw!")
  vim.cmd("sleep 500m")

  -- Check if Cargo is available
  if vim.fn.executable("cargo") == 0 then
    show_progress("Phase 3: Cargo not available - skipping Rust builds", 3)
    vim.cmd("redraw!")
    vim.cmd("sleep 1000m")
    table.insert(state.errors, "Cargo not available - skipping Rust builds")
    state.current_phase = 4
    return true -- Not critical failure
  end

  show_progress("Phase 3: Rust detected - building performance optimizations...", 3)
  vim.cmd("redraw!")
  vim.cmd("sleep 500m")

  -- Build blink.cmp Rust fuzzy matching
  local blink_path = vim.fn.stdpath("data") .. "/site/pack/user/start/blink.cmp"
  if vim.fn.isdirectory(blink_path) == 1 then
    show_progress("Phase 3: Building blink.cmp Rust fuzzy matching...", 3)
    vim.cmd("redraw!")

    local cmd = string.format("cd %s && cargo build --release", vim.fn.shellescape(blink_path))
    local result = vim.fn.system(cmd)

    if vim.v.shell_error == 0 then
      show_progress("Phase 3: Rust build successful - verifying binary...", 3)
      vim.cmd("redraw!")
      vim.cmd("sleep 500m")
      
      -- Cross-platform binary check (Linux: .so, macOS: .dylib, Windows: .dll)
      local binary_path = blink_path .. "/target/release/"
      local possible_libs = {
        "libblink_cmp_fuzzy.so",    -- Linux
        "libblink_cmp_fuzzy.dylib", -- macOS
        "blink_cmp_fuzzy.dll",      -- Windows
      }
      
      local lib_found = false
      for _, lib_name in ipairs(possible_libs) do
        if vim.fn.filereadable(binary_path .. lib_name) == 1 then
          lib_found = true
          show_progress("Phase 3: Rust performance binary ready (" .. lib_name .. ")", 3)
          vim.cmd("redraw!")
          vim.cmd("sleep 800m")
          break
        end
      end
      
      if not lib_found then
        show_progress("Phase 3: Rust build completed but binary verification failed", 3)
        vim.cmd("redraw!")
        vim.cmd("sleep 800m")
        table.insert(state.errors, "Rust binary built but library not found (cross-platform check)")
      end
    else
      show_progress("Phase 3: Rust build failed - using Lua fallback", 3)
      vim.cmd("redraw!")
      vim.cmd("sleep 800m")
      table.insert(state.errors, "blink.cmp Rust build failed")
    end
  end

  vim.defer_fn(function()
    state.current_phase = 4
  end, 500)
  return true
end

-- Phase 4: Health Verification
local function phase_health()
  show_progress("Running health checks...", 4)

  -- Quick health verification
  local health_ok, health = pcall(require, "core.health")
  if health_ok then
    -- Run a basic health check
    vim.defer_fn(function()
      pcall(health.check)
      state.current_phase = 5
    end, 1000)
  else
    table.insert(state.errors, "Health system not available")
    vim.defer_fn(function()
      state.current_phase = 5
    end, 100)
  end

  return true
end

-- Phase 5: Welcome Setup
local function phase_welcome()
  show_progress("Finalizing installation...", 5)

  -- Mark installation as complete
  local version_mod = require("core.version")
  version_mod.store_version()

  -- Calculate installation time
  local duration = state.start_time and (vim.fn.reltime(state.start_time)) or nil
  local duration_str = duration and vim.fn.reltimestr(duration) or "unknown"

  -- Direct execution without defer to prevent flickering
  local plugin_count = vim.tbl_count(require("plugins.manage").plugins)
  local rust_status = vim.fn.executable("cargo") == 1 and "Enabled" or "Disabled"

  local success_msg = string.format(
    "Installation Complete! v%s • %d plugins • Rust: %s • %ss",
    version_mod.config_version,
    plugin_count,
    rust_status,
    string.format("%.1f", tonumber(duration_str) or 0)
  )

  -- Single print call - no flickering
  print(success_msg .. " " .. icons.status.success)
  print("Ready! Restart VelocityNvim to use.")
  
  -- Mark as complete and exit after short delay
  state.is_running = false
  vim.cmd("sleep 2")
  vim.cmd("qall!")

  return true
end

-- Main installation orchestrator
function M.run_installation()
  if state.is_running then
    return -- Prevent concurrent installations
  end

  state.is_running = true
  state.start_time = vim.fn.reltime()
  state.current_phase = 1
  state.errors = {}

  -- Phase execution chain
  local phases = {
    phase_compatibility,
    phase_plugins,
    phase_rust,
    phase_health,
    phase_welcome,
  }

  local function run_next_phase()
    if state.current_phase > #phases then
      return -- Installation complete
    end

    local phase_func = phases[state.current_phase]
    local success = phase_func()

    if not success and state.current_phase <= 2 then
      -- Critical failure in early phases
      show_progress("Installation failed - critical error", state.current_phase, true)
      state.is_running = false
      return
    end

    -- Schedule next phase
    vim.defer_fn(run_next_phase, 100)
  end

  run_next_phase()
end

-- Check if first-run installation is needed
function M.is_needed()
  local version_mod = require("core.version")
  return version_mod.is_fresh_install()
end

-- Silent background check (for non-interactive environments)
function M.quick_check()
  if not M.is_needed() then
    return true -- No installation needed
  end

  -- For headless/script usage - just install plugins without UI
  local manage_ok, manage = pcall(require, "plugins.manage")
  if manage_ok then
    local pack_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/"
    local missing = false

    for name, url in pairs(manage.plugins) do
      if vim.fn.isdirectory(pack_dir .. name) == 0 then
        missing = true
        break
      end
    end

    if missing then
      return false -- Plugins missing
    end
  end

  return true
end

return M

