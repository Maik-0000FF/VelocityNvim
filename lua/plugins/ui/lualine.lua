-- ~/.config/VelocityNvim/lua/plugins/lualine.lua
-- Lualine Plugin Konfiguration

-- Icons laden
local icons = require("core.icons")

-- Compatibility layer
local uv = vim.uv or vim.loop


-- Python venv Anzeigefunktion
local function python_venv()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    -- Extrahiere nur den Namen der virtuellen Umgebung
    return string.match(venv, "[^/]+$")
  end
  return ""
end

-- Dateischutz-Statusanzeige mit Berechtigungen
local function file_protection_status()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    return ""
  end

  -- Prüfe, ob aktuelle Datei eine Datei auf dem Dateisystem ist
  local stats = uv.fs_stat(filepath)
  if not stats then
    return "" -- Keine Datei (z.B. NeoTree-Buffer)
  end

  -- Hole aktuelle Dateiberechtigungen unabhängig vom Status
  local current_mode = ""
  local stat_cmd = "stat -c '%a' " .. vim.fn.shellescape(filepath)
  local stat_ok, stat_result = pcall(vim.fn.system, stat_cmd)

  if stat_ok and stat_result then
    current_mode = stat_result:gsub("\n", "")
  end

  -- Status aus der globalen Statusvariable
  local status = "none"
  if _G.file_protection_status == nil then
    _G.file_protection_status = {}
  end
  if _G.file_protection_status[filepath] then
    status = _G.file_protection_status[filepath]
  end

  -- Emoji-Map für verschiedene Schutzlevel
  local emoji_map = {
    none = "", -- Kein Emoji bei normalem Status
    readonly = icons.status.shield .. " ", -- Nur Lesen
    executable = icons.system.binary .. " ", -- Ausführbar
    owner = icons.status.warning .. " ", -- Besitzer-Schutz
    group = icons.status.config .. " ", -- Gruppen-Schutz
    public = icons.status.info .. " ", -- Öffentlicher Zugriff
    custom = icons.status.shield .. " ", -- Benutzerdefiniert
  }

  -- Emoji-Zuordnung basierend auf Berechtigungen
  if status == "none" then
    -- Wenn kein expliziter Status gesetzt ist, zeige Emoji basierend auf den Dateirechten
    if current_mode == "400" then
      return icons.status.shield .. " " .. current_mode
    elseif current_mode == "500" then
      return icons.system.binary .. " " .. current_mode
    elseif current_mode == "600" then
      return icons.status.warning .. " " .. current_mode
    elseif current_mode == "640" then
      return icons.status.config .. " " .. current_mode
    elseif current_mode == "644" then
      return icons.status.info .. " " .. current_mode
    elseif current_mode:match("^[0-7][0-7][0-7]$") then
      -- Anderes bekanntes Format
      return icons.status.shield .. " " .. current_mode
    else
      -- Nur anzeigen, wenn besonders niedrige Rechte
      local first_digit = current_mode:sub(1, 1)
      if
        first_digit == "0"
        or first_digit == "1"
        or first_digit == "2"
        or first_digit == "3"
        or first_digit == "4"
        or first_digit == "5"
      then
        return icons.status.warning .. " " .. current_mode
      end
      return "" -- Normalfall: keine Anzeige
    end
  end

  -- Andernfalls zeige Status mit den Berechtigungen
  return (emoji_map[status] or "") .. current_mode
end


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
      -- Dateischutz-Status anzeigen
      { file_protection_status },
      { python_venv, icon = "❯ " },
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