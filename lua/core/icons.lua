-- ~/.config/VelocityNvim/lua/core/icons.lua
-- Native Neovim Icons - Zentrale Icon-Verwaltung

local M = {}

-- Alpha Dashboard Header
M.alpha = {
  header = {
    "                                                                ",
    "                                ██                              ",
    "                               ████                             ",
    "                              ████                            ",
    "                             ██  ██                           ",
    "                            ██    ██                          ",
    "                           ██      ██                         ",
    "                          ██        ██                        ",
    "                         ██          ██                       ",
    "                                                                  ",
    "██        ███████████████ ████████████████    ██",
    " ██      ███    ██ ██   ██ ██     ██   ██   █  ██ ",
    "  ██    ███    ██  ██   ██ ██      ██   ██   ███  ",
    "   ██  █████████   ██   ██ ██       ██   ██   ███   ",
    "    █████    ██    ██   ██ ██        ██   ██  ██    ",
    "     █████    ██     ██   ██ ██         ██   ██ ██     ",
    "      █████████████████████ █████████████   ██      ",
    "                                                                  ",
    "               ██                              ██             ",
    "              ██                                ██            ",
    "             ██                                  ██           ",
    "            ██████████████████████████████████████████          ",
    "                                                                  ",
    -- "                                                                   ",
    -- "                                 █                               ",
    -- "                                ███                              ",
    -- "                               █████                             ",
    -- "                              ██ ██                            ",
    -- "                             ██   ██                           ",
    -- "                            ██     ██                          ",
    -- "                           ██       ██                         ",
    -- "                          ██         ██                        ",
    -- "                         ██           ██                       ",
    -- "                                                                   ",
    -- "██        ███████████████ █████████████████    ██",
    -- " ██      ███    ██ ██   ██ ██      ██   ██   █  ██ ",
    -- "  ██    ███    ██  ██   ██ ██       ██   ██   ███  ",
    -- "   ██  █████████   ██   ██ ██        ██   ██   ███   ",
    -- "    █████    ██    ██   ██ ██         ██   ██  ██    ",
    -- "     █████    ██     ██   ██ ██          ██   ██ ██     ",
    -- "      █████████████████████ ██████████████   ██      ",
    -- "                                                                   ",
    -- "               ██                               ██             ",
    -- "              ██                                 ██            ",
    -- "             ██                                   ██           ",
    -- "            ███████████████████████████████████████████          ",
    -- "                                                                   ",
  },
}

-- Git Icons
M.git = {
  added = "┃",
  change = "┃",
  delete = "_",
  topdelete = "‾",
  changedelete = "~",
  untracked = "┇",
  ignored = "◌",
  unstaged = "✗",
  staged = "✓",
  renamed = "",
  unmerged = "",
  deleted = "",
  addedsymbol = "",
  changesymbol = "",
  deletesymbol = "",
  gitsymbol = "󰊢", --algemeines Git Symbol
  branch = "", -- Git Branch Symbol
}

-- Diagnostic Icons
M.diagnostics = {
  error = "",
  warn = "",
  info = "",
  hint = "󰌶",
}

-- LSP Icons
M.lsp = {
  server = "󰒍",
  client = "",
  workspace = "",
  folder = "",
  file = "",
  text = "󰦨",
  method = "",
  function_icon = "󰊕",
  constructor = "",
  field = "",
  variable = "",
  class = "",
  interface = "",
  module = "󰕳",
  property = "",
  unit = "",
  value = "",
  enum = "",
  keyword = "",
  snippet = "",
  color = "",
  reference = "",
  folder_opened = "",
  default = "",
  references = "",
  definition = "ﴰ",
  implementation = "󰶮",
  code_action = "󰌶", -- MINIMAL ERGÄNZUNG
}

-- Buffer Icons
M.misc = {
  buffer = "",
  vim = "",
  plugin = "󰐱",
  config = "",
  telescope = "",
  terminal = "", -- MINIMAL ERGÄNZUNG
  gear = "",
  party = "󱁖", -- statt 🎉
  rocket = "", -- statt 🚀
  search = "", -- statt 🔍
  scan = "󰚫", -- statt 🔍 (Scan-Variante)
  filter = "󰈳", -- statt 🔍 (Filter-Variante)
  trend_up = "󰔵", -- statt 📈
  trend_down = "󰔳", -- statt 📉
  new = "󰎔", -- statt 🆕
  folder = "󰉋", -- statt 🗂️
  copy = "", -- statt Copy-Symbol
  pin = "", -- statt 📌
  health = "󰓙", -- statt 🩺
  star = "", -- statt ⭐
  build = "󰙨", -- statt 🏗️
  flash = "󰓠", -- statt ⚡
  shield = "󰞀", -- statt 🛡️
  progress = "󰦖", -- statt Fortschritt
  lightbulb = "", -- für Tipps
  info = "", -- zusätzliche Info
}

-- Erweiterte hlchunk Icons
M.hlchunk = {
  indent = {
    line = "│",
  },
  chunk = {
    horizontal_line = "─",
    vertical_line = "│",
    left_top = "╭",
    left_bottom = "╰",
    left_bottom_neotree = "└",
    right_arrow = "─",
  },
}

-- Status/Feedback Icons (NerdFont Performance-optimiert)
M.status = {
  success = "󰄴", -- statt ✅
  error = "󰅚", -- statt ❌
  warning = "", -- statt ⚠️
  loading = "󰝲", -- statt 🔄
  sync = "", -- statt 🔄 (Sync-Variante)
  info = "󰋼", -- statt ℹ️
  hint = "󰌶", -- statt 💡
  warn = "", -- alias für warning
  gear = "", -- alias für gear
  rocket = "", -- für Performance-Status
  vim = "",
  neovim = "",
  health = "󰓙", -- MINIMAL ERGÄNZUNG
  update = "󰚰", -- MINIMAL ERGÄNZUNG
  current = "", -- MINIMAL ERGÄNZUNG
  trend_down = "󰔳", -- MINIMAL ERGÄNZUNG
  -- Weitere benötigte Icons (MINIMAL FIXES)
  stats = "󰋖", -- Statistiken
  fresh = "󰯡", -- Frisch/Neu
  trend_up = "󰔵", -- Aufwärtstrend
  shield = "󰞀", -- Schutzschild
  search = "", -- Suche
  list = "", -- Liste
  scan = "󰚫", -- Scannen
  folder = "󰉋", -- Ordner
  file = "", -- Datei
  recent_file = "", -- bekannte Dateien
  find_file = "󰮗", -- Ordner finden
  config = "", -- Konfiguration
  colorscheme = "", -- Farbschema/Theme
  clipboard = "󰅌", -- Zwischenablage
  clean = "󰃢", -- Säubern
  test = "󰙨", -- Test
  party = "󱁖", -- Party/Feier
  filter = "󰈳", -- Filter
  quit = "󰩈", -- Quit oder Exit
}

-- Performance Icons (RUST-optimiert)
M.performance = {
  fast = "", -- Blitz für Geschwindigkeit
  benchmark = "󰙨", -- Benchmark-Symbol
  rust = "󱘗", -- Rust-Logo (wenn verfügbar)
  optimize = "", -- Zahnrad für Optimierung
}

-- MINIMAL NOTWENDIGE ERGÄNZUNGEN für Plugin-Kompatibilität
M.ui = {
  close = "󰖭",
  arrow_right = "▸",
  arrow_down = "▾",
  checkmark = "✓",
}

M.files = {
  default = "",
  modified = "●",
  folder = {
    default = "",
    open = "",
    empty = "",
    empty_open = "",
  },
}

M.lualine = {
  section_separator_left = "",
  section_separator_right = "",
}

-- System Icons (MINIMAL FIXES)
M.system = {
  binary = "󰘨", -- Ausführbare Datei
}

return M
