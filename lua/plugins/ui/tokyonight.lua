-- ~/.config/VelocityNvim/lua/plugins/tokyonight.lua
-- Tokyonight Colorscheme Configuration

-- Tokyonight Setup
require("tokyonight").setup({
  -- Tokyonight storm variant
  style = "night",

  -- Performance: Cache compiled highlights
  cache = true,

  -- Other options
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

-- Activate colorscheme
vim.cmd.colorscheme("tokyonight-night")