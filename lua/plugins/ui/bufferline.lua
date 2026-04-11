-- ~/.config/VelocityNvim/lua/plugins/bufferline.lua
-- Bufferline Plugin Configuration

-- Load icons
local icons = require("core.icons")

-- PERFORMANCE: Pre-cached diagnostic icons and order (avoid table creation per call)
local DIAG_ORDER = { "error", "warning", "info", "hint" }
local DIAG_ICONS = {
  error = icons.diagnostics.error,
  warning = icons.diagnostics.warn,
  info = icons.diagnostics.info,
  hint = icons.diagnostics.hint,
}

-- Bufferline Setup
require("bufferline").setup({
  options = {
    style_preset = {
      require("bufferline").style_preset.no_italic,
      require("bufferline").style_preset.no_bold,
    },
    -- Use icons from core.icons
    close_icon = icons.ui.close,
    modified_icon = icons.files.modified,
    buffer_close_icon = icons.ui.close,
    -- Tab style
    separator_style = "slant",
    -- Show buffer number
    numbers = "ordinal",
    -- Truncate long filenames
    truncate_names = true,
    -- PERFORMANCE: Show all diagnostics with icons (optimized)
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    -- OPTIMIZED: Single-pass diagnostic indicator with cached icons
    diagnostics_indicator = function(_, _, diagnostics_dict, _)
      local parts = {}
      local n = 0
      for _, key in ipairs(DIAG_ORDER) do
        local count = diagnostics_dict[key]
        if count and count > 0 then
          n = n + 1
          parts[n] = DIAG_ICONS[key] .. " " .. count
        end
      end
      return n > 0 and (" " .. table.concat(parts, " ", 1, n) .. " ") or ""
    end,
    -- Close buffer
    close_command = "bdelete! %d",
    -- Show icons
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    -- Switch buffer with mouse click
    left_mouse_command = "buffer %d",
    right_mouse_command = "bdelete! %d",
    -- Maximum width for buffer tabs
    max_name_length = 18,
    tab_size = 18,
    -- Always show bufferline
    always_show_bufferline = true,
    -- Neo-tree Integration
    offsets = {
      {
        filetype = "neo-tree",
        text = "File Explorer",
        text_align = "center",
        separator = true,
      },
    },
    -- Additional options
    color_icons = true,
    sort_by = "id",
  },
})

-- Key mappings for Bufferline
vim.keymap.set(
  "n",
  "<leader>j",
  "<cmd>BufferLineCycleNext<CR>",
  { noremap = true, silent = true, desc = "Buffer: Next" }
)
vim.keymap.set(
  "n",
  "<leader>k",
  "<cmd>BufferLineCyclePrev<CR>",
  { noremap = true, silent = true, desc = "Buffer: Previous" }
)
vim.keymap.set(
  "n",
  "<leader>bb",
  "<cmd>BufferLinePick<CR>",
  { noremap = true, silent = true, desc = "Buffer: Select" }
)
vim.keymap.set(
  "n",
  "<leader>bc",
  "<cmd>BufferLinePickClose<CR>",
  { noremap = true, silent = true, desc = "Buffer: Select to close" }
)