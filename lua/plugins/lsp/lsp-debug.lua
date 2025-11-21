-- ~/.config/VelocityNvim/lua/plugins/lsp-debug.lua
-- LSP Diagnostics with native Neovim features (OPTIMIZED: 181 → ~30 lines)

local icons = require("core.icons")

-- ============================================================================
-- NATIVE DIAGNOSTIC FUNCTIONS (Replacement for 130+ lines of custom code)
-- ============================================================================

-- Show diagnostics in float window (replaces update_diagnostics_buffer + show_diagnostics_split)
local function show_diagnostics_float()
  local buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(buf)

  if #diagnostics == 0 then
    vim.notify(icons.ui.checkmark .. " No problems found", vim.log.levels.INFO)
    return
  end

  -- Native float window with improved formatting
  vim.diagnostic.open_float({
    bufnr = buf,
    header = string.format("%s LSP Diagnostics (%s)", icons.status.stats, vim.fn.expand("%:t")),
    source = "if_many",  -- Show source only when multiple LSP servers
    scope = "buffer",    -- Current buffer only
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
    focusable = true,     -- Scrollbar possible
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
  })
end

-- Show diagnostics in quickfix list ONLY for current buffer
local function show_diagnostics_quickfix()
  local buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(buf)

  if #diagnostics == 0 then
    vim.notify(icons.ui.checkmark .. " No problems found", vim.log.levels.INFO)
    return
  end

  -- FIXED: Buffer-specific quickfix list
  vim.diagnostic.setqflist({
    open = true,
    title = "LSP Diagnostics - " .. vim.fn.expand("%:t"),
    bufnr = buf  -- IMPORTANT: Only diagnostics from current buffer!
  })
end

-- Toggle between float and quickfix based on diagnostic count
local function toggle_diagnostics()
  local buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(buf)
  local count = #diagnostics

  if count == 0 then
    vim.notify(icons.ui.checkmark .. " No problems found", vim.log.levels.INFO)
  elseif count <= 5 then
    -- Few diagnostics: Float window (clearer)
    show_diagnostics_float()
  else
    -- Many diagnostics: Quickfix list (navigable)
    show_diagnostics_quickfix()
  end
end

-- ============================================================================
-- COMMANDS & KEYMAPS (Native Integration)
-- ============================================================================

-- User commands (compatible with old API)
vim.api.nvim_create_user_command("LspShow", show_diagnostics_float, { desc = "Show LSP diagnostics in float" })
vim.api.nvim_create_user_command("LspToggle", toggle_diagnostics, { desc = "Toggle LSP diagnostics display" })

-- Additional native commands
vim.api.nvim_create_user_command("LspQuickfix", show_diagnostics_quickfix, { desc = "Show LSP diagnostics in quickfix" })

-- Keymaps (simplified - FZF diagnostics are better)
vim.keymap.set("n", "<leader>ld", toggle_diagnostics, { desc = "Toggle LSP Diagnostics" })
vim.keymap.set("n", "<leader>lf", show_diagnostics_float, { desc = "LSP Diagnostics Float" })

-- LSP DIAGNOSTICS KEYMAPS
-- <leader>lq - Buffer Diagnostics (Location List)
vim.keymap.set("n", "<leader>lq", function()
  local buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(buf)

  if #diagnostics == 0 then
    vim.notify("✓ No problems found in this buffer", vim.log.levels.INFO)
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