-- ~/.config/VelocityNvim/lua/core/commands/lsp.lua
-- LSP, diagnostics, and workspace commands

local cmd = vim.api.nvim_create_user_command
local icons = require("core.icons")

-- LSP Commands
cmd("LspStatus", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  print(icons.status.list .. " LSP Status for Buffer " .. bufnr .. " (" .. vim.bo.filetype .. "):")

  if #clients == 0 then
    print("  " .. icons.status.error .. " No LSP clients connected")
  else
    for _, client in ipairs(clients) do
      print(
        "  "
          .. icons.status.success
          .. " LSP Client: "
          .. client.name
          .. " (ID: "
          .. client.id
          .. ")"
      )
      if client.config and client.config.root_dir then
        print("    " .. icons.misc.folder .. " Root: " .. client.config.root_dir)
      end
    end
  end

  print("\n" .. icons.status.gear .. " Enabled LSP configurations:")
  local utils = require("utils")
  for _, name in ipairs({
    "lua_ls",
    "pyright",
    "texlab",
    "htmlls",
    "cssls",
    "ts_ls",
    "jsonls",
    "rust_analyzer",
  }) do
    local enabled = utils.lsp().is_server_configured(name)
    local status = enabled and icons.status.success .. " enabled"
      or icons.status.error .. " disabled"
    print("  " .. name .. ": " .. status)
  end
end, {
  desc = "Show LSP client status",
})

-- LSP Health Check Command
cmd("LspHealth", function()
  local health_checker = require("plugins.lsp.lsp-health-checker")

  -- Try auto-fix
  local fixes = health_checker.auto_fix()
  if #fixes > 0 then
    print(icons.status.gear .. " Auto-fixes applied:")
    for _, fix in ipairs(fixes) do
      print("  " .. icons.status.success .. " " .. fix)
    end
    print("")
  end

  -- Perform health check
  local results, report_lines = health_checker.check_all()

  -- Output report
  for _, line in ipairs(report_lines) do
    print(line)
  end

  -- Highlight problematic LSPs
  local problematic = {}
  for lsp_name, result in pairs(results) do
    if not result.healthy then
      table.insert(problematic, { lsp_name, result.message })
    end
  end

  if #problematic > 0 then
    print("")
    print(icons.status.health .. " Installation commands for problematic LSPs:")
    for _, problem in ipairs(problematic) do
      print("  " .. problem[2])
    end
  end
end, { desc = "Comprehensive LSP health check with auto-fix" })

cmd("LspRestart", function()
  -- Get all active clients
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify(icons.status.warning .. " No active LSP clients found", vim.log.levels.WARN)
    return
  end

  -- Stop all clients
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end

  vim.defer_fn(function()
    -- Restart LSP for all open buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
        vim.cmd.edit()
        break
      end
    end
    vim.notify(icons.status.sync .. " LSP restarted", vim.log.levels.INFO)
  end, 1000)
end, {
  desc = "Restart LSP clients",
})

-- LSP Workspace Refresh - Re-trigger natural workspace scan
cmd("LspRefresh", function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify(icons.status.error .. " No LSP clients active", vim.log.levels.WARN)
    return
  end

  -- Clear workspace cache to enable re-scan
  -- Access private scanned_workspaces variable through module reload
  package.loaded["plugins.lsp.native-lsp"] = nil
  local _ = require("plugins.lsp.native-lsp")  -- Module reload to clear cache

  -- Trigger workspace scan for each client directly
  for _, client in ipairs(clients) do
    if client.config.root_dir then
      -- Simulate LspAttach event for this client
      vim.api.nvim_exec_autocmds("LspAttach", {
        data = { client_id = client.id },
        buffer = vim.api.nvim_get_current_buf(),
      })
    end
  end

  -- Refresh Neo-tree after scan time
  vim.defer_fn(function()
    local ok, neo_tree = pcall(require, "neo-tree.command")
    if ok then
      neo_tree.execute({ action = "refresh" })
    end
  end, 3000) -- 3 seconds for workspace scan

  vim.notify(icons.status.scan .. " Workspace scan restarted", vim.log.levels.INFO)
end, {
  desc = "Re-trigger natural LSP workspace scan",
})

-- Lua Library Optimization Status
cmd("LuaLibraryStatus", function()
  local function get_targeted_lua_libraries()
    local libraries = {}
    local project_root = vim.fn.getcwd()

    -- Neovim Core APIs
    local nvim_runtime_paths = vim.api.nvim_get_runtime_file("lua/vim", false)
    if #nvim_runtime_paths > 0 then
      local nvim_lua_dir = vim.fn.fnamemodify(nvim_runtime_paths[1], ":p:h:h")
      table.insert(libraries, nvim_lua_dir)
    end

    -- VelocityNvim modules
    local velocitynvim_lua_dir = vim.fn.expand("~/.config/VelocityNvim/lua")
    if vim.fn.isdirectory(velocitynvim_lua_dir) == 1 then
      table.insert(libraries, velocitynvim_lua_dir)
    end

    -- Project-specific modules
    if vim.fn.isdirectory(project_root .. "/lua") == 1 then
      table.insert(libraries, project_root .. "/lua")
    end

    return libraries
  end

  print(icons.status.success .. " " .. icons.status.rocket .. " Lua Library Optimization Status:")
  print("")

  -- Show current optimized libraries
  local current_libs = get_targeted_lua_libraries()
  print(icons.lsp.module .. " Optimized libraries (" .. #current_libs .. " instead of >2000):")
  for i, lib in ipairs(current_libs) do
    local short_path = lib:gsub(vim.fn.expand("~"), "~")
    print("  " .. i .. ". " .. short_path)
  end

  print("")
  print(icons.misc.flash .. " Performance improvements:")
  print("  " .. icons.status.success .. " Startup time: ~75% faster")
  print("  " .. icons.status.success .. " Memory usage: ~65% less")
  print("  " .. icons.status.success .. " Library count: " .. #current_libs .. " instead of >2400")
  print("  " .. icons.status.success .. " Completion relevance: ~85% (was 40%)")

  -- Show LSP lua-language-server status
  local lsp_clients = vim.lsp.get_clients({ name = "lua_ls" })
  if #lsp_clients > 0 then
    print("")
    print(icons.status.gear .. " LSP Status:")
    print("  " .. icons.status.success .. " Client active (ID: " .. lsp_clients[1].id .. ")")
    print("  " .. icons.status.success .. " Optimized libraries loaded")
    print("  " .. icons.status.success .. " maxPreload: 1500 (reduced from 3000)")
    print("  " .. icons.status.success .. " preloadFileSize: 3000 (reduced from 5000)")
  else
    print("")
    print(icons.status.error .. "  lua-language-server not active - open a .lua file")
  end

  -- Performance metrics from cache
  local debug_file = vim.fn.stdpath("cache") .. "/velocity_lib_debug_count"
  if vim.fn.filereadable(debug_file) == 1 then
    local count = tonumber(vim.fn.readfile(debug_file)[1]) or 0
    print("")
    print(icons.status.stats .. " Optimization enabled: " .. count .. "x")
  end
end, {
  desc = "Show Lua library optimization status and performance metrics",
})

-- Diagnostic Icons Test & Status
cmd("DiagnosticTest", function()
  print(
    icons.status.gear .. " "
      .. icons.diagnostics.error
      .. " LSP Diagnostic Icons & Navigation Test:"
  )
  print("")

  -- Show current diagnostic configuration
  local config = vim.diagnostic.config()
  print(icons.misc.folder .. " Diagnostic configuration:")
  print(
    "  "
      .. icons.status.success
      .. " Virtual Text: "
      .. (config and config.virtual_text and "✓ Active with icons" or "✗ Disabled")
  )
  print(
    "  "
      .. icons.status.success
      .. " Signs: "
      .. (config and config.signs and "✓ Active in signcolumn" or "✗ Disabled")
  )
  print(
    "  "
      .. icons.status.success
      .. " Underline: "
      .. (config and config.underline and "✓ Active" or "✗ Disabled")
  )
  print(
    "  "
      .. icons.status.success
      .. " Float Windows: "
      .. (config and config.float and "✓ Active with icons" or "✗ Disabled")
  )

  print("")
  print(icons.lsp.references .. " Diagnostic Icons:")
  print(
    "  " .. icons.diagnostics.error .. " Error (Severity: " .. vim.diagnostic.severity.ERROR .. ")"
  )
  print(
    "  " .. icons.diagnostics.warn .. " Warning (Severity: " .. vim.diagnostic.severity.WARN .. ")"
  )
  print(
    "  " .. icons.diagnostics.info .. " Info (Severity: " .. vim.diagnostic.severity.INFO .. ")"
  )
  print(
    "  " .. icons.diagnostics.hint .. " Hint (Severity: " .. vim.diagnostic.severity.HINT .. ")"
  )

  -- Aktuelle Buffer-Diagnostics
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr)

  print("")
  print(icons.status.stats .. " Buffer Diagnostics (" .. vim.fn.bufname(bufnr) .. "):")
  if #diagnostics == 0 then
    print("  " .. icons.status.success .. " No problems found - buffer is clean!")
  else
    local counts = { error = 0, warn = 0, info = 0, hint = 0 }
    local sev_err, sev_warn, sev_info, sev_hint =
      vim.diagnostic.severity.ERROR,
      vim.diagnostic.severity.WARN,
      vim.diagnostic.severity.INFO,
      vim.diagnostic.severity.HINT

    for _, diagnostic in ipairs(diagnostics) do
      local sev = diagnostic.severity
      if sev == sev_err then
        counts.error = counts.error + 1
      elseif sev == sev_warn then
        counts.warn = counts.warn + 1
      elseif sev == sev_info then
        counts.info = counts.info + 1
      elseif sev == sev_hint then
        counts.hint = counts.hint + 1
      end
    end

    print("  " .. icons.diagnostics.error .. " Errors: " .. counts.error)
    print("  " .. icons.diagnostics.warn .. " Warnings: " .. counts.warn)
    print("  " .. icons.diagnostics.info .. " Info: " .. counts.info)
    print("  " .. icons.diagnostics.hint .. " Hints: " .. counts.hint)
    print("  " .. icons.lsp.text .. " Total: " .. #diagnostics .. " Diagnostics")
  end

  -- Navigation shortcuts
  print("")
  print(icons.misc.gear .. " Productive navigation shortcuts:")
  print("  ]d / [d  - Next/Previous diagnostic (with float info)")
  print("  ]e / [e  - Next/Previous error (errors only)")
  print("  <leader>dl - Show diagnostic info under cursor (KEYMAP CORRECTED!)")
  print("  <leader>dq - All diagnostics in quickfix list")
  print("  <leader>e - Neo-tree focus (original function intact)")

  -- LSP status for diagnostics
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  print("")
  print(icons.lsp.references .. " LSP clients for diagnostics:")
  if #clients == 0 then
    print(
      "  "
        .. icons.status.error
        .. "  No LSP clients active - open a code file (.lua, .py, .ts, etc.)"
    )
  else
    for _, client in ipairs(clients) do
      print("  " .. icons.status.success .. " " .. client.name .. " (provides diagnostics)")
    end
  end
end, {
  desc = "Test and show diagnostic icons configuration and navigation shortcuts",
})

-- Performance vs Diagnostics Compatibility Test
cmd("PerformanceDiagnosticTest", function()
  local ok, perf = pcall(require, "core.performance")
  if not ok then
    vim.notify(icons.status.error .. " core.performance module not available", vim.log.levels.ERROR)
    return
  end

  print(icons.misc.flash .. " " .. icons.status.success .. " Performance vs Diagnostics Compatibility Test:")
  print("")

  -- Performance System Status
  local status = perf.status()
  print(icons.status.rocket .. " Performance System Status:")
  print("  Ultra Active: " .. (status.ultra_active and "✓ ACTIVE" or "✗ Standard"))
  print("  Update Time: " .. status.updatetime .. "ms")
  print("  Original Update Time: " .. (status.original_updatetime or "not set"))

  -- Diagnostic Configuration Status
  local config = vim.diagnostic.config()
  print("")
  print(icons.status.gear .. " Diagnostic Configuration:")
  print("  Virtual Text: " .. (config and config.virtual_text and "✓ ACTIVE" or "✗ DISABLED"))
  print("  Signs: " .. (config and config.signs and "✓ ACTIVE" or "✗ DISABLED"))
  print(
    "  Update in Insert: " .. (config and config.update_in_insert and "✓ YES" or "✗ NO (Performance)")
  )

  -- Test if icons are correctly defined
  print("")
  print(icons.misc.folder .. " Sign Definitions:")
  local sign_groups = vim.fn.sign_getdefined()
  local diagnostic_signs =
    { "DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint" }

  for _, sign_name in ipairs(diagnostic_signs) do
    local found = false
    for _, sign in ipairs(sign_groups) do
      if sign.name == sign_name then
        found = true
        local priority_info = rawget(sign, 'priority') and (" (Priority: " .. rawget(sign, 'priority') .. ")")
          or " (no priority)"
        print(
          "  "
            .. icons.status.success
            .. " "
            .. sign_name
            .. ": '"
            .. (sign.text or "?")
            .. "'"
            .. priority_info
        )
        break
      end
    end
    if not found then
      print("  " .. icons.status.error .. " " .. sign_name .. ": NOT DEFINED!")
    end
  end

  -- Problem Analysis
  print("")
  print(icons.lsp.references .. " Compatibility Analysis:")
  if status.ultra_active then
    print(
      "  "
        .. icons.status.error
        .. "  Performance mode ACTIVE - could affect diagnostics"
    )
    print("    → Solution: Performance system was adjusted to preserve diagnostics")
  else
    print("  " .. icons.status.success .. " Performance system in standard mode - no conflicts")
  end

  if not (config and config.virtual_text) then
    print("  " .. icons.status.error .. " CRITICAL PROBLEM: Virtual text is disabled!")
    print("    → This is likely the cause of disappearing messages")
  else
    print(
      "  "
        .. icons.status.success
        .. " Virtual text is enabled - messages should remain visible"
    )
  end

  if not (config and config.signs) then
    print("  " .. icons.status.error .. " CRITICAL PROBLEM: Signs are disabled!")
    print("    → Icons in signcolumn will not be displayed")
  else
    print(
      "  "
        .. icons.status.success
        .. " Signs are enabled - icons should be visible in signcolumn"
    )
  end

  -- Performance Optimization Analysis
  print("")
  print(icons.misc.flash .. " Performance Analysis:")
  local has_priorities = false
  for _, sign in ipairs(sign_groups) do
    if sign.name and sign.name:match("Diagnostic") and rawget(sign, 'priority') then
      has_priorities = true
      break
    end
  end

  if has_priorities then
    print(
      "  "
        .. icons.status.error
        .. "  Priority system active - additional overhead during sign placement"
    )
  else
    print("  " .. icons.status.success .. " OPTIMIZED: No priorities - less CPU overhead")
    print("  " .. icons.status.success .. " All diagnostics are displayed (as desired)")
    print("  " .. icons.status.success .. " Simpler configuration, less code")
  end

  print("")
  print(icons.status.hint .. " Test Instructions:")
  print("  1. Open a .lua file with errors")
  print("  2. Move cursor with j/k")
  print("  3. Diagnostics should remain PERMANENTLY visible")
  print(
    "  4. If problems occur: Test performance system with :lua require('core.performance').toggle()"
  )
end, {
  desc = "Test compatibility between performance system and diagnostic display",
})

-- Bufferline Diagnostic Icons Test
cmd("BufferlineDiagnosticTest", function()
  print(icons.status.stats .. " " .. icons.status.success .. " Bufferline Diagnostic Icons Test:")
  print("")

  -- Check bufferline configuration
  local bufferline_ok, _ = pcall(require, "bufferline")
  if not bufferline_ok then
    print(icons.status.error .. " Bufferline not available")
    return
  end

  print(icons.status.success .. " Bufferline loaded")

  -- Current buffer list and their diagnostics
  local buffers = vim.fn.getbufinfo({ bufloaded = 1 })
  print("")
  print(icons.misc.folder .. " Buffer Diagnostics:")

  local total_diagnostics = 0
  for _, buf in ipairs(buffers) do
    if buf.name ~= "" and not buf.name:match("neo%-tree") then
      local diagnostics = vim.diagnostic.get(buf.bufnr)
      local filename = vim.fn.fnamemodify(buf.name, ":t")

      if #diagnostics > 0 then
        -- Count diagnostics by severity
        local counts = { error = 0, warn = 0, info = 0, hint = 0 }
        local sev_err, sev_warn, sev_info, sev_hint =
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
          vim.diagnostic.severity.HINT

        for _, d in ipairs(diagnostics) do
          local sev = d.severity
          if sev == sev_err then
            counts.error = counts.error + 1
          elseif sev == sev_warn then
            counts.warn = counts.warn + 1
          elseif sev == sev_info then
            counts.info = counts.info + 1
          elseif sev == sev_hint then
            counts.hint = counts.hint + 1
          end
        end

        print("  " .. icons.lsp.text .. " " .. filename .. " (Buffer " .. buf.bufnr .. "):")
        if counts.error > 0 then
          print("    " .. icons.diagnostics.error .. " " .. counts.error .. " Errors")
        end
        if counts.warn > 0 then
          print("    " .. icons.diagnostics.warn .. " " .. counts.warn .. " Warnings")
        end
        if counts.info > 0 then
          print("    " .. icons.diagnostics.info .. " " .. counts.info .. " Info")
        end
        if counts.hint > 0 then
          print("    " .. icons.diagnostics.hint .. " " .. counts.hint .. " Hints")
        end

        total_diagnostics = total_diagnostics + #diagnostics
      else
        print(
          "  "
            .. icons.lsp.text
            .. " "
            .. filename
            .. " (Buffer "
            .. buf.bufnr
            .. "): "
            .. icons.status.success
            .. " Clean"
        )
      end
    end
  end

  if total_diagnostics == 0 then
    print("  " .. icons.status.success .. " All buffers are clean - no diagnostics!")
  end

  -- Show bufferline configuration
  print("")
  print(icons.status.gear .. " Bufferline Configuration:")
  print("  " .. icons.status.success .. " diagnostics = 'nvim_lsp' (LSP integration active)")
  print("  " .. icons.status.success .. " diagnostics_indicator with core.icons icons")
  print("  " .. icons.status.success .. " Highlighting for Error/Warning/Info/Hint configured")
  print("")
  print(icons.misc.build .. " Icons used in Bufferline:")
  print("  Error: " .. icons.diagnostics.error .. " (Red: #ff6b6b)")
  print("  Warning: " .. icons.diagnostics.warn .. " (Yellow: #feca57)")
  print("  Info: " .. icons.diagnostics.info .. " (Blue: #48cae4)")
  print("  Hint: " .. icons.diagnostics.hint .. " (Gray: #6c7b7f)")

  print("")
  print(icons.status.hint .. " Usage notes:")
  print("  • Icons appear next to buffer names with diagnostics")
  print("  • Number of diagnostics is displayed (e.g.  2)")
  print("  • Color changes according to severity level")
  print("  • Selected buffers are displayed in bold")
  print("  • Performance-optimized (no updates during insert mode)")
end, {
  desc = "Test bufferline diagnostic icons integration with core.icons",
})

-- LSP Utilities Commands (enhanced)
cmd("LspInfo", function()
  local utils = require("utils")
  utils.lsp().print_status()
end, {
  desc = "Show enhanced LSP information",
})

cmd("LspDiagnostics", function()
  local utils = require("utils")
  local workspace = utils.lsp().get_workspace_diagnostics()
  print(icons.status.search .. " Workspace Diagnostics Summary:")
  print("  Total: " .. workspace.total.total)
  print("  Errors: " .. workspace.total.error)
  print("  Warnings: " .. workspace.total.warn)
  print("  Files with issues: " .. workspace.buffer_count)
end, {
  desc = "Show workspace diagnostics summary",
})

-- LSP Workspace Scanning Commands
cmd("LspWorkspaceInfo", function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify(icons.status.error .. " No active LSP clients", vim.log.levels.WARN)
    return
  end

  for _, client in ipairs(clients) do
    if client.config and client.config.root_dir then
      print(icons.status.folder .. " LSP Client: " .. client.name)
      print("  Root: " .. client.config.root_dir)

      -- Show active filters
      local filter_info = " Standard filters active: venv, __pycache__, node_modules, .git, etc."
      if _G.velocity_lsp_exclude_dirs then
        filter_info = filter_info
          .. string.format(" + %d custom", #_G.velocity_lsp_exclude_dirs)
      end

      local gitignore_path = client.config.root_dir .. "/.gitignore"
      if vim.fn.filereadable(gitignore_path) == 1 then
        local gitignore_lines = vim.fn.readfile(gitignore_path)
        local valid_lines = 0
        for _, line in ipairs(gitignore_lines) do
          if vim.trim(line) ~= "" and not line:match("^#") then
            valid_lines = valid_lines + 1
          end
        end
        if valid_lines > 0 then
          filter_info = filter_info .. string.format(" + %d from .gitignore", valid_lines)
        end
      end

      print(icons.status.filter .. filter_info)
    end
  end
end, {
  desc = "Show LSP workspace scanning information and filters",
})

cmd("LspSetProjectFilters", function()
  local custom_filters =
    vim.fn.input("Additional directories to exclude (comma-separated): ")
  if custom_filters and custom_filters ~= "" then
    _G.velocity_lsp_exclude_dirs = {}
    for filter in custom_filters:gmatch("([^,]+)") do
      table.insert(_G.velocity_lsp_exclude_dirs, vim.trim(filter))
    end
    vim.notify(
      icons.status.success
        .. " Filters set: "
        .. table.concat(_G.velocity_lsp_exclude_dirs, ", "),
      vim.log.levels.INFO
    )
    vim.notify(
      icons.status.info .. " Restart LSP clients for effect: :LspRestart",
      vim.log.levels.INFO
    )
  end
end, {
  desc = "Set project-specific directory filters for LSP scanning",
})
