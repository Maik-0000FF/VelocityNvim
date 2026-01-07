-- ~/.config/VelocityNvim/lua/plugins/ui/nvim-colorizer.lua
-- Ultra-Performance Color Highlighting for VelocityNvim

local ok, colorizer = pcall(require, "colorizer")
if not ok then
  return
end

-- VelocityNvim BLACKLIST Configuration - Active for ALL file types
colorizer.setup({
  -- "*" means all file types
  ["*"] = {
    -- User-specific configuration for ALL file types
    RGB = true, -- #RGB hex codes
    RRGGBB = true, -- #RRGGBB hex codes
    names = true, -- "Name" codes like Blue or red
    RRGGBBAA = true, -- #RRGGBBAA hex codes (with Alpha)
    AARRGGBB = true, -- 0xAARRGGBB hex codes
    rgb_fn = true, -- CSS rgb() and rgba() functions
    hsl_fn = true, -- CSS hsl() and hsla() functions
    css = true, -- Enable all CSS features
    css_fn = true, -- Enable all CSS functions

    -- Performance optimizations
    mode = "background", -- Available modes: foreground, background, virtualtext
    tailwind = false, -- Enable Tailwind colors (only if needed)

    -- Virtual text options (if mode = "virtualtext")
    virtualtext = "■",

    -- Performance: Update behavior (WezTerm optimized)
    always_update = false,

    -- Buffer-based updates for better performance
    sass = { enable = false }, -- Sass disabled for performance
    vim = true, -- Vim color names enabled

    -- Reduce update events for fewer cursor interruptions
    use_default_namespace = true,
    buftypes = {
      "*",
      "!prompt",
      "!popup",
    },

    -- Performance: Lazy update for better responsiveness
    debounce = {
      default = 100, -- 100ms debounce for updates
      "css",
      "html",
      "javascript",
      "typescript",
    },
  },

  -- BLACKLIST: These file types are EXCLUDED (empty configuration = disabled)
  ["help"] = {}, -- Vim help
  ["man"] = {}, -- Man pages
  ["qf"] = {}, -- Quickfix list
  ["terminal"] = {}, -- Terminal buffer
  ["lazy"] = {}, -- Lazy.nvim
  ["mason"] = {}, -- Mason.nvim
  ["notify"] = {}, -- Notifications
  ["TelescopePrompt"] = {}, -- Telescope
  ["TelescopeResults"] = {},
  ["alpha"] = {}, -- Alpha Dashboard
  ["dashboard"] = {}, -- Dashboard
  ["startify"] = {}, -- Startify
  ["oil"] = {}, -- Oil.nvim
  ["NvimTree"] = {}, -- NvimTree
  ["neo-tree"] = {}, -- Neo-tree
  ["neo-tree-popup"] = {}, -- Neo-tree Popups
  ["fugitive"] = {}, -- vim-fugitive
  ["gitcommit"] = {}, -- Git Commit Messages
  ["gitrebase"] = {}, -- Git Rebase
  ["log"] = {}, -- Log-Dateien
  ["diff"] = {}, -- Diff-Ansicht
  ["undotree"] = {}, -- Undotree
  ["dbout"] = {}, -- Database Output
  ["spectre_panel"] = {}, -- Spectre
  ["packer"] = {}, -- Packer.nvim
  ["checkhealth"] = {}, -- Health checks
  ["lspinfo"] = {}, -- LSP info
  ["startuptime"] = {}, -- Startup time
  ["WhichKey"] = {}, -- Which-Key
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
