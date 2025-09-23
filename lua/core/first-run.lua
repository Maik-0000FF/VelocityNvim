-- ~/.config/VelocityNvim/lua/core/first-run.lua
-- Automated First-Run Installation System for VelocityNvim
-- FIXED: Race conditions, UI flickering, blocking operations

local M = {}
local icons = require("core.icons")

-- Installation phases with improved timing
local PHASES = {
  { name = "Compatibility Check", key = "compat", duration = 1.5 },
  { name = "Plugin Installation", key = "plugins", duration = 0 }, -- Variable based on plugin count
  { name = "Rust Performance Build", key = "rust", duration = 3.0 },
  { name = "Health Verification", key = "health", duration = 1.0 },
  { name = "Welcome Setup", key = "welcome", duration = 1.0 },
}

-- STABLE state tracking - no race conditions
local state = {
  current_phase = 1,
  total_phases = #PHASES,
  phase_progress = 0, -- 0.0 to 1.0 within current phase
  errors = {},
  warnings = {},
  start_time = nil,
  is_running = false,
  phase_start_time = nil,
  ui_buffer = nil,
  ui_window = nil,
}

-- STABLE progress display with dedicated UI window
local function create_progress_ui()
  if state.ui_buffer and vim.api.nvim_buf_is_valid(state.ui_buffer) then
    return -- Already exists
  end

  -- Create dedicated buffer for progress
  state.ui_buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(state.ui_buffer, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(state.ui_buffer, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(state.ui_buffer, 'swapfile', false)
  vim.api.nvim_buf_set_option(state.ui_buffer, 'modifiable', false)

  -- Create centered floating window (wider for progress bars)
  local width = 90
  local height = 15
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  state.ui_window = vim.api.nvim_open_win(state.ui_buffer, false, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' VelocityNvim First-Run Installation ',
    title_pos = 'center'
  })

  -- Set window options
  vim.api.nvim_win_set_option(state.ui_window, 'cursorline', false)
  vim.api.nvim_win_set_option(state.ui_window, 'number', false)
  vim.api.nvim_win_set_option(state.ui_window, 'relativenumber', false)
end

-- STABLE progress update - no race conditions
local function update_progress_ui(message, phase_progress)
  if not state.ui_buffer or not vim.api.nvim_buf_is_valid(state.ui_buffer) then
    create_progress_ui()
  end

  local phase_num = state.current_phase
  local total = state.total_phases
  local phase_name = PHASES[phase_num].name

  -- Calculate overall progress
  local overall_progress = (phase_num - 1) / total + (phase_progress or 0) / total
  local phase_only_progress = phase_progress or 0

  -- Create progress bars
  local overall_bar_width = 60
  local phase_bar_width = 40
  local overall_filled = math.floor(overall_progress * overall_bar_width)
  local phase_filled = math.floor(phase_only_progress * phase_bar_width)

  local overall_bar = string.rep("█", overall_filled) .. string.rep("░", overall_bar_width - overall_filled)
  local phase_bar = string.rep("█", phase_filled) .. string.rep("░", phase_bar_width - phase_filled)

  -- Build UI content
  local lines = {
    "",
    string.format("  %s VelocityNvim Installation in Progress...", icons.status.gear),
    "",
    string.format("  Overall Progress: [%s] %.1f%%", overall_bar, overall_progress * 100),
    "",
    string.format("  Phase %d/%d: %s", phase_num, total, phase_name),
    string.format("  [%s] %.1f%%", phase_bar, phase_only_progress * 100),
    "",
    string.format("  %s %s", icons.status.info, message or "Processing..."),
    "",
  }

  -- Add error/warning summary
  if #state.errors > 0 then
    table.insert(lines, string.format("  %s Errors: %d", icons.status.error, #state.errors))
  end
  if #state.warnings > 0 then
    table.insert(lines, string.format("  %s Warnings: %d", icons.status.warning, #state.warnings))
  end

  -- Update buffer content atomically
  vim.api.nvim_buf_set_option(state.ui_buffer, 'modifiable', true)
  vim.api.nvim_buf_set_lines(state.ui_buffer, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(state.ui_buffer, 'modifiable', false)

  -- Force redraw only once
  vim.cmd('redraw')
end

-- Clean up UI
local function cleanup_progress_ui()
  if state.ui_window and vim.api.nvim_win_is_valid(state.ui_window) then
    vim.api.nvim_win_close(state.ui_window, true)
  end
  if state.ui_buffer and vim.api.nvim_buf_is_valid(state.ui_buffer) then
    vim.api.nvim_buf_delete(state.ui_buffer, { force = true })
  end
  state.ui_window = nil
  state.ui_buffer = nil
end

-- ASYNC Phase 1: Compatibility Check
local function phase_compatibility(callback)
  state.phase_start_time = vim.fn.reltime()
  update_progress_ui("Checking Neovim compatibility...", 0)

  -- Non-blocking compatibility check with progress updates
  local function check_step(step, max_steps, check_func, description)
    vim.defer_fn(function()
      local progress = step / max_steps
      update_progress_ui(description, progress)

      local success, result = pcall(check_func)
      if not success then
        table.insert(state.errors, "Compatibility check failed: " .. tostring(result))
      end

      -- Continue to next step or finish
      if step < max_steps then
        local next_step = step + 1
        if next_step == 2 then
          check_step(2, max_steps, function()
            local version_mod = require("core.version")
            local compat, msg = version_mod.check_nvim_compatibility()
            if not compat then
              table.insert(state.errors, "Neovim " .. msg .. " required")
              return false
            end
            return true
          end, "Verifying Neovim version...")
        elseif next_step == 3 then
          check_step(3, max_steps, function()
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
                table.insert(state.warnings, tool.name .. " not available (optional)")
              end
            end
            return true
          end, "Checking development tools...")
        end
      else
        -- Phase complete
        update_progress_ui("Compatibility check completed", 1.0)
        vim.defer_fn(function()
          callback(#state.errors == 0)
        end, 300)
      end
    end, 500)
  end

  -- Start the step chain
  check_step(1, 3, function() return true end, "Starting compatibility check...")
end

-- ASYNC Phase 2: Plugin Installation
local function phase_plugins(callback)
  state.phase_start_time = vim.fn.reltime()

  local manage_ok, manage = pcall(require, "plugins.manage")
  if not manage_ok then
    table.insert(state.errors, "Plugin manager not found")
    callback(false)
    return
  end

  local plugins = vim.tbl_keys(manage.plugins)
  local plugin_count = #plugins
  local success_count = 0
  local current_index = 0
  local pack_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/"

  -- Ensure pack directory exists
  vim.fn.mkdir(pack_dir, "p")

  -- ASYNC plugin installation - one at a time to avoid blocking
  local function install_next_plugin()
    current_index = current_index + 1

    if current_index > plugin_count then
      -- All plugins processed
      local final_message = string.format(
        "Plugin installation complete: %d/%d successful",
        success_count,
        plugin_count
      )
      update_progress_ui(final_message, 1.0)

      if success_count < plugin_count then
        table.insert(
          state.errors,
          string.format("Only %d/%d plugins installed successfully", success_count, plugin_count)
        )
      end

      vim.defer_fn(function()
        callback(success_count > 0)
      end, 500)
      return
    end

    local name = plugins[current_index]
    local url = manage.plugins[name]
    local plugin_path = pack_dir .. name
    local progress = current_index / plugin_count

    if vim.fn.isdirectory(plugin_path) == 0 then
      -- Need to install
      update_progress_ui(string.format("Installing %d/%d: %s", current_index, plugin_count, name), progress)

      -- ASYNC git clone using vim.fn.jobstart
      local cmd = {
        "git", "clone", "--depth", "1", "--quiet", url, plugin_path
      }

      vim.fn.jobstart(cmd, {
        on_exit = function(_, exit_code)
          if exit_code == 0 then
            success_count = success_count + 1
            update_progress_ui(string.format("Installed %s successfully", name), progress)
          else
            table.insert(state.errors, string.format("Failed to install %s", name))
            update_progress_ui(string.format("Failed to install %s", name), progress)
          end

          -- Continue to next plugin after short delay
          vim.defer_fn(install_next_plugin, 100)
        end,
        stderr_buffered = true,
        stdout_buffered = true,
      })
    else
      -- Already installed
      success_count = success_count + 1
      update_progress_ui(string.format("Already installed %d/%d: %s", current_index, plugin_count, name), progress)

      -- Continue immediately
      vim.defer_fn(install_next_plugin, 50)
    end
  end

  -- Start installation chain
  update_progress_ui("Starting plugin installation...", 0)
  vim.defer_fn(install_next_plugin, 300)
end

-- ASYNC Phase 3: Rust Performance Build
local function phase_rust(callback)
  state.phase_start_time = vim.fn.reltime()

  -- Check if Cargo is available
  if vim.fn.executable("cargo") == 0 then
    update_progress_ui("Cargo not available - skipping Rust builds", 0.5)
    table.insert(state.warnings, "Cargo not available - skipping Rust builds")
    vim.defer_fn(function()
      update_progress_ui("Rust build phase completed (skipped)", 1.0)
      vim.defer_fn(function() callback(true) end, 500)
    end, 1000)
    return
  end

  update_progress_ui("Rust detected - preparing build environment...", 0.1)

  -- Check for blink.cmp directory
  local blink_path = vim.fn.stdpath("data") .. "/site/pack/user/start/blink.cmp"
  if vim.fn.isdirectory(blink_path) == 0 then
    update_progress_ui("blink.cmp not found - skipping Rust build", 0.8)
    table.insert(state.warnings, "blink.cmp plugin not installed - skipping Rust build")
    vim.defer_fn(function()
      update_progress_ui("Rust build phase completed (no blink.cmp)", 1.0)
      vim.defer_fn(function() callback(true) end, 500)
    end, 800)
    return
  end

  update_progress_ui("Building blink.cmp Rust fuzzy matching (this may take a while)...", 0.2)

  -- ASYNC Rust build using jobstart
  local build_cmd = { "cargo", "build", "--release" }

  vim.fn.jobstart(build_cmd, {
    cwd = blink_path,
    on_stdout = function(_, data)
      if data and #data > 0 and data[1] ~= "" then
        -- Show build progress feedback
        update_progress_ui("Building Rust components... (compiling)", 0.6)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 and data[1] ~= "" then
        -- Build output - not necessarily an error
        update_progress_ui("Building Rust components... (linking)", 0.8)
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        update_progress_ui("Rust build successful - verifying binary...", 0.9)

        -- Verify binary exists
        local binary_path = blink_path .. "/target/release/"
        local possible_libs = {
          "libblink_cmp_fuzzy.so",    -- Linux
          "libblink_cmp_fuzzy.dylib", -- macOS
          "blink_cmp_fuzzy.dll",      -- Windows
        }

        local lib_found = false
        local lib_name = ""
        for _, lib in ipairs(possible_libs) do
          if vim.fn.filereadable(binary_path .. lib) == 1 then
            lib_found = true
            lib_name = lib
            break
          end
        end

        if lib_found then
          update_progress_ui(string.format("Rust performance binary ready (%s)", lib_name), 1.0)
          vim.defer_fn(function() callback(true) end, 800)
        else
          update_progress_ui("Rust build completed but binary verification failed", 1.0)
          table.insert(state.errors, "Rust binary built but library not found")
          vim.defer_fn(function() callback(true) end, 800) -- Still continue
        end
      else
        update_progress_ui("Rust build failed - will use Lua fallback", 1.0)
        table.insert(state.warnings, "blink.cmp Rust build failed - using Lua fallback")
        vim.defer_fn(function() callback(true) end, 800) -- Not critical
      end
    end,
    stdout_buffered = false,
    stderr_buffered = false,
  })
end

-- ASYNC Phase 4: Health Verification
local function phase_health(callback)
  state.phase_start_time = vim.fn.reltime()
  update_progress_ui("Running system health checks...", 0)

  -- Check if health system is available
  local health_ok, health = pcall(require, "core.health")
  if not health_ok then
    table.insert(state.errors, "Health system not available")
    update_progress_ui("Health system not available", 1.0)
    vim.defer_fn(function() callback(false) end, 500)
    return
  end

  update_progress_ui("Verifying core systems...", 0.3)

  -- Run health check asynchronously
  vim.defer_fn(function()
    local health_results = {}

    -- Capture health check results
    local success = pcall(function()
      -- Run basic health verification
      health.check()
    end)

    update_progress_ui("Analyzing health check results...", 0.7)

    vim.defer_fn(function()
      if success then
        update_progress_ui("Health verification completed successfully", 1.0)
        vim.defer_fn(function() callback(true) end, 500)
      else
        update_progress_ui("Health verification completed with warnings", 1.0)
        table.insert(state.warnings, "Some health checks failed")
        vim.defer_fn(function() callback(true) end, 500) -- Continue anyway
      end
    end, 500)
  end, 800)
end

-- ASYNC Phase 5: Welcome Setup
local function phase_welcome(callback)
  state.phase_start_time = vim.fn.reltime()
  update_progress_ui("Finalizing installation...", 0.2)

  -- Mark installation as complete
  local version_mod = require("core.version")
  version_mod.store_version()

  update_progress_ui("Saving configuration state...", 0.5)

  vim.defer_fn(function()
    -- Calculate installation time
    local duration = state.start_time and vim.fn.reltimefloat(vim.fn.reltime(state.start_time)) or 0
    local plugin_count = vim.tbl_count(require("plugins.manage").plugins)
    local rust_status = vim.fn.executable("cargo") == 1 and "Available" or "Not Available"

    update_progress_ui("Generating installation summary...", 0.8)

    vim.defer_fn(function()
      -- Show final summary in UI
      local summary_lines = {
        "",
        string.format("  %s Installation Complete!", icons.status.success),
        "",
        string.format("  %s Version: v%s", icons.status.info, version_mod.config_version),
        string.format("  %s Plugins: %d installed", icons.status.gear, plugin_count),
        string.format("  %s Rust Tools: %s", icons.status.rocket, rust_status),
        string.format("  %s Duration: %.1fs", icons.status.clock, duration),
        "",
        string.format("  %s Errors: %d", #state.errors > 0 and icons.status.error or icons.status.success, #state.errors),
        string.format("  %s Warnings: %d", #state.warnings > 0 and icons.status.warning or icons.status.success, #state.warnings),
        "",
        "  Press any key to exit and restart VelocityNvim...",
      }

      -- Update UI with final summary
      if state.ui_buffer and vim.api.nvim_buf_is_valid(state.ui_buffer) then
        vim.api.nvim_buf_set_option(state.ui_buffer, 'modifiable', true)
        vim.api.nvim_buf_set_lines(state.ui_buffer, 0, -1, false, summary_lines)
        vim.api.nvim_buf_set_option(state.ui_buffer, 'modifiable', false)
        vim.cmd('redraw')
      end

      -- Wait for user input or timeout
      vim.defer_fn(function()
        cleanup_progress_ui()
        state.is_running = false

        -- Show final message in command line
        print(string.format("%s VelocityNvim Installation Complete! Restart to use.", icons.status.success))

        callback(true)

        -- Auto-exit after delay
        vim.defer_fn(function()
          vim.cmd("qall!")
        end, 2000)
      end, 3000)
    end, 800)
  end, 500)
end

-- STABLE Main installation orchestrator - no race conditions
function M.run_installation()
  if state.is_running then
    return -- Prevent concurrent installations
  end

  state.is_running = true
  state.start_time = vim.fn.reltime()
  state.current_phase = 1
  state.errors = {}
  state.warnings = {}

  -- Initialize UI
  create_progress_ui()

  -- ASYNC phase execution chain with callbacks
  local phases = {
    { name = "Compatibility Check", func = phase_compatibility, critical = true },
    { name = "Plugin Installation", func = phase_plugins, critical = true },
    { name = "Rust Performance Build", func = phase_rust, critical = false },
    { name = "Health Verification", func = phase_health, critical = false },
    { name = "Welcome Setup", func = phase_welcome, critical = false },
  }

  -- Sequential phase execution with proper error handling
  local function run_phase(phase_index)
    if phase_index > #phases then
      -- All phases complete
      state.is_running = false
      return
    end

    local phase = phases[phase_index]
    state.current_phase = phase_index

    -- Run phase with callback
    phase.func(function(success)
      if not success and phase.critical then
        -- Critical failure - stop installation
        local error_msg = string.format("Installation failed in %s phase", phase.name)
        update_progress_ui(error_msg, 1.0)

        vim.defer_fn(function()
          cleanup_progress_ui()
          vim.notify("VelocityNvim installation failed. Check errors and try again.", vim.log.levels.ERROR)
          state.is_running = false
        end, 3000)
        return
      end

      -- Continue to next phase
      vim.defer_fn(function()
        run_phase(phase_index + 1)
      end, 200)
    end)
  end

  -- Start the installation chain
  update_progress_ui("Starting VelocityNvim installation...", 0)
  vim.defer_fn(function()
    run_phase(1)
  end, 500)
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
