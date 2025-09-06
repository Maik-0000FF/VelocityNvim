local icons = require("core.icons")
-- ~/core/performance.lua
-- ULTIMATE Performance Mode - Cursor-responsive wie reines Neovim

local M = {}

-- Performance state tracking
local performance_mode = {
  ultra_active = false,
  original_updatetime = nil,
  cursor_busy = false,
}

-- Deaktiviere UI-Updates während Cursor-Navigation (DIAGNOSTICS AUSGESCHLOSSEN)
local function disable_ui_updates()
  if performance_mode.ultra_active then return end
  
  performance_mode.ultra_active = true
  performance_mode.original_updatetime = vim.opt.updatetime:get()
  
  -- Drastisch reduzierte Update-Frequenz während Navigation
  vim.opt.updatetime = 2000  -- 2 Sekunden statt 250ms
  
  -- KRITISCHE ÄNDERUNG: LSP diagnostics NICHT deaktivieren - sie sollen sichtbar bleiben!
  -- Die Diagnostics sind bereits optimal konfiguriert und sollen bei Cursor-Bewegung sichtbar bleiben
  -- Nur die automatischen Updates pausieren, nicht die Anzeige
  vim.diagnostic.config({
    update_in_insert = false,  -- Keine Updates während Typing
    -- virtual_text und signs bleiben aktiviert für dauerhaftes Display!
  })
end

-- Reaktiviere UI-Updates nach Navigation (DIAGNOSTICS BLEIBEN AKTIV)
local function enable_ui_updates()
  if not performance_mode.ultra_active then return end
  
  vim.defer_fn(function()
    performance_mode.ultra_active = false
    
    -- Restore original settings
    if performance_mode.original_updatetime then
      vim.opt.updatetime = performance_mode.original_updatetime
    end
    
    -- WICHTIG: Diagnostics-Konfiguration NICHT zurücksetzen!
    -- Die Diagnostics sollen die in native-lsp.lua definierten Einstellungen behalten
    -- mit Icons aus icons.lua und dauerhaftem Display
    
  end, 100)  -- 100ms delay nach Navigation
end

-- ULTRA Performance Mode Setup
function M.setup()
  -- Navigation-basierte Performance-Optimierung
  local navigation_keys = {'j', 'k', 'h', 'l', 'w', 'b', 'e', 'g', 'G', 'f', 'F', 't', 'T', '/', '?', 'n', 'N'}
  
  for _, key in ipairs(navigation_keys) do
    -- Before navigation - disable UI updates
    vim.keymap.set('n', key, function()
      disable_ui_updates()
      vim.api.nvim_feedkeys(key, 'n', true)
      -- Schedule UI re-enable after navigation
      vim.defer_fn(enable_ui_updates, 50)
    end, { silent = true })
  end
  
  -- Cursor movement detection
  vim.api.nvim_create_autocmd('CursorMoved', {
    callback = function()
      disable_ui_updates()
      vim.defer_fn(enable_ui_updates, 200)  -- Longer delay for continuous movements
    end
  })
  
  -- Silent setup - Performance-Optimierung läuft im Hintergrund
end

-- Status check
function M.status()
  return {
    ultra_active = performance_mode.ultra_active,
    updatetime = vim.opt.updatetime:get(),
    original_updatetime = performance_mode.original_updatetime,
  }
end

-- Toggle performance mode
function M.toggle()
  if performance_mode.ultra_active then
    enable_ui_updates()
    print(".. icons.misc.flash .. ")
  else
    disable_ui_updates()
    print(".. icons.status.rocket .. ")
  end
end

return M