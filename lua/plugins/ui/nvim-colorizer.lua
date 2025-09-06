-- ~/.config/VelocityNvim/lua/plugins/ui/nvim-colorizer.lua
-- Ultra-Performance Color Highlighting für VelocityNvim

local ok, colorizer = pcall(require, "colorizer")
if not ok then
  return
end

-- VelocityNvim BLACKLIST Konfiguration - Aktiv für ALLE Dateitypen
colorizer.setup({
  -- "*" bedeutet alle Dateitypen
  ["*"] = {
    -- User-spezifische Konfiguration für ALLE Dateitypen
    RGB = true, -- #RGB hex codes
    RRGGBB = true, -- #RRGGBB hex codes
    names = true, -- "Name" codes like Blue or red
    RRGGBBAA = true, -- #RRGGBBAA hex codes (mit Alpha)
    AARRGGBB = true, -- 0xAARRGGBB hex codes
    rgb_fn = true, -- CSS rgb() and rgba() functions
    hsl_fn = true, -- CSS hsl() and hsla() functions
    css = true, -- Enable all CSS features
    css_fn = true, -- Enable all CSS functions

    -- Performance-Optimierungen
    mode = "background", -- Verfügbare Modi: foreground, background, virtualtext
    tailwind = false, -- Enable Tailwind colors (nur wenn benötigt)

    -- Virtuelle Text-Optionen (falls mode = "virtualtext")
    virtualtext = "■",

    -- Performance: Update-Verhalten (WezTerm optimiert)
    always_update = false,
    
    -- Buffer-basierte Updates für bessere Performance
    sass = { enable = false }, -- Sass deaktiviert für Performance
    vim = true, -- Vim color names aktiviert
    
    -- Update-Events reduzieren für weniger Cursor-Interruptions
    use_default_namespace = true,
    buftypes = {
      "*",
      "!prompt",
      "!popup",
    },
    
    -- Performance: Lazy-Update für bessere Responsivität
    debounce = {
      default = 100, -- 100ms debounce für Updates
      "css",
      "html",
      "javascript",
      "typescript",
    },
  },

  -- BLACKLIST: Diese Dateitypen werden AUSGESCHLOSSEN (leere Konfiguration = deaktiviert)
  ["help"] = {}, -- Vim-Hilfe
  ["man"] = {}, -- Man-Pages
  ["qf"] = {}, -- Quickfix-Liste
  ["terminal"] = {}, -- Terminal-Buffer
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
  ["checkhealth"] = {}, -- Health-Checks
  ["lspinfo"] = {}, -- LSP-Info
  ["startuptime"] = {}, -- Startup-Time
  ["WhichKey"] = {}, -- Which-Key
})

-- Keybindings für Color-Highlighting-Kontrolle
local icons = require("core.icons")
vim.keymap.set("n", "<leader>ct", "<cmd>ColorizerToggle<CR>", {
  desc = icons.misc.gear .. " Toggle Colorizer",
})
vim.keymap.set("n", "<leader>cr", "<cmd>ColorizerReloadAllBuffers<CR>", {
  desc = icons.status.sync .. " Reload Colorizer",
})

-- Colorizer ist mit der setup() Konfiguration automatisch aktiv für die angegebenen Filetypes

