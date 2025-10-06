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
    -- Icons aus core.icons verwenden
    close_icon = icons.ui.close,
    modified_icon = icons.files.modified,
    buffer_close_icon = icons.ui.close,
    -- Stil der Tabs
    separator_style = "slant",
    -- Zeige die Buffer-Nummer an
    numbers = "ordinal",
    -- Kürze lange Dateinamen
    truncate_names = true,
    -- PERFORMANCE: Alle Diagnostics mit Icons anzeigen (optimiert)
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    -- Zeige alle Diagnostic-Typen mit korrekten Icons aus core.icons
    diagnostics_indicator = function(_, _, diagnostics_dict, _)
      local result = {}

      -- Errors
      if diagnostics_dict.error and diagnostics_dict.error > 0 then
        table.insert(result, icons.diagnostics.error .. " " .. diagnostics_dict.error)
      end

      -- Warnings
      if diagnostics_dict.warning and diagnostics_dict.warning > 0 then
        table.insert(result, icons.diagnostics.warn .. " " .. diagnostics_dict.warning)
      end

      -- Info
      if diagnostics_dict.info and diagnostics_dict.info > 0 then
        table.insert(result, icons.diagnostics.info .. " " .. diagnostics_dict.info)
      end

      -- Hints
      if diagnostics_dict.hint and diagnostics_dict.hint > 0 then
        table.insert(result, icons.diagnostics.hint .. " " .. diagnostics_dict.hint)
      end

      if #result > 0 then
        return " " .. table.concat(result, " ") .. " "
      end
      return ""
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