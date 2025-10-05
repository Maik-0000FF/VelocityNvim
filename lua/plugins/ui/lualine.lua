-- ~/.config/VelocityNvim/lua/plugins/lualine.lua
-- Lualine Plugin Konfiguration

-- Icons laden
local icons = require("core.icons")


-- Statusline wieder einschalten für lualine
vim.opt.laststatus = 3

-- Lualine Setup
require("lualine").setup({
  options = {
    theme = "tokyonight",
    component_separators = "",
    section_separators = {
      left = icons.lualine.section_separator_left,
      right = icons.lualine.section_separator_right,
    },
    globalstatus = true,
    disabled_filetypes = {
      statusline = { "dashboard", "alpha" },
      winbar = { "dashboard", "alpha", "neo-tree" },
    },
    ignore_focus = { "neo-tree" },
  },
  sections = {
    lualine_a = {
      {
        "mode",
        separator = {
          left = icons.lualine.section_separator_right,
        },
        right_padding = 2,
      },
    },
    lualine_b = {
      { "filename", path = 0 },
      {
        "branch",
        icon = icons.git.gitsymbol,
      },
      {
        "diff",
        symbols = {
          added = icons.git.addedsymbol .. " ",
          modified = icons.git.changesymbol .. " ",
          removed = icons.git.deletesymbol .. " ",
        },
        colored = true,
      },
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = {
          error = icons.diagnostics.error .. " ",
          warn = icons.diagnostics.warn .. " ",
          info = icons.diagnostics.info .. " ",
          hint = icons.diagnostics.hint .. " ",
        },
        colored = true,
        update_in_insert = false,
      },
    },
    lualine_c = {
      "%=", -- Linke und rechte Sektionen ausbalancieren
    },
    lualine_x = {
      {
        "lsp_status",
        icon = icons.lsp.code_action .. " ",
      },
      { "filetype", colored = true, icon_only = false },
    },
    lualine_y = {
      "fileformat",
      "encoding",
      "progress",
    },
    lualine_z = {
      {
        "location",
        separator = {
          right = icons.lualine.section_separator_left,
        },
        left_padding = 2,
      },
    },
  },
  inactive_sections = {
    lualine_a = { "filename" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  tabline = {},
  extensions = { "neo-tree" },
})

