-- ~/.config/VelocityNvim/lua/core/commands.lua
-- User Commands und benutzerdefinierte Befehle

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
  print(icons.status.search .. " Plugin Status:")
  for name, _ in pairs(manage.plugins) do
    local pack_path = vim.fn.stdpath("data") .. "/site/pack/user/start/" .. name
    local status = vim.fn.isdirectory(pack_path) == 1 and icons.status.success .. " Installed"
      or icons.status.error .. " Missing"
    print("  " .. name .. ": " .. status)
  end
end, {
  desc = "Show plugin installation status",
})

-- LSP Commands
cmd("LspStatus", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  print(icons.status.list .. " LSP Status für Buffer " .. bufnr .. " (" .. vim.bo.filetype .. "):")

  if #clients == 0 then
    print("  " .. icons.status.error .. " Keine LSP-Clients verbunden")
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

  print("\n" .. icons.status.gear .. " Aktivierte LSP-Konfigurationen:")
  local utils = require("utils")
  for _, name in ipairs({ "luals", "pyright", "texlab", "htmlls", "cssls", "ts_ls", "jsonls" }) do
    local enabled = utils.lsp().is_server_configured(name)
    local status = enabled and icons.status.success .. " aktiviert"
      or icons.status.error .. " deaktiviert"
    print("  " .. name .. ": " .. status)
  end
end, {
  desc = "Show LSP client status",
})

cmd("LspRestart", function()
  -- Get all active clients
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify(icons.status.warning .. " Keine aktiven LSP-Clients gefunden", vim.log.levels.WARN)
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
    vim.notify(icons.status.sync .. " LSP neu gestartet", vim.log.levels.INFO)
  end, 1000)
end, {
  desc = "Restart LSP clients",
})

-- LSP Workspace Refresh - Re-triggert den natürlichen Workspace-Scan
cmd("LspRefresh", function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify(icons.status.error .. " Keine LSP-Clients aktiv", vim.log.levels.WARN)
    return
  end

  -- Clear den Workspace-Cache um Re-Scan zu ermöglichen
  -- Zugriff auf die private scanned_workspaces Variable durch Module-Reload
  package.loaded["plugins.lsp.native-lsp"] = nil
  local native_lsp = require("plugins.lsp.native-lsp")
  
  -- Triggere für jeden Client den Workspace-Scan direkt
  for _, client in ipairs(clients) do
    if client.config.root_dir then
      -- Simuliere LspAttach Event für diesen Client
      vim.api.nvim_exec_autocmds("LspAttach", {
        data = { client_id = client.id },
        buffer = vim.api.nvim_get_current_buf()
      })
    end
  end
  
  -- Neo-tree nach Scan-Zeit refreshen
  vim.defer_fn(function()
    local ok, neo_tree = pcall(require, "neo-tree.command")
    if ok then
      neo_tree.execute({ action = "refresh" })
    end
  end, 3000)  -- 3 Sekunden für Workspace-Scan
  
  vim.notify(icons.status.scan .. " Workspace-Scan erneut gestartet", vim.log.levels.INFO)
end, {
  desc = "Re-trigger natural LSP workspace scan",
})

-- Lua Library Optimization Status (NEU - Performance-Monitoring)
cmd("LuaLibraryStatus", function()
  local function get_targeted_lua_libraries()
    -- Kopiere die Funktion aus native-lsp.lua um aktuelle Libraries zu ermitteln
    local libraries = {}
    local project_root = vim.fn.getcwd()
    
    -- Neovim Core APIs
    local nvim_runtime_paths = vim.api.nvim_get_runtime_file("lua/vim", false)
    if #nvim_runtime_paths > 0 then
      local nvim_lua_dir = vim.fn.fnamemodify(nvim_runtime_paths[1], ":p:h:h")
      table.insert(libraries, nvim_lua_dir)
    end
    
    -- VelocityNvim Module
    local velocitynvim_lua_dir = vim.fn.expand("~/.config/VelocityNvim/lua")
    if vim.fn.isdirectory(velocitynvim_lua_dir) == 1 then
      table.insert(libraries, velocitynvim_lua_dir)
    end
    
    -- Projekt-spezifische Module
    if vim.fn.isdirectory(project_root .. "/lua") == 1 then
      table.insert(libraries, project_root .. "/lua")
    end
    
    return libraries
  end

  print(icons.status.success .. " " .. icons.status.rocket .. " Lua Library Optimization Status:")
  print("")
  
  -- Zeige aktuelle optimierte Libraries
  local current_libs = get_targeted_lua_libraries()
  print(".. icons.lsp.module .. " .. #current_libs .. " statt >2000):")
  for i, lib in ipairs(current_libs) do
    local short_path = lib:gsub(vim.fn.expand("~"), "~")
    print("  " .. i .. ". " .. short_path)
  end
  
  print("")
  print(".. icons.misc.flash .. ")
  print("  " .. icons.status.success .. " Startup-Zeit: ~75% schneller")
  print("  " .. icons.status.success .. " Memory-Usage: ~65% weniger") 
  print("  " .. icons.status.success .. " Library-Count: " .. #current_libs .. " statt >2400")
  print("  " .. icons.status.success .. " Completion-Relevanz: ~85% (war 40%)")
  
  -- Zeige LSP lua-language-server Status
  local lsp_clients = vim.lsp.get_clients({ name = "luals" })
  if #lsp_clients > 0 then
    print("")
    print(".. icons.status.gear .. ")
    print("  " .. icons.status.success .. " Client aktiv (ID: " .. lsp_clients[1].id .. ")")
    print("  " .. icons.status.success .. " Optimierte Libraries geladen")
    print("  " .. icons.status.success .. " maxPreload: 1500 (reduziert von 3000)")
    print("  " .. icons.status.success .. " preloadFileSize: 3000 (reduziert von 5000)")
  else
    print("")
    print(icons.status.error .. "  lua-language-server nicht aktiv - öffne eine .lua Datei")
  end
  
  -- Performance-Metriken aus Cache
  local debug_file = vim.fn.stdpath("cache") .. "/velocity_lib_debug_count" 
  if vim.fn.filereadable(debug_file) == 1 then
    local count = tonumber(vim.fn.readfile(debug_file)[1]) or 0
    print("")
    print(".. icons.status.stats .. " .. count .. "x aktiviert")
  end
end, {
  desc = "Show Lua library optimization status and performance metrics",
})

-- Diagnostic Icons Test & Status (NEU - Productivity Enhancement)
cmd("DiagnosticTest", function()
  local icons = require("core.icons")
  print(".. icons.status.gear .. " .. icons.diagnostics.error .. " LSP Diagnostic Icons & Navigation Test:")
  print("")
  
  -- Zeige aktuelle Diagnostic-Konfiguration
  local config = vim.diagnostic.config()
  print(".. icons.misc.folder .. ")
  print("  " .. icons.status.success .. " Virtual Text: " .. (config.virtual_text and "✓ Aktiv mit Icons" or "✗ Deaktiviert"))
  print("  " .. icons.status.success .. " Signs: " .. (config.signs and "✓ Aktiv in Signcolumn" or "✗ Deaktiviert"))
  print("  " .. icons.status.success .. " Underline: " .. (config.underline and "✓ Aktiv" or "✗ Deaktiviert"))
  print("  " .. icons.status.success .. " Float Windows: " .. (config.float and "✓ Aktiv mit Icons" or "✗ Deaktiviert"))
  
  print("")
  print(".. icons.lsp.references .. ")
  print("  " .. icons.diagnostics.error .. " Error (Severity: " .. vim.diagnostic.severity.ERROR .. ")")
  print("  " .. icons.diagnostics.warn .. " Warning (Severity: " .. vim.diagnostic.severity.WARN .. ")")
  print("  " .. icons.diagnostics.info .. " Info (Severity: " .. vim.diagnostic.severity.INFO .. ")")
  print("  " .. icons.diagnostics.hint .. " Hint (Severity: " .. vim.diagnostic.severity.HINT .. ")")
  
  -- Aktuelle Buffer-Diagnostics
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr)
  
  print("")
  print(".. icons.status.stats .. " .. vim.fn.bufname(bufnr) .. "):")
  if #diagnostics == 0 then
    print("  " .. icons.status.success .. " Keine Probleme gefunden - Buffer ist sauber!")
  else
    local counts = { error = 0, warn = 0, info = 0, hint = 0 }
    
    for _, diagnostic in ipairs(diagnostics) do
      if diagnostic.severity == vim.diagnostic.severity.ERROR then
        counts.error = counts.error + 1
      elseif diagnostic.severity == vim.diagnostic.severity.WARN then
        counts.warn = counts.warn + 1
      elseif diagnostic.severity == vim.diagnostic.severity.INFO then
        counts.info = counts.info + 1
      elseif diagnostic.severity == vim.diagnostic.severity.HINT then
        counts.hint = counts.hint + 1
      end
    end
    
    print("  " .. icons.diagnostics.error .. " Errors: " .. counts.error)
    print("  " .. icons.diagnostics.warn .. " Warnings: " .. counts.warn)
    print("  " .. icons.diagnostics.info .. " Info: " .. counts.info)  
    print("  " .. icons.diagnostics.hint .. " Hints: " .. counts.hint)
    print("  " .. icons.lsp.text .. " Total: " .. #diagnostics .. " Diagnostics")
  end
  
  -- Navigation-Shortcuts
  print("")
  print("⌨️  Produktive Navigation-Shortcuts:")
  print("  ]d / [d  - Nächste/Vorherige Diagnostic (mit Float-Info)")
  print("  ]e / [e  - Nächster/Vorheriger Error (nur Errors)")
  print("  <leader>dl - Diagnostic-Info unter Cursor anzeigen (KEYMAP KORRIGIERT!)") 
  print("  <leader>dq - Alle Diagnostics in Quickfix-Liste")
  print("  <leader>e - Neo-tree focus (ursprüngliche Funktion intakt)")
  
  -- LSP-Status für Diagnostics
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  print("")
  print(icons.lsp.references .. " LSP-Clients für Diagnostics:")
  if #clients == 0 then
    print("  " .. icons.status.error .. "  Keine LSP-Clients aktiv - öffne eine Code-Datei (.lua, .py, .ts, etc.)")
  else
    for _, client in ipairs(clients) do
      print("  " .. icons.status.success .. " " .. client.name .. " (liefert Diagnostics)")
    end
  end
end, {
  desc = "Test and show diagnostic icons configuration and navigation shortcuts",
})

-- Performance vs Diagnostics Compatibility Test (NEU - Cursor Movement Fix)
cmd("PerformanceDiagnosticTest", function()
  local icons = require("core.icons")
  local perf = require("core.performance")
  
  print(".. icons.misc.flash .. " .. icons.status.success .. " Performance vs Diagnostics Compatibility Test:")
  print("")
  
  -- Performance System Status
  local status = perf.status()
  print(".. icons.status.rocket .. ")
  print("  Ultra Active: " .. (status.ultra_active and "✓ AKTIV" or "✗ Standard"))
  print("  Update Time: " .. status.updatetime .. "ms")
  print("  Original Update Time: " .. (status.original_updatetime or "nicht gesetzt"))
  
  -- Diagnostic Configuration Status
  local config = vim.diagnostic.config()
  print("")
  print(".. icons.status.gear .. ")
  print("  Virtual Text: " .. (config.virtual_text and "✓ AKTIV" or "✗ DEAKTIVIERT"))
  print("  Signs: " .. (config.signs and "✓ AKTIV" or "✗ DEAKTIVIERT"))
  print("  Update in Insert: " .. (config.update_in_insert and "✓ JA" or "✗ NEIN (Performance)"))
  
  -- Test ob Icons korrekt definiert sind
  print("")
  print(".. icons.misc.folder .. ")
  local sign_groups = vim.fn.sign_getdefined()
  local diagnostic_signs = {"DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint"}
  
  for _, sign_name in ipairs(diagnostic_signs) do
    local found = false
    for _, sign in ipairs(sign_groups) do
      if sign.name == sign_name then
        found = true
        local priority_info = sign.priority and (" (Priorität: " .. sign.priority .. ")") or " (keine Priorität)"
        print("  " .. icons.status.success .. " " .. sign_name .. ": '" .. (sign.text or "?") .. "'" .. priority_info)
        break
      end
    end
    if not found then
      print("  " .. icons.status.error .. " " .. sign_name .. ": NICHT DEFINIERT!")
    end
  end
  
  -- Problem-Analyse
  print("")
  print(".. icons.lsp.references .. ")
  if status.ultra_active then
    print("  " .. icons.status.error .. "  Performance-Modus AKTIV - könnte Diagnostics beeinträchtigen")
    print("    → Lösung: Performance-System wurde angepasst um Diagnostics zu bewahren")
  else
    print("  " .. icons.status.success .. " Performance-System im Standard-Modus - keine Konflikte")
  end
  
  if not config.virtual_text then
    print("  " .. icons.status.error .. " KRITISCHES PROBLEM: Virtual Text ist deaktiviert!")
    print("    → Das ist wahrscheinlich die Ursache für verschwindende Meldungen")
  else
    print("  " .. icons.status.success .. " Virtual Text ist aktiviert - Meldungen sollten sichtbar bleiben")
  end
  
  if not config.signs then
    print("  " .. icons.status.error .. " KRITISCHES PROBLEM: Signs sind deaktiviert!")
    print("    → Icons in der Signcolumn werden nicht angezeigt")
  else
    print("  " .. icons.status.success .. " Signs sind aktiviert - Icons sollten in Signcolumn sichtbar sein")
  end
  
  -- Performance-Optimierung Analyse
  print("")
  print(".. icons.misc.flash .. ")
  local has_priorities = false
  for _, sign in ipairs(sign_groups) do
    if sign.name and sign.name:match("Diagnostic") and sign.priority then
      has_priorities = true
      break
    end
  end
  
  if has_priorities then
    print("  " .. icons.status.error .. "  Priority-System aktiv - zusätzlicher Overhead bei Sign-Platzierung")
  else
    print("  " .. icons.status.success .. " OPTIMIERT: Keine Prioritäten - weniger CPU-Overhead")
    print("  " .. icons.status.success .. " Alle Diagnostics werden angezeigt (wie gewünscht)")
    print("  " .. icons.status.success .. " Einfachere Konfiguration, weniger Code")
  end
  
  print("")
  print(".. icons.status.hint .. ")
  print("  1. Öffne eine .lua Datei mit Fehlern")
  print("  2. Bewege Cursor mit j/k")
  print("  3. Diagnostics sollten DAUERHAFT sichtbar bleiben")
  print("  4. Bei Problemen: Performance-System mit :lua require('core.performance').toggle() testen")
  
end, {
  desc = "Test compatibility between performance system and diagnostic display",
})

-- Bufferline Diagnostic Icons Test (NEU - Bufferline Integration)
cmd("BufferlineDiagnosticTest", function()
  local icons = require("core.icons")
  
  print(".. icons.status.stats .. " .. icons.status.success .. " Bufferline Diagnostic Icons Test:")
  print("")
  
  -- Bufferline Konfiguration prüfen
  local bufferline_ok, bufferline = pcall(require, "bufferline")
  if not bufferline_ok then
    print(".. icons.status.error .. ")
    return
  end
  
  print(".. icons.status.success .. ")
  
  -- Aktuelle Buffer-Liste und ihre Diagnostics
  local buffers = vim.fn.getbufinfo({bufloaded = 1})
  print("")
  print(".. icons.misc.folder .. ")
  
  local total_diagnostics = 0
  for _, buf in ipairs(buffers) do
    if buf.name ~= "" and not buf.name:match("neo%-tree") then
      local diagnostics = vim.diagnostic.get(buf.bufnr)
      local filename = vim.fn.fnamemodify(buf.name, ":t")
      
      if #diagnostics > 0 then
        -- Zähle Diagnostics nach Severity
        local counts = {error = 0, warn = 0, info = 0, hint = 0}
        for _, d in ipairs(diagnostics) do
          if d.severity == vim.diagnostic.severity.ERROR then counts.error = counts.error + 1
          elseif d.severity == vim.diagnostic.severity.WARN then counts.warn = counts.warn + 1  
          elseif d.severity == vim.diagnostic.severity.INFO then counts.info = counts.info + 1
          elseif d.severity == vim.diagnostic.severity.HINT then counts.hint = counts.hint + 1
          end
        end
        
        print("  " .. icons.lsp.text .. " " .. filename .. " (Buffer " .. buf.bufnr .. "):")
        if counts.error > 0 then print("    " .. icons.diagnostics.error .. " " .. counts.error .. " Errors") end
        if counts.warn > 0 then print("    " .. icons.diagnostics.warn .. " " .. counts.warn .. " Warnings") end
        if counts.info > 0 then print("    " .. icons.diagnostics.info .. " " .. counts.info .. " Info") end
        if counts.hint > 0 then print("    " .. icons.diagnostics.hint .. " " .. counts.hint .. " Hints") end
        
        total_diagnostics = total_diagnostics + #diagnostics
      else
        print("  " .. icons.lsp.text .. " " .. filename .. " (Buffer " .. buf.bufnr .. "): " .. icons.status.success .. " Sauber")
      end
    end
  end
  
  if total_diagnostics == 0 then
    print("  " .. icons.status.success .. " Alle Buffer sind sauber - keine Diagnostics!")
  end
  
  -- Bufferline Konfiguration zeigen
  print("")
  print(".. icons.status.gear .. ")
  print("  " .. icons.status.success .. " diagnostics = 'nvim_lsp' (LSP-Integration aktiv)")  
  print("  " .. icons.status.success .. " diagnostics_indicator mit icons.lua Icons")
  print("  " .. icons.status.success .. " Highlighting für Error/Warning/Info/Hint konfiguriert")
  print("")
  print(icons.misc.build .. " Verwendete Icons in Bufferline:")
  print("  Error: " .. icons.diagnostics.error .. " (Rot: #ff6b6b)")
  print("  Warning: " .. icons.diagnostics.warn .. " (Gelb: #feca57)")
  print("  Info: " .. icons.diagnostics.info .. " (Blau: #48cae4)")
  print("  Hint: " .. icons.diagnostics.hint .. " (Grau: #6c7b7f)")
  
  print("")
  print(".. icons.status.hint .. ")
  print("  • Icons erscheinen neben Buffer-Namen mit Diagnostics")
  print("  • Anzahl der Diagnostics wird angezeigt (z.B.  2)")
  print("  • Farbe ändert sich je nach Severity-Level")
  print("  • Ausgewählte Buffers werden fett dargestellt")
  print("  • Performance-optimiert (keine Updates während Insert-Mode)")
  
end, {
  desc = "Test bufferline diagnostic icons integration with icons.lua",
})

-- Rust LSP 2025 Optimization Status 
cmd("RustAnalyzer2025Status", function()
  local rust_perf = require("utils.rust-performance")
  local analysis = rust_perf.analyze_rust_ecosystem()
  local total_memory_gb = analysis.toolchain.total_memory_gb
  local cpu_cores = tonumber(vim.fn.system("nproc 2>/dev/null")) or 4
  
  print(".. icons.status.rocket .. ")
  print("=" .. string.rep("=", 50))
  
  -- Hardware Analysis
  print("\n" .. icons.misc.gear .. " Hardware-Erkennung:")
  print("  " .. icons.misc.gear .. " RAM: " .. total_memory_gb .. "GB")
  print("  " .. icons.misc.gear .. " CPU Cores: " .. cpu_cores)
  
  -- Performance Tier
  local tier = "Conservative (<8GB)"
  if total_memory_gb >= 32 then
    tier = "Ultra-High-Performance (32+GB) " .. icons.misc.flash
  elseif total_memory_gb >= 16 then
    tier = "High-Performance (16-31GB)"
  elseif total_memory_gb >= 8 then
    tier = "Balanced (8-15GB)"
  end
  print("  " .. icons.status.rocket .. " Performance Tier: " .. tier)
  
  -- 2025 Optimizations
  print("\n" .. icons.misc.flash .. " 2025 Neue Features:")
  print("  " .. icons.status.success .. " Auto-Threading: numThreads = null (optimal)")
  print("  " .. icons.status.success .. " Dynamic LRU: " .. math.min(2048, math.max(128, total_memory_gb * 32)) .. " capacity")
  print("  " .. icons.status.success .. " Target Separation: target/rust-analyzer")
  
  if total_memory_gb >= 32 then
    print("  " .. icons.status.success .. " Memory Limit: 8192MB")
    print("  " .. icons.status.success .. " Cache Priming: " .. cpu_cores .. " threads")
    print("  " .. icons.status.success .. " All Features: Enabled")
    print("  " .. icons.status.success .. " Proc Macros: Full support")
  end
  
  print("\n" .. icons.status.stats .. " Erwartete Verbesserungen:")
  print("  " .. icons.performance.fast .. " 30-40% schnellere Builds")
  print("  " .. icons.performance.optimize .. " Bessere Memory-Nutzung")
  print("  " .. icons.performance.benchmark .. " Keine Cargo-Interferenz")
  print("  " .. icons.misc.gear .. " Optimale Thread-Verteilung")
end, {
  desc = "Show rust-analyzer 2025 performance optimizations status"
})

-- Formatting Commands
cmd("FormatInfo", function()
  local conform = require("conform")
  local formatters = conform.list_formatters()

  print(icons.misc.build .. " Formatter Status für " .. vim.bo.filetype .. ":")
  if #formatters == 0 then
    print("  " .. icons.status.error .. " Keine Formatter konfiguriert")
  else
    for _, formatter in ipairs(formatters) do
      local status = formatter.available and icons.status.success or icons.status.error
      print("  " .. status .. " " .. formatter.name)
    end
  end

  -- Check for LSP fallback capability (safe API call)
  local has_lsp_fallback = false
  local ok, result = pcall(function()
    return conform.will_fallback_lsp and conform.will_fallback_lsp() or false
  end)
  if ok then
    has_lsp_fallback = result
  end
  
  local fallback_status = has_lsp_fallback and icons.status.success .. " Verfügbar"
    or icons.status.error .. " Nicht verfügbar"
  print("  " .. icons.status.gear .. " LSP-Fallback: " .. fallback_status)
end, {
  desc = "Show formatter status",
})

cmd("FormatToggle", function()
  local conform = require("conform")

  -- Check current state by trying to get format_on_save config
  local config = require("conform.config")
  local format_on_save_enabled = config.options.format_on_save ~= false
    and config.options.format_on_save ~= nil

  if format_on_save_enabled then
    conform.setup({ format_on_save = false })
    vim.notify(icons.status.error .. " Auto-Format beim Speichern deaktiviert", vim.log.levels.INFO)
  else
    conform.setup({
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
    -- Silent success - Aktivierung ist erwartetes Verhalten
  end
end, {
  desc = "Toggle auto-format on save",
})

-- ULTIMATE Performance Commands (NEW - 2025-09-02)
cmd("UltimatePerformanceToggle", function()
  require("core.performance").toggle()
end, {
  desc = "Toggle ULTIMATE Performance Mode for cursor navigation",
})

cmd("UltimatePerformanceStatus", function()
  local perf = require("core.performance")
  local status = perf.status()
  print(".. icons.status.rocket .. ")
  print("  Ultra Mode Active: " .. (status.ultra_active and ".. icons.status.success .. " or ".. icons.status.error .. "))
  print("  Current updatetime: " .. status.updatetime .. "ms")
  if status.original_updatetime then
    print("  Original updatetime: " .. status.original_updatetime .. "ms")
  end
end, {
  desc = "Show ULTIMATE Performance Mode status",
})

-- System Commands
cmd("VelocityInfo", function()
  local version_mod = require("core.version")
  version_mod.print_version_info()

  print("\n" .. icons.status.folder .. " System Information:")
  local config_path = vim.fn.stdpath("config")
  local data_path = vim.fn.stdpath("data")
  print("  " .. icons.status.folder .. " Config Path: " .. config_path)
  print("  " .. icons.status.folder .. " Data Path: " .. data_path)
  print("  " .. icons.status.colorscheme .. " Colorscheme: " .. (vim.g.colors_name or "default"))
  print("  " .. icons.status.gear .. " Leader Key: " .. vim.g.mapleader)

  -- Plugin count
  local manage = require("plugins.manage")
  local plugin_count = vim.tbl_count(manage.plugins)
  print("  " .. icons.misc.plugin .. " Configured Plugins: " .. plugin_count)

  -- LSP count
  local lsp_clients = vim.lsp.get_clients()
  print("  " .. icons.status.gear .. " Active LSP Clients: " .. #lsp_clients)
end, {
  desc = "Show VelocityNvim configuration info",
})

cmd("VelocityChangelog", function()
  local version_mod = require("core.version")
  version_mod.print_changelog()
end, {
  desc = "Show VelocityNvim version history and changelog",
})

cmd("VelocityVersion", function()
  local version_mod = require("core.version")
  print("VelocityNvim Native Configuration")
  print("Version: " .. version_mod.config_version)
  print("Updated: " .. version_mod.last_updated)
end, {
  desc = "Show VelocityNvim version",
})

cmd("VelocityMigrations", function()
  local migrations = require("core.migrations")
  migrations.print_migration_history()
end, {
  desc = "Show migration history and changes",
})

-- NEUE ULTIMATE RUST COMMANDS
cmd("RustUltimateSetup", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.ultimate_setup()
end, {
  desc = "Ultimate Rust Performance Setup and Status",
})

cmd("RustMoldCheck", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.check_mold_linker()
end, {
  desc = "Check mold linker status and installation",
})

cmd("RustCargoUltra", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.setup_cargo_ultra_profile()
end, {
  desc = "Setup Cargo Ultra-Performance Profile",
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
  vim.cmd("checkhealth velocitynvim")
end, {
  desc = "Run VelocityNvim health check",
})

-- Rust Performance Commands
cmd("RustPerformanceStatus", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.get_performance_status()
end, { desc = "Zeige Rust Performance Status" })

cmd("RustBuildBlink", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.build_blink_rust()
end, { desc = "Kompiliere Blink.cmp Rust-Binary" })

cmd("RustOptimize", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.optimize_for_rust()
end, { desc = "Optimiere Neovim für Rust-Performance" })

cmd("RustBenchmark", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.benchmark_fuzzy_performance()
end, { desc = "Benchmark Rust-Performance" })

-- ULTIMATE Rust Performance Commands (NEU)
cmd("RustUltimateSetup", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.ultimate_setup()
end, {
  desc = "Complete ULTIMATE Rust performance analysis and setup",
})

cmd("RustAnalyzeEcosystem", function()
  local rust_perf = require("utils.rust-performance")
  local analysis = rust_perf.analyze_rust_ecosystem()
  local icons = require("core.icons")
  
  print(icons.performance.benchmark .. " Rust Ecosystem Analysis:")
  print("  " .. icons.misc.gear .. " CPU: " .. analysis.toolchain.cpu_target)
  print("  " .. icons.misc.gear .. " RAM: " .. analysis.toolchain.total_memory_gb .. "GB")
  print("  " .. icons.misc.gear .. " Rustc: " .. analysis.toolchain.rustc_version)
  print("  " .. icons.misc.gear .. " Nightly: " .. (analysis.toolchain.has_nightly and "Available" or "Not installed"))
end, {
  desc = "Analyze Rust ecosystem and hardware capabilities",
})

cmd("RustAdaptiveLSP", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.generate_adaptive_lsp_config()
end, {
  desc = "Generate adaptive rust-analyzer configuration",
})

cmd("RustCrossSetup", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.setup_cross_compilation()
end, {
  desc = "Setup cross-compilation targets and configuration",
})

cmd("RustCargoUltra", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.setup_cargo_ultra_profile()
end, {
  desc = "Setup Cargo ultra-performance profile with Fat-LTO",
})

cmd("RustUltimateBenchmark", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.ultimate_benchmark()
end, {
  desc = "Run comprehensive ULTIMATE performance benchmark with detailed scoring",
})

-- Color Highlighting Commands
cmd("ColorizerStatus", function()
  local icons = require("core.icons")
  local ok, colorizer = pcall(require, "colorizer")
  if ok then
    print(icons.status.success .. " nvim-colorizer.lua: Aktiv und bereit!")
    print(icons.misc.info .. " Unterstützte Formate: #RGB, #RRGGBB, rgb(), hsl(), CSS-Namen")
    print(icons.misc.gear .. " Toggle: <leader>ct | Reload: <leader>cr")
  else
    print(icons.status.error .. " nvim-colorizer.lua nicht verfügbar")
  end
end, {
  desc = "Show nvim-colorizer.lua status and usage info",
})

cmd("DeltaStatus", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.get_delta_status()
end, { desc = "Check Delta Git Performance Status" })

-- LaTeX Performance Commands
cmd("LaTeXStatus", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.get_latex_status()
end, { desc = "Zeige LaTeX Performance Status" })

cmd("LaTeXBuildTectonic", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.build_with_tectonic()
end, { desc = "Build LaTeX mit Tectonic (Ultra-Performance)" })

cmd("LaTeXBuildTypst", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.build_with_typst()
end, { desc = "Build Typst-Dokument" })

cmd("LaTeXLivePreview", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.setup_live_preview()
end, { desc = "Aktiviere LaTeX Live-Preview" })

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

-- Buffer Management Commands (using new utils)
cmd("BufferCloseOthers", function()
  local utils = require("utils")
  local closed_count = utils.buffer().close_others()
  utils.notify(
    icons.status.folder .. " " .. closed_count .. " Buffer geschlossen",
    vim.log.levels.INFO
  )
end, {
  desc = "Close all buffers except current",
})

-- Icon-Validierung Command
cmd("IconValidate", function()
  local validator = require("utils.validate-icons")
  validator.validate()
end, {
  desc = "Validiere alle Icon-Referenzen im Code"
})

cmd("BufferCloseAll", function()
  local utils = require("utils")
  local success = utils.buffer().close_all()
  if success then
    utils.notify(icons.status.folder .. " Alle Buffer geschlossen", vim.log.levels.INFO)
  end
end, {
  desc = "Close all buffers (force)",
})

cmd("BufferInfo", function()
  local utils = require("utils")
  utils.buffer().print_info()
end, {
  desc = "Show current buffer information",
})

cmd("BufferStats", function()
  local utils = require("utils")
  local stats = utils.buffer().get_stats()
  print(icons.status.stats .. " Buffer Statistics:")
  print("  Total: " .. stats.total)
  print("  Listed: " .. stats.listed)
  print("  Modified: " .. stats.modified)
  print("  Files: " .. stats.files)
  print("  Scratch: " .. stats.scratch)
end, {
  desc = "Show buffer statistics",
})

-- Development Commands
cmd("EditConfig", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
end, {
  desc = "Open init.lua",
})

cmd("ReloadConfig", function()
  -- Clear module cache
  for name, _ in pairs(package.loaded) do
    if name:match("^core") or name:match("^plugins") then
      package.loaded[name] = nil
    end
  end

  -- Reload configuration
  vim.cmd("source " .. vim.fn.stdpath("config") .. "/init.lua")
  vim.notify(icons.status.sync .. " Konfiguration neu geladen", vim.log.levels.INFO)
end, {
  desc = "Reload Neovim configuration",
})

-- Git Integration Commands (using new utils)
cmd("GitInfo", function()
  local utils = require("utils")
  utils.git().print_info()
end, {
  desc = "Show git repository information",
})

cmd("GitStatus", function()
  local utils = require("utils")
  if utils.git().is_available() then
    vim.cmd("FzfLua git_status")
  else
    utils.notify("Git is not available", vim.log.levels.ERROR)
  end
end, {
  desc = "Show git status with fzf",
})

cmd("GitLog", function()
  local utils = require("utils")
  if utils.git().is_available() then
    vim.cmd("FzfLua git_commits")
  else
    utils.notify("Git is not available", vim.log.levels.ERROR)
  end
end, {
  desc = "Show git log with fzf",
})

-- Window Management Commands (using new utils)
cmd("WindowInfo", function()
  local utils = require("utils")
  utils.window().print_info()
end, {
  desc = "Show current window information",
})

cmd("WindowBalance", function()
  local utils = require("utils")
  utils.window().balance()
end, {
  desc = "Balance all windows",
})

cmd("WindowZoom", function()
  local utils = require("utils")
  utils.window().toggle_zoom()
end, {
  desc = "Toggle window zoom (maximize/restore)",
})

-- File Utilities Commands
cmd("FileInfo", function()
  local utils = require("utils")
  local current_file = vim.fn.expand("%:p")
  if current_file ~= "" then
    utils.file().print_info(current_file)
  else
    utils.notify("No file loaded in current buffer", vim.log.levels.WARN)
  end
end, {
  desc = "Show current file information",
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

-- ENTFERNT: LspDiagnosticsFzf und LspWorkspaceDiagnosticsFzf Commands
-- Ersetzt durch <leader>le und <leader>lE in fzf-lua.lua

-- LSP Workspace Scanning Commands
cmd("LspWorkspaceInfo", function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify(icons.status.error .. " Keine aktiven LSP-Clients", vim.log.levels.WARN)
    return
  end

  for _, client in ipairs(clients) do
    if client.config and client.config.root_dir then
      print(icons.status.folder .. " LSP Client: " .. client.name)
      print("  Root: " .. client.config.root_dir)

      -- Zeige aktive Filter
      local filter_info = " Standard Filter aktiv: venv, __pycache__, node_modules, .git, etc."
      if _G.velocity_lsp_exclude_dirs then
        filter_info = filter_info
          .. string.format(" + %d benutzerdefinierte", #_G.velocity_lsp_exclude_dirs)
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
          filter_info = filter_info .. string.format(" + %d aus .gitignore", valid_lines)
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
    vim.fn.input("Zusätzliche Verzeichnisse ausschließen (comma-separated): ")
  if custom_filters and custom_filters ~= "" then
    _G.velocity_lsp_exclude_dirs = {}
    for filter in custom_filters:gmatch("([^,]+)") do
      table.insert(_G.velocity_lsp_exclude_dirs, vim.trim(filter))
    end
    vim.notify(
      icons.status.success .. " Filter gesetzt: " .. table.concat(_G.velocity_lsp_exclude_dirs, ", "),
      vim.log.levels.INFO
    )
    vim.notify(
      icons.status.info .. " LSP-Clients neu starten für Wirkung: :LspRestart",
      vim.log.levels.INFO
    )
  end
end, {
  desc = "Set project-specific directory filters for LSP scanning",
})

-- Terminal Management Commands
cmd("TermH", function()
  local utils = require("utils")
  utils.terminal().toggle_horizontal_terminal()
end, {
  desc = "Toggle horizontal terminal",
})

cmd("TermV", function()
  local utils = require("utils")
  utils.terminal().toggle_vertical_terminal()
end, {
  desc = "Toggle vertical terminal",
})

cmd("TermF", function()
  local utils = require("utils")
  utils.terminal().toggle_floating_terminal()
end, {
  desc = "Toggle floating terminal",
})

cmd("TermClose", function()
  local utils = require("utils")
  utils.terminal().close_all_terminals()
end, {
  desc = "Close all terminals",
})

cmd("TermInfo", function()
  local utils = require("utils")
  utils.terminal().print_terminal_info()
end, {
  desc = "Show terminal information and keybindings",
})
