-- ~/.config/VelocityNvim/lua/plugins/editor/lsp-file-operations.lua
-- LSP File Operations - Automatische Import-Updates bei Datei-Operationen

-- Sichere Plugin-Ladung
local status_ok, lsp_file_operations = pcall(require, "lsp-file-operations")
if not status_ok then
  return
end

-- Setup mit Neo-tree Integration
lsp_file_operations.setup({
  -- Debug-Modus (nur aktivieren bei Problemen)
  debug = false,

  -- Timeout für LSP-Operationen (in ms)
  timeout_ms = 10000,

  -- Neo-tree Integration aktivieren
  operations = {
    -- Wird ausgeführt bei willRead/willRename/willDelete
    willRenameFiles = true,
    willCreateFiles = true,
    willDeleteFiles = true,
  },
})
