-- ~/.config/VelocityNvim/lua/plugins/bufferline.lua
-- Bufferline Plugin Konfiguration

-- Icons laden
local icons = require("core.icons")

-- Bufferline Setup
require("bufferline").setup({
  options = {
    style_preset = {
      require("bufferline").style_preset.no_italic,
      require("bufferline").style_preset.no_bold,
    },
    -- Icons aus core/icons.lua verwenden
    close_icon = icons.ui.close,
    modified_icon = icons.files.modified,
    buffer_close_icon = icons.ui.close,
    -- Stil der Tabs
    separator_style = "slant",
    -- Zeige die Buffer-Nummer an
    numbers = "ordinal",
    -- Kürze lange Dateinamen
    truncate_names = true,
    -- Standard Bufferline Diagnostics (einfach und performant)
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    -- Standard Multi-Level Diagnostic Indicator (aus offizieller Dokumentation)
    diagnostics_indicator = function(_, _, diagnostics_dict, _)
      local s = " "
      for e, n in pairs(diagnostics_dict) do
        local sym = e == "error" and " " or (e == "warning" and " " or " ")
        s = s .. n .. sym
      end
      return s
    end,
    -- Buffer schließen
    close_command = "bdelete! %d",
    -- Zeige Icons
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    -- Buffer wechseln mit Mausklick
    left_mouse_command = "buffer %d",
    right_mouse_command = "bdelete! %d",
    -- Maximale Breite für Buffer-Tabs
    max_name_length = 18,
    tab_size = 18,
    -- Immer die Bufferline anzeigen
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
    -- Weitere Optionen
    color_icons = true,
    sort_by = "id",
  },
})

-- Tastenkombinationen für Bufferline
vim.keymap.set(
  "n",
  "<leader>j",
  "<cmd>BufferLineCycleNext<CR>",
  { noremap = true, silent = true, desc = "Buffer: Nächster" }
)
vim.keymap.set(
  "n",
  "<leader>k",
  "<cmd>BufferLineCyclePrev<CR>",
  { noremap = true, silent = true, desc = "Buffer: Vorheriger" }
)
vim.keymap.set(
  "n",
  "<leader>bb",
  "<cmd>BufferLinePick<CR>",
  { noremap = true, silent = true, desc = "Buffer: Auswählen" }
)
vim.keymap.set(
  "n",
  "<leader>bc",
  "<cmd>BufferLinePickClose<CR>",
  { noremap = true, silent = true, desc = "Buffer: Zum Schließen auswählen" }
)