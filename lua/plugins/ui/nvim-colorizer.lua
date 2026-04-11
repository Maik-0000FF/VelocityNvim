-- ~/.config/VelocityNvim/lua/plugins/ui/nvim-colorizer.lua
-- Ultra-Performance Color Highlighting for VelocityNvim

local ok, colorizer = pcall(require, "colorizer")
if not ok then
  return
end

-- VelocityNvim BLACKLIST Configuration - Active for ALL file types
colorizer.setup({
  -- "*" means all file types, "!filetype" excludes specific types
  filetypes = {
    "*",
    -- BLACKLIST: These file types are EXCLUDED
    "!help", -- Vim help
    "!man", -- Man pages
    "!qf", -- Quickfix list
    "!terminal", -- Terminal buffer
    "!lazy", -- Lazy.nvim
    "!mason", -- Mason.nvim
    "!notify", -- Notifications
    "!TelescopePrompt", -- Telescope
    "!TelescopeResults",
    "!alpha", -- Alpha Dashboard
    "!dashboard", -- Dashboard
    "!startify", -- Startify
    "!oil", -- Oil.nvim
    "!NvimTree", -- NvimTree
    "!neo-tree", -- Neo-tree
    "!neo-tree-popup", -- Neo-tree Popups
    "!fugitive", -- vim-fugitive
    "!gitcommit", -- Git Commit Messages
    "!gitrebase", -- Git Rebase
    "!log", -- Log files
    "!diff", -- Diff-Ansicht
    "!undotree", -- Undotree
    "!dbout", -- Database Output
    "!spectre_panel", -- Spectre
    "!packer", -- Packer.nvim
    "!checkhealth", -- Health checks
    "!lspinfo", -- LSP info
    "!startuptime", -- Startup time
    "!WhichKey", -- Which-Key
  },
  buftypes = {
    "*",
    "!prompt",
    "!popup",
  },
  user_commands = true,
  options = {
    parsers = {
      css = true, -- Preset: enables names, hex, rgb, hsl, oklch
      css_fn = true, -- Preset: enables rgb(), hsl(), oklch() functions
      names = { enable = true }, -- "Name" codes like Blue or red
      hex = {
        default = true, -- Enable all hex formats
        rrggbbaa = true, -- #RRGGBBAA hex codes (with Alpha)
        aarrggbb = true, -- 0xAARRGGBB hex codes
      },
      rgb = { enable = true }, -- CSS rgb() and rgba() functions
      hsl = { enable = true }, -- CSS hsl() and hsla() functions
      tailwind = { enable = false }, -- Tailwind colors (only if needed)
      sass = { enable = false }, -- Sass disabled for performance
    },
    display = {
      mode = "background", -- Available modes: foreground, background, virtualtext
      virtualtext = {
        char = "■",
        position = "eol",
      },
    },
    always_update = false, -- Performance: reduced update events
  },
})

-- Keybindings for color highlighting control
local icons = require("core.icons")
vim.keymap.set("n", "<leader>Tc", "<cmd>ColorizerToggle<CR>", {
  desc = icons.misc.gear .. " Toggle Colorizer",
})
vim.keymap.set("n", "<leader>cr", "<cmd>ColorizerReloadAllBuffers<CR>", {
  desc = icons.status.sync .. " Reload Colorizer",
})

-- Colorizer is automatically active for the specified filetypes with the setup() configuration
