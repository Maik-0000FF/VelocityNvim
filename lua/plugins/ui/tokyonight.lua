-- ~/.config/VelocityNvim/lua/plugins/tokyonight.lua
-- Tokyonight Colorscheme Konfiguration

-- Tokyonight Setup
require("tokyonight").setup({
  -- Tokyonight storm variant
  style = "night",

  -- Andere Optionen
  light_style = "day",
  transparent = false,
  terminal_colors = true,

  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
    sidebars = "dark",
    floats = "dark",
  },

  sidebars = { "qf", "help", "neo-tree" },
  day_brightness = 0.3,
  hide_inactive_statusline = false,
  dim_inactive = true,
  lualine_bold = false,

  on_colors = function(_) end,
  on_highlights = function(_, _) end,
})

-- Colorscheme aktivieren
vim.cmd.colorscheme("tokyonight-night")
