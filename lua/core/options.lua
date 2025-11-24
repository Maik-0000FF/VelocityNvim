-- ~/.config/VelocityNvim/lua/core/options.lua
-- Native Neovim Options - Basic settings

-- PERFORMANCE: Disable unnecessary default plugins (~7ms savings)
-- netrw: Old file browser (replaced by neo-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- rplugin: Remote plugins Python/Node (VelocityNvim uses only Lua/Rust)
vim.g.loaded_remote_plugins = 1

-- Python formatting handled by conform.nvim + ruff
-- Ruff replaces black + isort with better performance
-- Disable system-wide black.vim plugin (~5ms savings)
-- IMPORTANT: black.vim only checks if g:load_black exists (if exists("g:load_black"))
-- The value doesn't matter - any value (0, 1, "foo") prevents loading
-- Source: https://github.com/psf/black/blob/main/plugin/black.vim (lines 10-13)
vim.g.load_black = 1

local opt = vim.opt
local g = vim.g

-- Set leader key
g.mapleader = " "
g.maplocalleader = " "

-- Basic UI options
opt.number = true -- Line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true -- Highlight current line
opt.signcolumn = "yes" -- Sign column for markers
opt.scrolloff = 10 -- Context when scrolling
opt.sidescrolloff = 8 -- Horizontal context

-- Tab and indentation (for better hlchunk visibility)
opt.tabstop = 2 -- 2 spaces for tab (smaller spacing)
opt.shiftwidth = 2 -- Indentation width 2
opt.softtabstop = 2 -- Soft tab stop
opt.expandtab = true -- Tabs to spaces
opt.smartindent = true -- Smart indentation
-- opt.autoindent = true -- Auto indentation
-- opt.cindent = true -- C-style indentation for better structure

-- Native indent lines (replaces hlchunk indent)
opt.list = true -- Enable native indent lines
opt.listchars = {
  tab = "  ", -- Tab characters invisible (displayed as normal spaces)
  -- space = "·", -- Make space characters visible
  trail = "•", -- Show trailing spaces (important!)
  -- nbsp = "␣", -- Non-breaking space
  extends = "⟩", -- Lines cut off on the right
  precedes = "⟨", -- Lines cut off on the left
  leadmultispace = "│ ", -- Native indent lines (replaces hlchunk indent)
}

-- Visual Block options
vim.opt.virtualedit = "block" -- Allows cursor position beyond line end in Visual Block mode
-- vim.opt.selection = "exclusive" -- Better Visual Block selection
vim.opt.selectmode = "" -- Prevents Select Mode, prefers Visual Mode

-- Search
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Case-sensitive if uppercase used
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Incremental search

-- Windows and splits
opt.splitbelow = true -- Horizontal splits below
opt.splitright = true -- Vertical splits right

-- Files
opt.clipboard = "unnamedplus" -- System clipboard
opt.fileencoding = "utf-8" -- Default file encoding
opt.swapfile = false -- No swap files
opt.backup = false -- No backup files
opt.undofile = true -- Persistent undo history
opt.autoread = true -- Automatically reload externally modified files

-- Performance (WezTerm optimized + ultra responsiveness)
opt.updatetime = 250 -- Optimized for WezTerm responsiveness
opt.timeoutlen = 500 -- Timeout for key combinations
opt.ttimeoutlen = 10 -- Very fast terminal escapes (critical for WezTerm)
opt.lazyredraw = false -- Immediate redraw for smooth cursor movement
opt.ttyfast = true -- Terminal optimization for WezTerm
opt.redrawtime = 10000 -- More time for complex syntax highlighting

-- Ultra-performance optimizations
opt.regexpengine = 0 -- Auto-select regex engine (back to default for compatibility)
opt.maxmempattern = 2000 -- Increased pattern memory for better performance
opt.synmaxcol = 300 -- Limit syntax highlighting for long lines
opt.matchtime = 1 -- Very short bracket match time
opt.complete:remove({ "i", "t" }) -- No include/tag completion (slow)

-- Appearance (WezTerm-optimized)
opt.termguicolors = true -- True-color support
opt.wrap = false -- No line wrapping
opt.showmode = false -- Disable mode display (replaced by statusline)
opt.ruler = false -- No native ruler (lualine shows position)
opt.title = true -- Set window title
opt.pumheight = 10 -- Limit popup menu height
opt.showtabline = 0 -- No native tabline (bufferline plugin handles it)
opt.laststatus = 0 -- No native statusline (lualine plugin handles it)

-- Whitespace display (remove Neo-tree tildes)
opt.fillchars = {
  eob = " ", -- End-of-buffer character (removes ~ tildes in empty lines)
}

-- WezTerm-specific performance optimizations
opt.mouse = "a" -- Mouse support for WezTerm
opt.display = "lastline" -- Show as much as possible of the last line

-- Advanced performance tweaks
opt.eventignore = "" -- Don't ignore events (but ready for selective ignoring)
opt.maxfuncdepth = 200 -- Increased function depth for complex syntax

-- Memory & history optimizations (MyNvim-inspired)
opt.history = 1000 -- Command history limited (less RAM)
-- ShaDa (Shared Data) - Modern session persistence for Neovim
-- '100 = Remember 100 marked files (Marks: ma, mb, etc.)
-- <50 = Save 50 lines from registers/yanks across sessions
--       IMPORTANT: Current session yank/paste remains unlimited (1222 lines → 1222 lines paste)
--       Limit only applies to cross-session persistence after restart
-- s10 = 10KB maximum per register/item (prevents memory bloat)
-- h = Highlight-search disabled at startup (clean start)
opt.shada = "'100,<50,s10,h" -- Performance-optimized ShaDa (15-25% faster startup)
opt.foldnestmax = 10 -- Fold level limited for performance
opt.viminfo = "" -- Legacy VimInfo disabled (ShaDa is modern alternative)

-- Folding - overridden by Treesitter for better code structure
-- opt.foldmethod = "indent" -- Folding based on indentation
-- opt.foldlevel = 99 -- All folds open by default
-- opt.foldlevelstart = 99 -- Start with open folds
opt.foldminlines = 2 -- Minimum 2 lines for fold

-- Neovim 0.11 Performance: Redraw optimization for long lines
opt.maxmempattern = 5000 -- Pattern memory limit (default: 1000)
opt.synmaxcol = 300 -- Syntax highlighting only up to column 300 (better redraw performance)