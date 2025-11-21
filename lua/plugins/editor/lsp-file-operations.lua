-- ~/.config/VelocityNvim/lua/plugins/editor/lsp-file-operations.lua
-- LSP File Operations - Automatic import updates on file operations

-- Safe plugin loading
local status_ok, lsp_file_operations = pcall(require, "lsp-file-operations")
if not status_ok then
  return
end

-- Setup with Neo-tree integration
lsp_file_operations.setup({
  -- Debug mode (only activate when troubleshooting)
  debug = false,

  -- Timeout for LSP operations (in ms)
  timeout_ms = 10000,

  -- Enable Neo-tree integration
  operations = {
    -- Executed on willRead/willRename/willDelete
    willRenameFiles = true,
    willCreateFiles = true,
    willDeleteFiles = true,
  },
})
