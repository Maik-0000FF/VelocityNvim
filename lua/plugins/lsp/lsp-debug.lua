-- ~/.config/VelocityNvim/lua/plugins/lsp-debug.lua
-- LSP Diagnostics mit nativen Neovim Features (OPTIMIERT: 181 → ~30 Zeilen)

local icons = require("core.icons")

-- ============================================================================
-- NATIVE DIAGNOSTIC FUNCTIONS (Ersatz für 130+ Zeilen Custom Code)
-- ============================================================================

-- Zeige Diagnostics in Float-Window (ersetzt update_diagnostics_buffer + show_diagnostics_split)
local function show_diagnostics_float()
  local buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(buf)

  if #diagnostics == 0 then
    vim.notify(icons.ui.checkmark .. " Keine Probleme gefunden", vim.log.levels.INFO)
    return
  end

  -- Native Float-Window mit verbesserter Formatierung
  vim.diagnostic.open_float({
    bufnr = buf,
    header = string.format("%s LSP Diagnostics (%s)", icons.status.stats, vim.fn.expand("%:t")),
    source = "if_many",  -- Zeige Source nur wenn mehrere LSP-Server
    scope = "buffer",    -- Nur aktueller Buffer
    format = function(diagnostic)
      local icon = ({
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
      })[diagnostic.severity] or "●"

      local source = diagnostic.source and ("[" .. diagnostic.source .. "] ") or ""
      return string.format("%s %s%s", icon, source, diagnostic.message)
    end,
    border = "rounded",
    focusable = true,     -- Scrollbar möglich
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
  })
end

-- Zeige Diagnostics in Quickfix-Liste NUR für aktuellen Buffer
local function show_diagnostics_quickfix()
  local buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(buf)

  if #diagnostics == 0 then
    vim.notify(icons.ui.checkmark .. " Keine Probleme gefunden", vim.log.levels.INFO)
    return
  end

  -- KORRIGIERT: Buffer-spezifische Quickfix-Liste
  vim.diagnostic.setqflist({
    open = true,
    title = "LSP Diagnostics - " .. vim.fn.expand("%:t"),
    bufnr = buf  -- WICHTIG: Nur Diagnostics vom aktuellen Buffer!
  })
end

-- Toggle zwischen Float und Quickfix basierend auf Diagnostic-Anzahl
local function toggle_diagnostics()
  local buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(buf)
  local count = #diagnostics

  if count == 0 then
    vim.notify(icons.ui.checkmark .. " Keine Probleme gefunden", vim.log.levels.INFO)
  elseif count <= 5 then
    -- Wenige Diagnostics: Float-Window (übersichtlicher)
    show_diagnostics_float()
  else
    -- Viele Diagnostics: Quickfix-Liste (navigierbar)
    show_diagnostics_quickfix()
  end
end

-- ============================================================================
-- COMMANDS & KEYMAPS (Native Integration)
-- ============================================================================

-- User Commands (kompatibel mit alter API)
vim.api.nvim_create_user_command("LspShow", show_diagnostics_float, { desc = "Show LSP diagnostics in float" })
vim.api.nvim_create_user_command("LspToggle", toggle_diagnostics, { desc = "Toggle LSP diagnostics display" })

-- Zusätzliche native Commands
vim.api.nvim_create_user_command("LspQuickfix", show_diagnostics_quickfix, { desc = "Show LSP diagnostics in quickfix" })

-- Keymaps (vereinfacht - FZF-Diagnostics sind besser)
vim.keymap.set("n", "<leader>ld", toggle_diagnostics, { desc = "Toggle LSP Diagnostics" })
vim.keymap.set("n", "<leader>lf", show_diagnostics_float, { desc = "LSP Diagnostics Float" })

-- LSP DIAGNOSTICS KEYMAPS
-- <leader>lq - Buffer Diagnostics (Location List)
vim.keymap.set("n", "<leader>lq", function()
  local buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(buf)

  if #diagnostics == 0 then
    vim.notify("✓ Keine Probleme in diesem Buffer gefunden", vim.log.levels.INFO)
    return
  end

  vim.diagnostic.setloclist({
    open = true,
    title = string.format("Buffer Diagnostics: %s (%d problems)", vim.fn.expand("%:t"), #diagnostics),
    severity_sort = true,
    namespace = nil,
    winnr = 0,
  })
end, { desc = "Buffer Diagnostics (Location List)" })

-- <leader>lQ - Workspace Diagnostics (Quickfix List)
vim.keymap.set("n", "<leader>lQ", function()
  vim.diagnostic.setqflist({
    open = true,
    title = "Workspace Diagnostics (All Buffers)",
    severity_sort = true,
    namespace = nil,
  })
end, { desc = "Workspace Diagnostics (Quickfix)" })