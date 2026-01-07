-- ~/.config/VelocityNvim/lua/core/first-run.lua
-- Automated First-Run Installation System for VelocityNvim
-- FIXED: Race conditions, UI flickering, blocking operations
-- NEW: Optional package selection (Strudel, LaTeX, Typst)

local M = {}
local icons = require("core.icons")

-- Installation phases with improved timing
local PHASES = {
  { name = "System Detection", key = "sysdetect", duration = 1.0 },
  { name = "Dependency Setup", key = "sysdeps", duration = 0 }, -- User interaction for system deps
  { name = "Compatibility Check", key = "compat", duration = 1.5 },
  { name = "Package Selection", key = "selection", duration = 0 }, -- User interaction
  { name = "Plugin Installation", key = "plugins", duration = 0 }, -- Variable based on plugin count
  { name = "Treesitter Parsers", key = "treesitter", duration = 30.0 }, -- Parser compilation
  { name = "Rust Performance Build", key = "rust", duration = 3.0 },
  { name = "Optional Dependencies", key = "optional_deps", duration = 2.0 }, -- npm install for Strudel etc.
  { name = "Health Verification", key = "health", duration = 1.0 },
  { name = "Welcome Setup", key = "welcome", duration = 1.0 },
}

-- Path for installation warnings log
local WARNINGS_LOG_PATH = vim.fn.stdpath("data") .. "/installation-warnings.log"

-- Save warnings to file for later viewing
local function save_warnings_to_file()
  if #state.warnings == 0 and #state.errors == 0 then
    -- Remove old log file if no warnings
    if vim.fn.filereadable(WARNINGS_LOG_PATH) == 1 then
      vim.fn.delete(WARNINGS_LOG_PATH)
    end
    return
  end

  local lines = {
    "===============================================================================",
    "VelocityNvim Installation Log - " .. os.date("%Y-%m-%d %H:%M:%S"),
    "===============================================================================",
    "",
  }

  if #state.errors > 0 then
    table.insert(lines, "ERRORS:")
    table.insert(lines, string.rep("-", 40))
    for _, err in ipairs(state.errors) do
      table.insert(lines, "  " .. err)
    end
    table.insert(lines, "")
  end

  if #state.warnings > 0 then
    table.insert(lines, "WARNINGS (Missing Dependencies):")
    table.insert(lines, string.rep("-", 40))
    for _, warn in ipairs(state.warnings) do
      table.insert(lines, "  " .. warn)
    end
    table.insert(lines, "")
    table.insert(lines, "INSTALLATION COMMANDS:")
    table.insert(lines, string.rep("-", 40))
    table.insert(lines, "")
    table.insert(lines, "# Arch Linux (pacman):")
    for _, warn in ipairs(state.warnings) do
      local pacman_cmd = warn:match("pacman %-S [%w%-]+")
      if pacman_cmd then
        table.insert(lines, "sudo " .. pacman_cmd)
      end
    end
    table.insert(lines, "")
    table.insert(lines, "# macOS (Homebrew):")
    for _, warn in ipairs(state.warnings) do
      local brew_cmd = warn:match("brew install [%w%-]+")
      if brew_cmd then
        table.insert(lines, brew_cmd)
      end
    end
    table.insert(lines, "")
    table.insert(lines, "# Cargo (Rust):")
    for _, warn in ipairs(state.warnings) do
      local cargo_cmd = warn:match("cargo install [%w%-]+")
      if cargo_cmd then
        table.insert(lines, cargo_cmd)
      end
    end
  end

  table.insert(lines, "")
  table.insert(lines, "===============================================================================")
  table.insert(lines, "View this file anytime with:  :InstallationLog")
  table.insert(lines, "===============================================================================")

  vim.fn.writefile(lines, WARNINGS_LOG_PATH)
end

-- Get warnings log path (for external access)
M.get_warnings_log_path = function()
  return WARNINGS_LOG_PATH
end

-- STABLE state tracking - no race conditions
local state = {
  current_phase = 1,
  total_phases = 10, -- Updated to include system detection + dependency setup phases
  phase_progress = 0, -- 0.0 to 1.0 within current phase
  errors = {},
  warnings = {},
  start_time = nil,
  is_running = false,
  phase_start_time = nil,
  ui_buffer = nil,
  ui_window = nil,
  selection_cursor = 1, -- For UI navigation
}

-- STABLE progress display with dedicated UI window
local function create_progress_ui()
  if state.ui_buffer and vim.api.nvim_buf_is_valid(state.ui_buffer) then
    return -- Already exists
  end

  -- Create dedicated buffer for progress
  state.ui_buffer = vim.api.nvim_create_buf(false, true)
  vim.bo[state.ui_buffer].bufhidden = 'wipe'
  vim.bo[state.ui_buffer].buftype = 'nofile'
  vim.bo[state.ui_buffer].swapfile = false
  vim.bo[state.ui_buffer].modifiable = false

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
  vim.wo[state.ui_window].cursorline = false
  vim.wo[state.ui_window].number = false
  vim.wo[state.ui_window].relativenumber = false
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
  vim.bo[state.ui_buffer].modifiable = true
  vim.api.nvim_buf_set_lines(state.ui_buffer, 0, -1, false, lines)
  vim.bo[state.ui_buffer].modifiable = false

  -- Force redraw only once
  vim.api.nvim_command('redraw')
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

-- Store detected system info for later phases
local detected_system = nil

-- ASYNC Phase 0a: System Detection
local function phase_sysdetect(callback)
  state.phase_start_time = vim.fn.reltime()
  update_progress_ui("Detecting operating system...", 0)

  local sysdeps_ok, sysdeps = pcall(require, "core.system-deps")
  if not sysdeps_ok then
    update_progress_ui("System dependency module not found", 1.0)
    vim.defer_fn(function() callback(true) end, 500)
    return
  end

  vim.defer_fn(function()
    update_progress_ui("Analyzing system configuration...", 0.3)

    detected_system = sysdeps.detect_os()

    vim.defer_fn(function()
      update_progress_ui("Checking installed packages...", 0.6)

      vim.defer_fn(function()
        local status = sysdeps.get_status()
        local os_info = string.format("%s (%s)", detected_system.distro, detected_system.pkg_manager or "unknown")

        update_progress_ui(string.format("Detected: %s - %d packages missing", os_info, status.total_missing), 1.0)

        vim.defer_fn(function() callback(true) end, 800)
      end, 500)
    end, 500)
  end, 300)
end

-- ASYNC Phase 0b: System Dependency Installation UI
local function phase_sysdeps(callback)
  state.phase_start_time = vim.fn.reltime()

  local sysdeps_ok, sysdeps = pcall(require, "core.system-deps")
  if not sysdeps_ok then
    callback(true)
    return
  end

  if not detected_system then
    detected_system = sysdeps.detect_os()
  end

  -- Check if package manager is available
  if not detected_system.pkg_manager then
    update_progress_ui("No supported package manager found - skipping", 1.0)
    table.insert(state.warnings, "No package manager detected (pacman/apt/dnf/brew)")
    vim.defer_fn(function() callback(true) end, 1000)
    return
  end

  -- Create selection UI
  local width = 90
  local height = 30
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create buffer for selection
  local sel_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[sel_buf].bufhidden = 'wipe'
  vim.bo[sel_buf].buftype = 'nofile'
  vim.bo[sel_buf].swapfile = false

  -- Create window
  local sel_win = vim.api.nvim_open_win(sel_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' VelocityNvim - System Dependencies ',
    title_pos = 'center'
  })

  -- Track selection state
  local current_screen = "profile" -- "profile", "custom", "confirm"
  local selected_profile = "standard"
  local selected_categories = {}
  local cursor_pos = 2 -- 1-indexed, default to "standard"

  -- Profile definitions
  local profiles = {
    { key = "minimal", name = "Minimal", desc = "Core functionality only (editor + search)" },
    { key = "standard", name = "Standard (Recommended)", desc = "Full development environment" },
    { key = "full", name = "Full", desc = "Everything including LaTeX, Typst, web tools" },
    { key = "custom", name = "Custom", desc = "Choose individual package categories" },
    { key = "skip", name = "Skip", desc = "Skip system dependency installation" },
  }

  -- Category order for custom selection
  local category_order = { "core", "search", "clipboard", "git_tools", "rust", "nodejs", "lsp", "formatters", "pdf", "latex", "typst", "web", "strudel" }

  -- Initialize custom selection from standard profile
  for _, cat in ipairs(sysdeps.profiles.standard.categories) do
    selected_categories[cat] = true
  end

  -- Get status for display
  local status = sysdeps.get_status()

  -- Render profile selection screen
  local function render_profile_screen()
    local lines = {
      "",
      string.format("  %s VelocityNvim First-Run Setup", icons.status.rocket),
      "",
      string.format("  Detected: %s (%s)", detected_system.distro:upper(), detected_system.pkg_manager),
      string.format("  Missing packages: %d | Installed: %d", status.total_missing, status.total_installed),
      "",
      "  " .. string.rep("─", width - 6),
      "",
      "  Choose an installation profile:",
      "",
    }

    for i, profile in ipairs(profiles) do
      local cursor = (i == cursor_pos) and " ▶ " or "   "
      local checkbox = ""
      if profile.key == selected_profile then
        checkbox = "[●] "
      else
        checkbox = "[ ] "
      end

      if profile.key == "skip" then
        table.insert(lines, "")
      end

      table.insert(lines, string.format("%s%s%s", cursor, checkbox, profile.name))
      table.insert(lines, string.format("       %s", profile.desc))

      -- Show included categories for non-skip profiles
      if profile.key ~= "skip" and profile.key ~= "custom" and sysdeps.profiles[profile.key] then
        local cats = table.concat(sysdeps.profiles[profile.key].categories, ", ")
        table.insert(lines, string.format("       Categories: %s", cats))
      end
      table.insert(lines, "")
    end

    table.insert(lines, "  " .. string.rep("─", width - 6))
    table.insert(lines, "")
    table.insert(lines, "  [j/k] Navigate  |  [Enter/Space] Select  |  [q] Skip installation")
    table.insert(lines, "")

    vim.bo[sel_buf].modifiable = true
    vim.api.nvim_buf_set_lines(sel_buf, 0, -1, false, lines)
    vim.bo[sel_buf].modifiable = false
  end

  -- Render custom category selection screen
  local function render_custom_screen()
    local lines = {
      "",
      string.format("  %s Custom Package Selection", icons.status.gear),
      "",
      "  Select which package categories to install:",
      "",
      "  " .. string.rep("─", width - 6),
      "",
    }

    for i, cat_name in ipairs(category_order) do
      local cat = sysdeps.packages[cat_name]
      if cat then
        local cursor = (i == cursor_pos) and " ▶ " or "   "
        local checkbox = selected_categories[cat_name] and "[x]" or "[ ]"
        local required = cat.required and " (required)" or ""

        -- Count installed/missing
        local cat_status = status.categories[cat_name]
        local status_str = ""
        if cat_status then
          if cat_status.missing > 0 then
            status_str = string.format(" [%d missing]", cat_status.missing)
          else
            status_str = " [all installed]"
          end
        end

        table.insert(lines, string.format("%s%s %s%s%s", cursor, checkbox, cat.title, required, status_str))
        table.insert(lines, string.format("       %s", cat.description))
        table.insert(lines, "")
      end
    end

    table.insert(lines, "  " .. string.rep("─", width - 6))
    table.insert(lines, "")
    table.insert(lines, "  [j/k] Navigate  |  [Space] Toggle  |  [a] All  |  [n] None  |  [Enter] Continue")
    table.insert(lines, "")

    vim.bo[sel_buf].modifiable = true
    vim.api.nvim_buf_set_lines(sel_buf, 0, -1, false, lines)
    vim.bo[sel_buf].modifiable = false
  end

  -- Render confirmation screen with install commands
  local function render_confirm_screen()
    local categories = {}
    if selected_profile == "custom" then
      for cat, enabled in pairs(selected_categories) do
        if enabled then
          table.insert(categories, cat)
        end
      end
    elseif selected_profile ~= "skip" and sysdeps.profiles[selected_profile] then
      categories = sysdeps.profiles[selected_profile].categories
    end

    local missing = sysdeps.get_missing_packages(categories)

    local lines = {
      "",
      string.format("  %s Installation Summary", icons.status.info),
      "",
      string.format("  Profile: %s", selected_profile:upper()),
      string.format("  Packages to install: %d", #missing),
      "",
      "  " .. string.rep("─", width - 6),
      "",
    }

    if #missing == 0 then
      table.insert(lines, "  All required packages are already installed!")
      table.insert(lines, "")
    else
      table.insert(lines, "  Missing packages:")
      table.insert(lines, "")

      -- Group by category
      local by_category = {}
      for _, pkg in ipairs(missing) do
        by_category[pkg.category_title] = by_category[pkg.category_title] or {}
        table.insert(by_category[pkg.category_title], pkg.name)
      end

      for cat_title, pkgs in pairs(by_category) do
        table.insert(lines, string.format("    %s: %s", cat_title, table.concat(pkgs, ", ")))
      end
      table.insert(lines, "")

      -- Show install command
      local script, _ = sysdeps.generate_install_script(categories)
      if script then
        table.insert(lines, "  Installation will run these commands:")
        table.insert(lines, "")

        -- Extract key commands from script
        for line in script:gmatch("[^\n]+") do
          if line:match("^sudo") or line:match("^brew") or line:match("^npm") or line:match("^cargo") or line:match("^pip") or line:match("^curl") then
            table.insert(lines, "    " .. line:sub(1, width - 8))
          end
        end
      end
    end

    table.insert(lines, "")
    table.insert(lines, "  " .. string.rep("─", width - 6))
    table.insert(lines, "")

    if #missing > 0 then
      table.insert(lines, "  [i] Install now  |  [c] Copy commands  |  [b] Back  |  [s] Skip")
    else
      table.insert(lines, "  [Enter] Continue  |  [b] Back")
    end
    table.insert(lines, "")

    vim.bo[sel_buf].modifiable = true
    vim.api.nvim_buf_set_lines(sel_buf, 0, -1, false, lines)
    vim.bo[sel_buf].modifiable = false
  end

  -- Render current screen
  local function render()
    if current_screen == "profile" then
      render_profile_screen()
    elseif current_screen == "custom" then
      render_custom_screen()
    elseif current_screen == "confirm" then
      render_confirm_screen()
    end
  end

  -- Navigation functions
  local function move_cursor(delta)
    local max_pos
    if current_screen == "profile" then
      max_pos = #profiles
    elseif current_screen == "custom" then
      max_pos = #category_order
    else
      return
    end

    cursor_pos = cursor_pos + delta
    if cursor_pos < 1 then cursor_pos = max_pos end
    if cursor_pos > max_pos then cursor_pos = 1 end
    render()
  end

  local function select_current()
    if current_screen == "profile" then
      selected_profile = profiles[cursor_pos].key
      if selected_profile == "custom" then
        current_screen = "custom"
        cursor_pos = 1
      elseif selected_profile == "skip" then
        finish_selection(true)
        return
      else
        current_screen = "confirm"
      end
      render()
    elseif current_screen == "custom" then
      -- Move to confirm
      current_screen = "confirm"
      render()
    end
  end

  local function toggle_category()
    if current_screen == "custom" then
      local cat_name = category_order[cursor_pos]
      if cat_name then
        local cat = sysdeps.packages[cat_name]
        -- Don't allow deselecting required categories
        if cat and not cat.required then
          selected_categories[cat_name] = not selected_categories[cat_name]
        end
        render()
      end
    end
  end

  local function select_all_categories()
    if current_screen == "custom" then
      for _, cat_name in ipairs(category_order) do
        selected_categories[cat_name] = true
      end
      render()
    end
  end

  local function select_no_categories()
    if current_screen == "custom" then
      for _, cat_name in ipairs(category_order) do
        local cat = sysdeps.packages[cat_name]
        if cat and not cat.required then
          selected_categories[cat_name] = false
        end
      end
      render()
    end
  end

  local function go_back()
    if current_screen == "custom" then
      current_screen = "profile"
      cursor_pos = 4 -- Custom option
    elseif current_screen == "confirm" then
      if selected_profile == "custom" then
        current_screen = "custom"
        cursor_pos = 1
      else
        current_screen = "profile"
        cursor_pos = 1
      end
    end
    render()
  end

  local function copy_commands()
    if current_screen == "confirm" then
      local categories = {}
      if selected_profile == "custom" then
        for cat, enabled in pairs(selected_categories) do
          if enabled then table.insert(categories, cat) end
        end
      elseif sysdeps.profiles[selected_profile] then
        categories = sysdeps.profiles[selected_profile].categories
      end

      local script, _ = sysdeps.generate_install_script(categories)
      if script then
        vim.fn.setreg("+", script)
        vim.fn.setreg("*", script)
        vim.notify("Install commands copied to clipboard!", vim.log.levels.INFO)
      end
    end
  end

  local function run_installation()
    if current_screen == "confirm" then
      local categories = {}
      if selected_profile == "custom" then
        for cat, enabled in pairs(selected_categories) do
          if enabled then table.insert(categories, cat) end
        end
      elseif sysdeps.profiles[selected_profile] then
        categories = sysdeps.profiles[selected_profile].categories
      end

      local missing = sysdeps.get_missing_packages(categories)
      if #missing == 0 then
        finish_selection(false)
        return
      end

      -- Close selection window
      if vim.api.nvim_win_is_valid(sel_win) then
        vim.api.nvim_win_close(sel_win, true)
      end

      -- Generate and save install script
      local script, _ = sysdeps.generate_install_script(categories)
      if script then
        local script_path = vim.fn.stdpath("data") .. "/velocity-install-deps.sh"
        -- Add continuation message to script
        local script_with_msg = script .. '\necho ""\necho "══════════════════════════════════════════════════════════════"\necho "  Installation complete! Press ENTER to continue VelocityNvim setup..."\necho "══════════════════════════════════════════════════════════════"\nread'
        vim.fn.writefile(vim.split(script_with_msg, "\n"), script_path)
        vim.fn.setfperm(script_path, "rwxr-xr-x")

        -- Close progress UI temporarily
        cleanup_progress_ui()

        -- Run in terminal split - user can enter sudo password
        vim.cmd("botright split | terminal bash " .. script_path)

        -- Auto-close terminal and continue when done
        vim.api.nvim_create_autocmd("TermClose", {
          buffer = vim.api.nvim_get_current_buf(),
          once = true,
          callback = function()
            -- Close the terminal buffer
            vim.cmd("bdelete!")
            -- Refresh status and continue
            status = sysdeps.get_status()
            vim.defer_fn(function()
              callback(true)
            end, 500)
          end,
        })

        -- Enter terminal mode for immediate input
        vim.cmd("startinsert")
        return
      else
        finish_selection(false)
      end
    end
  end

  -- Finish and close
  function finish_selection(skipped)
    if vim.api.nvim_win_is_valid(sel_win) then
      vim.api.nvim_win_close(sel_win, true)
    end
    if vim.api.nvim_buf_is_valid(sel_buf) then
      vim.api.nvim_buf_delete(sel_buf, { force = true })
    end

    if skipped then
      update_progress_ui("System dependency installation skipped", 1.0)
    else
      update_progress_ui("System dependency setup complete", 1.0)
    end

    vim.defer_fn(function()
      callback(true)
    end, 500)
  end

  -- Set up keymaps
  local opts = { buffer = sel_buf, noremap = true, silent = true }
  vim.keymap.set('n', 'j', function() move_cursor(1) end, opts)
  vim.keymap.set('n', 'k', function() move_cursor(-1) end, opts)
  vim.keymap.set('n', '<Down>', function() move_cursor(1) end, opts)
  vim.keymap.set('n', '<Up>', function() move_cursor(-1) end, opts)
  vim.keymap.set('n', '<CR>', select_current, opts)
  vim.keymap.set('n', '<Space>', function()
    if current_screen == "custom" then
      toggle_category()
    else
      select_current()
    end
  end, opts)
  vim.keymap.set('n', 'a', select_all_categories, opts)
  vim.keymap.set('n', 'n', select_no_categories, opts)
  vim.keymap.set('n', 'b', go_back, opts)
  vim.keymap.set('n', 'c', copy_commands, opts)
  vim.keymap.set('n', 'i', run_installation, opts)
  vim.keymap.set('n', 's', function() finish_selection(true) end, opts)
  vim.keymap.set('n', 'q', function() finish_selection(true) end, opts)
  vim.keymap.set('n', '<Esc>', function()
    if current_screen ~= "profile" then
      go_back()
    else
      finish_selection(true)
    end
  end, opts)

  -- Initial render
  render()

  -- Focus the selection window
  vim.api.nvim_set_current_win(sel_win)
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
            -- Check Neovim version directly
            local nvim_ver = vim.version()
            local required = { major = 0, minor = 11, patch = 0 }
            local compat = nvim_ver.major > required.major or
                          (nvim_ver.major == required.major and nvim_ver.minor >= required.minor)
            if not compat then
              table.insert(state.errors, string.format("Neovim >= %d.%d.%d required (got %d.%d.%d)",
                required.major, required.minor, required.patch,
                nvim_ver.major, nvim_ver.minor, nvim_ver.patch))
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

-- ASYNC Phase 2: Optional Package Selection
local function phase_selection(callback)
  state.phase_start_time = vim.fn.reltime()

  local manage_ok, manage = pcall(require, "plugins.manage")
  if not manage_ok then
    -- Skip selection if manage.lua not available
    callback(true)
    return
  end

  -- Get optional packages info
  local packages = manage.optional_packages
  if not packages or vim.tbl_count(packages) == 0 then
    callback(true)
    return
  end

  -- Create selection UI
  local width = 80
  local height = 20
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create buffer for selection
  local sel_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[sel_buf].bufhidden = 'wipe'
  vim.bo[sel_buf].buftype = 'nofile'
  vim.bo[sel_buf].swapfile = false

  -- Create window
  local sel_win = vim.api.nvim_open_win(sel_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' VelocityNvim - Optional Packages ',
    title_pos = 'center'
  })

  -- Track selection state
  local selected = {}
  local package_keys = vim.tbl_keys(packages)
  table.sort(package_keys)  -- Consistent order

  -- Initialize all as unselected
  for _, key in ipairs(package_keys) do
    selected[key] = false
  end

  -- Render function
  local function render_selection()
    local lines = {
      "",
      "  Select optional packages for your installation:",
      "  (Navigate with j/k, toggle with Space/Enter, finish with q/Esc)",
      "",
      "  " .. string.rep("-", width - 6),
      "",
    }

    for i, key in ipairs(package_keys) do
      local pkg = packages[key]
      local checkbox = selected[key] and "[x]" or "[ ]"
      local cursor_indicator = (i == state.selection_cursor) and " > " or "   "

      -- Package name and checkbox
      table.insert(lines, string.format("%s%s %s", cursor_indicator, checkbox, pkg.name))

      -- Description (indented)
      table.insert(lines, string.format("       %s", pkg.description))

      -- Dependencies
      local deps = table.concat(pkg.dependencies, ", ")
      table.insert(lines, string.format("       Requires: %s", deps))
      table.insert(lines, "")
    end

    table.insert(lines, "  " .. string.rep("-", width - 6))
    table.insert(lines, "")
    table.insert(lines, "  [Space/Enter] Toggle  |  [a] All  |  [n] None  |  [q/Esc] Done")
    table.insert(lines, "")

    vim.bo[sel_buf].modifiable = true
    vim.api.nvim_buf_set_lines(sel_buf, 0, -1, false, lines)
    vim.bo[sel_buf].modifiable = false
  end

  -- Initialize cursor
  state.selection_cursor = 1

  -- Initial render
  render_selection()

  -- Key mappings for selection
  local function toggle_current()
    local key = package_keys[state.selection_cursor]
    if key then
      selected[key] = not selected[key]
      render_selection()
    end
  end

  local function move_cursor(delta)
    state.selection_cursor = state.selection_cursor + delta
    if state.selection_cursor < 1 then
      state.selection_cursor = #package_keys
    elseif state.selection_cursor > #package_keys then
      state.selection_cursor = 1
    end
    render_selection()
  end

  local function select_all()
    for _, key in ipairs(package_keys) do
      selected[key] = true
    end
    render_selection()
  end

  local function select_none()
    for _, key in ipairs(package_keys) do
      selected[key] = false
    end
    render_selection()
  end

  local function finish_selection()
    -- Collect selected packages
    local selected_list = {}
    for key, is_selected in pairs(selected) do
      if is_selected then
        table.insert(selected_list, key)
      end
    end

    -- Save configuration
    local config = {
      selected = selected_list,
      configured = true,
    }
    manage.save_optional_config(config)

    -- Close selection window
    if vim.api.nvim_win_is_valid(sel_win) then
      vim.api.nvim_win_close(sel_win, true)
    end
    if vim.api.nvim_buf_is_valid(sel_buf) then
      vim.api.nvim_buf_delete(sel_buf, { force = true })
    end

    -- Update progress UI
    local selected_count = #selected_list
    local msg = selected_count > 0
      and string.format("%d optional packages selected", selected_count)
      or "No optional packages selected"
    update_progress_ui(msg, 1.0)

    vim.defer_fn(function()
      callback(true)
    end, 500)
  end

  -- Set up keymaps
  local opts = { buffer = sel_buf, noremap = true, silent = true }
  vim.keymap.set('n', 'j', function() move_cursor(1) end, opts)
  vim.keymap.set('n', 'k', function() move_cursor(-1) end, opts)
  vim.keymap.set('n', '<Down>', function() move_cursor(1) end, opts)
  vim.keymap.set('n', '<Up>', function() move_cursor(-1) end, opts)
  vim.keymap.set('n', '<Space>', toggle_current, opts)
  vim.keymap.set('n', '<CR>', toggle_current, opts)
  vim.keymap.set('n', 'a', select_all, opts)
  vim.keymap.set('n', 'n', select_none, opts)
  vim.keymap.set('n', 'q', finish_selection, opts)
  vim.keymap.set('n', '<Esc>', finish_selection, opts)

  -- Focus the selection window
  vim.api.nvim_set_current_win(sel_win)
end

-- ASYNC Phase 3: Plugin Installation
local function phase_plugins(callback)
  state.phase_start_time = vim.fn.reltime()

  local manage_ok, manage = pcall(require, "plugins.manage")
  if not manage_ok then
    table.insert(state.errors, "Plugin manager not found")
    callback(false)
    return
  end

  -- Use get_all_plugins() to include optional packages based on user selection
  local all_plugins = manage.get_all_plugins()
  local plugins = vim.tbl_keys(all_plugins)
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
    local url = all_plugins[name]
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

-- ASYNC Phase 3a: Treesitter Parser Installation
local function phase_treesitter(callback)
  state.phase_start_time = vim.fn.reltime()

  -- Check if GCC/Clang is available for compilation
  local has_compiler = vim.fn.executable("gcc") == 1 or vim.fn.executable("clang") == 1 or vim.fn.executable("cc") == 1
  if not has_compiler then
    update_progress_ui("No C compiler found - skipping Treesitter parsers", 0.5)
    table.insert(state.warnings, "No C compiler (gcc/clang) - Treesitter parsers not compiled. Install: pacman -S gcc")
    vim.defer_fn(function()
      update_progress_ui("Treesitter phase completed (skipped)", 1.0)
      vim.defer_fn(function() callback(true) end, 500)
    end, 1000)
    return
  end

  -- Essential parsers to install
  local parsers = { "lua", "vim", "vimdoc", "markdown", "markdown_inline", "python", "javascript", "typescript", "html", "css", "json", "bash", "rust", "toml", "yaml" }
  local parser_count = #parsers
  local current_index = 0
  local success_count = 0

  update_progress_ui("Installing Treesitter parsers (this may take a few minutes)...", 0)

  -- Install parsers one by one with jobstart
  local function install_next_parser()
    current_index = current_index + 1

    if current_index > parser_count then
      -- All parsers processed
      local final_message = string.format("Treesitter: %d/%d parsers installed", success_count, parser_count)
      update_progress_ui(final_message, 1.0)

      if success_count < parser_count then
        table.insert(state.warnings, string.format("Only %d/%d Treesitter parsers compiled", success_count, parser_count))
      end

      vim.defer_fn(function()
        callback(true)
      end, 500)
      return
    end

    local parser_name = parsers[current_index]
    local progress = current_index / parser_count

    update_progress_ui(string.format("Compiling parser %d/%d: %s", current_index, parser_count, parser_name), progress)

    -- Use TSInstall command via jobstart to compile parser
    local ts_ok, ts_install = pcall(require, "nvim-treesitter.install")
    if ts_ok and ts_install and ts_install.install then
      -- Call install function
      local install_ok = pcall(function()
        ts_install.install(parser_name)
      end)

      if install_ok then
        -- Wait for compilation (parser compilation takes time)
        vim.defer_fn(function()
          -- Check if parser was installed
          local parser_dir = vim.fn.stdpath("data") .. "/site/pack/user/start/nvim-treesitter/parser/"
          local parser_file = parser_dir .. parser_name .. ".so"
          if vim.fn.filereadable(parser_file) == 1 then
            success_count = success_count + 1
          end
          install_next_parser()
        end, 3000) -- Wait 3 seconds per parser for compilation
      else
        -- Installation failed, continue to next
        vim.defer_fn(install_next_parser, 100)
      end
    else
      -- Treesitter not available, skip
      table.insert(state.warnings, "nvim-treesitter not available for parser installation")
      vim.defer_fn(function()
        update_progress_ui("Treesitter not available - skipping parser installation", 1.0)
        vim.defer_fn(function() callback(true) end, 500)
      end, 500)
    end
  end

  -- Start parser installation chain
  vim.defer_fn(install_next_parser, 500)
end

-- ASYNC Phase 4: Rust Performance Build
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

-- ASYNC Phase 4a: Optional Package Dependencies (Strudel npm, LaTeX/Typst system tools)
local function phase_optional_deps(callback)
  state.phase_start_time = vim.fn.reltime()

  local manage_ok, manage = pcall(require, "plugins.manage")
  if not manage_ok then
    callback(true)
    return
  end

  local has_strudel = manage.is_feature_enabled("strudel")
  local has_latex = manage.is_feature_enabled("latex")
  local has_typst = manage.is_feature_enabled("typst")

  -- No optional packages selected
  if not has_strudel and not has_latex and not has_typst then
    callback(true)
    return
  end

  local missing_deps = {}

  -- Check LaTeX dependencies
  if has_latex then
    update_progress_ui("Checking LaTeX dependencies...", 0.1)
    if vim.fn.executable("texlab") == 0 then
      table.insert(missing_deps, "texlab (LaTeX LSP) - install: pacman -S texlab / brew install texlab")
    end
    if vim.fn.executable("latexmk") == 0 then
      table.insert(missing_deps, "latexmk (LaTeX build) - install: pacman -S texlive-binextra / brew install mactex")
    end
    if vim.fn.executable("pdflatex") == 0 then
      table.insert(missing_deps, "pdflatex (LaTeX compiler) - install: pacman -S texlive-basic / brew install mactex")
    end
  end

  -- Check Typst dependencies
  if has_typst then
    update_progress_ui("Checking Typst dependencies...", 0.2)
    if vim.fn.executable("tinymist") == 0 then
      table.insert(missing_deps, "tinymist (Typst LSP) - install: cargo install tinymist / pacman -S tinymist")
    end
    if vim.fn.executable("typst") == 0 then
      table.insert(missing_deps, "typst (Typst compiler) - install: cargo install typst-cli / pacman -S typst")
    end
  end

  -- Check Strudel dependencies
  if has_strudel then
    update_progress_ui("Checking Strudel dependencies...", 0.3)
    if vim.fn.executable("npm") == 0 then
      table.insert(missing_deps, "npm (Node.js) - install: pacman -S nodejs-lts-iron npm / brew install node")
    end
    -- Check for browser
    local has_browser = vim.fn.executable("chromium") == 1
      or vim.fn.executable("google-chrome-stable") == 1
      or vim.fn.executable("brave") == 1
      or vim.fn.executable("firefox") == 1
    if not has_browser then
      table.insert(missing_deps, "chromium/brave/chrome (Browser) - install: pacman -S chromium / brew install chromium")
    end
  end

  -- Report missing dependencies
  if #missing_deps > 0 then
    for _, dep in ipairs(missing_deps) do
      table.insert(state.warnings, "Missing: " .. dep)
    end
    update_progress_ui(string.format("%d missing system dependencies (see warnings)", #missing_deps), 0.4)
  end

  -- Install Strudel npm dependencies if npm is available
  if has_strudel and vim.fn.executable("npm") == 1 then
    local strudel_path = vim.fn.stdpath("data") .. "/site/pack/user/start/strudel.nvim"

    if vim.fn.isdirectory(strudel_path) == 1 and vim.fn.filereadable(strudel_path .. "/package.json") == 1 then
      update_progress_ui("Installing Strudel npm dependencies...", 0.5)

      -- ASYNC npm ci using jobstart
      vim.fn.jobstart({ "npm", "ci" }, {
        cwd = strudel_path,
        on_stdout = function(_, data)
          if data and #data > 0 and data[1] ~= "" then
            update_progress_ui("Installing npm packages...", 0.7)
          end
        end,
        on_stderr = function(_, data)
          if data and #data > 0 and data[1] ~= "" then
            update_progress_ui("npm install in progress...", 0.8)
          end
        end,
        on_exit = function(_, exit_code)
          if exit_code == 0 then
            update_progress_ui("Strudel dependencies installed successfully", 1.0)
          else
            update_progress_ui("Strudel npm install failed - check npm logs", 1.0)
            table.insert(state.warnings, "Strudel npm dependencies failed to install")
          end
          vim.defer_fn(function() callback(true) end, 500)
        end,
        stdout_buffered = false,
        stderr_buffered = false,
      })
      return -- Wait for npm to finish
    end
  end

  -- No npm install needed, finish phase
  if #missing_deps > 0 then
    update_progress_ui("Dependency check complete - some tools missing", 1.0)
  else
    update_progress_ui("All optional dependencies available", 1.0)
  end
  vim.defer_fn(function() callback(true) end, 500)
end

-- ASYNC Phase 5: Health Verification
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
    local _ = {}  -- Health results collection placeholder

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

  -- Installation complete - no version tracking needed
  update_progress_ui("Installation complete...", 0.5)

  vim.defer_fn(function()
    -- Calculate installation time
    local duration = state.start_time and vim.fn.reltimefloat(vim.fn.reltime(state.start_time)) or 0
    local manage = require("plugins.manage")
    local plugin_count = vim.tbl_count(manage.get_all_plugins())
    local rust_status = vim.fn.executable("cargo") == 1 and "Available" or "Not Available"

    update_progress_ui("Generating installation summary...", 0.8)

    vim.defer_fn(function()
      -- Show final summary in UI
      local summary_lines = {
        "",
        string.format("  %s Installation Complete!", icons.status.success),
        "",
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
        vim.bo[state.ui_buffer].modifiable = true
        vim.api.nvim_buf_set_lines(state.ui_buffer, 0, -1, false, summary_lines)
        vim.bo[state.ui_buffer].modifiable = false
        vim.api.nvim_command('redraw')
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
          vim.api.nvim_command("qall!")
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
    { name = "System Detection", func = phase_sysdetect, critical = false },
    { name = "Dependency Setup", func = phase_sysdeps, critical = false },
    { name = "Compatibility Check", func = phase_compatibility, critical = true },
    { name = "Package Selection", func = phase_selection, critical = false },
    { name = "Plugin Installation", func = phase_plugins, critical = true },
    { name = "Treesitter Parsers", func = phase_treesitter, critical = false },
    { name = "Rust Performance Build", func = phase_rust, critical = false },
    { name = "Optional Dependencies", func = phase_optional_deps, critical = false },
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
  -- Check if plugins directory exists
  local plugins_dir = vim.fn.stdpath("data") .. "/site/pack/user/start"
  return vim.fn.isdirectory(plugins_dir) == 0
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

    for name, _ in pairs(manage.plugins) do
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
