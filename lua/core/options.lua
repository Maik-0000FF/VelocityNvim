-- ~/.config/VelocityNvim/lua/core/options.lua
-- Native Neovim Options - Grundlegende Einstellungen

-- PERFORMANCE: Deaktiviere unnötige Standard-Plugins (~7ms Einsparung)
-- netrw: Alter Datei-Browser (ersetzt durch neo-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- rplugin: Remote-Plugins Python/Node (VelocityNvim nutzt nur Lua/Rust)
vim.g.loaded_remote_plugins = 1

-- Python formatting handled by conform.nvim + ruff
-- Ruff replaces black + isort with better performance
-- Deaktiviere system-weites black.vim Plugin (~5ms Einsparung)
vim.g.load_black = 1

local opt = vim.opt
local g = vim.g

-- Leader-Taste setzen
g.mapleader = " "
g.maplocalleader = " "

-- Grundlegende UI-Optionen
opt.number = true -- Zeilennummern
opt.relativenumber = true -- Relative Zeilennummern
opt.cursorline = true -- Aktuelle Zeile hervorheben
opt.signcolumn = "yes" -- Zeichenspalte für Markierungen
opt.scrolloff = 10 -- Kontext beim Scrollen
opt.sidescrolloff = 8 -- Horizontaler Kontext

-- Tab- und Einrückung (für bessere hlchunk Sichtbarkeit)
opt.tabstop = 2 -- 2 Leerzeichen für Tab (kleinere Abstände)
opt.shiftwidth = 2 -- Einrückungsbreite 2
opt.softtabstop = 2 -- Soft Tab Stop
opt.expandtab = true -- Tabs zu Leerzeichen
opt.smartindent = true -- Intelligente Einrückung
-- opt.autoindent = true -- Auto-Einrückung
-- opt.cindent = true -- C-Style Einrückung für bessere Struktur

-- Native Einrückungslinien (ersetzt hlchunk indent)
opt.list = true -- Aktiviere native indent lines
opt.listchars = {
  tab = "  ", -- Tab-Zeichen unsichtbar (werden als normale Spaces angezeigt)
  -- space = "·", -- Space-Zeichen sichtbar machen
  trail = "•", -- Trailing Spaces anzeigen (wichtig!)
  -- nbsp = "␣", -- Non-breaking Space
  extends = "⟩", -- Zeilen die rechts abgeschnitten sind
  precedes = "⟨", -- Zeilen die links abgeschnitten sind
  leadmultispace = "│ ", -- Native indent lines (ersetzt hlchunk indent)
}

-- Visual Block Optionen
vim.opt.virtualedit = "block" -- Ermöglicht Cursor-Position jenseits des Zeilenendes im Visual Block Mode
-- vim.opt.selection = "exclusive" -- Bessere Visual Block Auswahl
vim.opt.selectmode = "" -- Verhindert Select Mode, bevorzugt Visual Mode

-- Suche
opt.ignorecase = true -- Groß-/Kleinschreibung ignorieren
opt.smartcase = true -- Beachten wenn Großbuchstaben verwendet
opt.hlsearch = true -- Suchergebnisse hervorheben
opt.incsearch = true -- Inkrementelle Suche

-- Fenster und Splits
opt.splitbelow = true -- Horizontale Splits unten
opt.splitright = true -- Vertikale Splits rechts

-- Dateien
opt.clipboard = "unnamedplus" -- System-Zwischenablage
opt.fileencoding = "utf-8" -- Standard-Dateikodierung
opt.swapfile = false -- Keine Swap-Dateien
opt.backup = false -- Keine Backup-Dateien
opt.undofile = true -- Persistente Undo-Geschichte
opt.autoread = true -- Automatisches Neuladen von extern geänderten Dateien

-- Performance (WezTerm optimiert + Ultra Responsiveness)
opt.updatetime = 250 -- Optimiert für WezTerm Responsivität
opt.timeoutlen = 500 -- Timeout für Tastenkombinationen
opt.ttimeoutlen = 10 -- Sehr schnelle Terminal-Escapes (kritisch für WezTerm)
opt.lazyredraw = false -- Sofortiges Redraw für flüssige Cursor-Bewegungen
opt.ttyfast = true -- Terminal-Optimierung für WezTerm
opt.redrawtime = 10000 -- Mehr Zeit für komplexe Syntax-Highlighting

-- Ultra-Performance Optimierungen
opt.regexpengine = 0 -- Auto-select regex engine (zurück zu default für Kompatibilität)
opt.maxmempattern = 2000 -- Erhöhte Pattern-Speicher für bessere Performance
opt.synmaxcol = 300 -- Syntax-Highlighting begrenzen für lange Zeilen
opt.matchtime = 1 -- Sehr kurze Bracket-Match-Zeit
opt.complete:remove("i") -- Keine include-file Completion (langsam)
opt.complete:remove("t") -- Keine tag-file Completion (langsam)

-- Aussehen (WezTerm-optimiert)
opt.termguicolors = true -- True-Color Support
opt.wrap = false -- Keine Zeilenumbrüche
opt.showmode = false -- Modusanzeige deaktivieren (wird von Statuszeile ersetzt)
opt.ruler = false -- Keine native ruler (lualine zeigt Position)
opt.title = true -- Fenstertitel setzen
opt.pumheight = 10 -- Popup-Menühöhe begrenzen
opt.showtabline = 0 -- Keine native tabline (bufferline plugin übernimmt)
opt.laststatus = 0 -- Keine native statusline (lualine plugin übernimmt)

-- Leerzeichen-Darstellung (Neo-tree Tilden entfernen)
opt.fillchars = {
  eob = " ", -- End-of-buffer Zeichen (entfernt ~ Tilden in leeren Zeilen)
}

-- WezTerm-spezifische Performance-Optimierungen
opt.mouse = "a" -- Mouse support für WezTerm
opt.display = "lastline" -- Zeige so viel wie möglich von der letzten Zeile

-- Advanced Performance Tweaks
opt.eventignore = "" -- Keine Events ignorieren (aber bereit für selective ignoring)
opt.maxfuncdepth = 200 -- Erhöhte Funktionstiefe für komplexe Syntax

-- Memory & History Optimierungen (MyNvim-inspiriert)
opt.history = 1000 -- Command history begrenzt (weniger RAM)
-- ShaDa (Shared Data) - Moderne Session-Persistierung für Neovim
-- '100 = 100 markierte Dateien merken (Marks: ma, mb, etc.)
-- <50 = 50 Zeilen aus Registern/Yanks session-übergreifend speichern
--       WICHTIG: Aktuelle Session Yank/Paste bleibt unbegrenzt (1222 Zeilen → 1222 Zeilen paste)
--       Limit gilt nur für Session-übergreifende Persistierung nach Neustart
-- s10 = 10KB Maximum pro Register/Item (verhindert Memory-Bloat)
-- h = Highlight-Search deaktiviert beim Start (sauberer Start)
opt.shada = "'100,<50,s10,h" -- Performance-optimierte ShaDa (15-25% schnelleres Startup)
opt.foldnestmax = 10 -- Fold-Level begrenzt für Performance
opt.viminfo = "" -- Legacy VimInfo deaktiviert (ShaDa ist moderne Alternative)

-- Folding - wird von Treesitter überschrieben für bessere Code-Struktur
-- opt.foldmethod = "indent" -- Falten basierend auf Einrückung
-- opt.foldlevel = 99 -- Alle Folds standardmäßig offen
-- opt.foldlevelstart = 99 -- Start mit offenen Folds
opt.foldminlines = 2 -- Minimum 2 Zeilen für Fold