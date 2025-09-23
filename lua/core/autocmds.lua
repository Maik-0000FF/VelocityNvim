-- ~/.config/VelocityNvim/lua/core/autocmds.lua
-- Autocommands und Event-Handler

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Cross-version compatibility layer für fs_stat access

-- VelocityNvim Autocommand Gruppen
local velocity_general = augroup("VelocityGeneral", { clear = true })
local velocity_lsp = augroup("VelocityLsp", { clear = true })
local velocity_ui = augroup("VelocityUI", { clear = true })
local velocity_format = augroup("VelocityFormat", { clear = true })

-- Allgemeine Autocommands
autocmd("TextYankPost", {
  group = velocity_general,
  desc = "Highlight yanked text",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

-- Cursor-Position bei Datei-Öffnung wiederherstellen
autocmd("BufReadPost", {
  group = velocity_general,
  desc = "Restore cursor position",
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Trailing Whitespace entfernen vor dem Speichern
autocmd("BufWritePre", {
  group = velocity_format,
  desc = "Remove trailing whitespace",
  pattern = "*.lua",
  callback = function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_command("%s/\\s\\+$//e")
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end,
})

-- UI Verbesserungen
autocmd("VimEnter", {
  group = velocity_ui,
  desc = "Setup UI on vim enter",
  pattern = "*",
  callback = function()
    -- Startmeldungen verbergen
    vim.opt.shortmess:append("I")
    -- Nur Fehler melden, erfolgreiche Ladung ist selbstverständlich
  end,
})

-- Colorscheme Updates für Plugins
autocmd("ColorScheme", {
  group = velocity_ui,
  desc = "Update plugin colors on colorscheme change",
  pattern = "*",
  callback = function()
    -- Trigger Farb-Updates für verschiedene Plugins
    vim.defer_fn(function()
      vim.cmd.doautocmd("User", "ColorSchemeChanged")
    end, 100)
  end,
})

-- Buffer-spezifische Einstellungen
autocmd("FileType", {
  group = velocity_general,
  desc = "Set filetype specific options",
  pattern = { "qf", "help", "man", "lspinfo", "spectre_panel" },
  callback = function()
    vim.keymap.set(
      "n",
      "q",
      "<cmd>close<cr>",
      { buffer = true, silent = true, desc = "Close buffer" }
    )
  end,
})

-- LSP-spezifische Autocommands
autocmd("LspAttach", {
  group = velocity_lsp,
  desc = "LSP keymaps and options on attach",
  callback = function(event)
    local bufnr = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if not client then
      return
    end

    -- Buffer-lokale Einstellungen
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Inlay Hints aktivieren (wenn verfügbar)
    if client and client.supports_method then
      local supports_inlay = pcall(client.supports_method, client, "textDocument/inlayHint")
      if supports_inlay then
        vim.defer_fn(function()
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end, 500)
      end
    end
  end,
})

-- Diagnostics Update für Neo-tree (Performance-optimiert)
local diagnostic_timer = nil
autocmd("DiagnosticChanged", {
  group = velocity_lsp,
  desc = "Update neo-tree diagnostics display (debounced)",
  callback = function()
    -- Debounced updates: Verhindert excessive Updates bei schnellen Änderungen
    if diagnostic_timer then
      diagnostic_timer:stop()
    end
    diagnostic_timer = vim.defer_fn(function()
      if package.loaded["neo-tree"] then
        local ok, events = pcall(require, "neo-tree.events")
        if ok and events then
          events.fire_event("diagnostics_changed")
        end
      end
      diagnostic_timer = nil
    end, 500) -- Längere Verzögerung für weniger frequent updates
  end,
})

-- Performance: Große Dateien optimieren (aggressiver)
autocmd("BufReadPre", {
  group = velocity_general,
  desc = "Optimize settings for large files (ultra-performance)",
  callback = function()
    local fs_stat_func = rawget(vim.uv, 'fs_stat') or rawget(vim.loop, 'fs_stat')
    local ok, stats = fs_stat_func and pcall(fs_stat_func, vim.fn.expand("<afile>")) or false, nil
    if ok and stats and stats.size > 512 * 1024 then -- 512KB (aggressiver als 1MB)
      -- Ultra-Performance Einstellungen für große Dateien
      vim.opt_local.swapfile = false
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.undolevels = -1
      vim.opt_local.undoreload = 0
      vim.opt_local.list = false
      vim.opt_local.cursorline = false  -- Cursor-Line deaktivieren
      vim.opt_local.cursorcolumn = false -- Cursor-Column deaktivieren
      vim.opt_local.relativenumber = false -- Relative Nummern deaktivieren
      vim.opt_local.spell = false       -- Spell-Check deaktivieren
      vim.opt_local.synmaxcol = 200     -- Syntax nur für erste 200 Spalten
      vim.b.large_buf = true
      -- Silent success - keine Notification für bessere UX
    end
  end,
})

-- Terminal-spezifische Einstellungen
autocmd("TermOpen", {
  group = velocity_general,
  desc = "Terminal specific settings",
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})
