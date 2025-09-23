-- ~/.config/VelocityNvim/lua/plugins/neo-tree.lua
-- Neo-tree Plugin Konfiguration

-- Icons laden
local icons = require("core.icons")

-- Vim global für LSP definieren
---@diagnostic disable-next-line: undefined-global
local vim = vim

-- Neo-tree Setup
local options = {
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  sort_case_insensitive = true,
  -- Sources definieren
  sources = {
    "filesystem",
    "buffers",
    "git_status",
  },
  source_selector = {
    winbar = true, -- Aktiviert den Source-Selector in der Fensterleiste
    statusline = false, -- Deaktiviert den Source-Selector in der Statusleiste
    content_layout = "center",
    sources = { -- Definiert die angezeigten Tabs
      { source = "filesystem", display_name = icons.files.folder.default .. " Files " },
      { source = "buffers", display_name = icons.misc.buffer .. " Buffers " },
      { source = "git_status", display_name = icons.git.gitsymbol .. " Git " },
    },
  },
  default_component_configs = {
    container = {
      enable_character_fade = true,
    },
    indent = {
      indent_size = 2,
      padding = 1,
      with_markers = true,
      indent_marker = icons.hlchunk.indent.line,
      last_indent_marker = icons.hlchunk.chunk.left_bottom_neotree,
      highlight = "NeoTreeIndentMarker",
      with_expanders = true,
      expander_collapsed = icons.ui.arrow_right,
      expander_expanded = icons.ui.arrow_down,
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = icons.files.folder.default,
      folder_open = icons.files.folder.open,
      folder_empty = icons.files.folder.empty,
      folder_empty_open = icons.files.folder.empty_open,
      default = icons.files.default,
      highlight = "NeoTreeFileIcon",
    },
    modified = {
      symbol = icons.files.modified,
      highlight = "NeoTreeModified",
    },
    diagnostics = {
      symbols = {
        error = icons.diagnostics.error .. " ",
        warn = icons.diagnostics.warn .. " ",
        info = icons.diagnostics.info .. " ",
        hint = icons.diagnostics.hint .. " ",
      },
      highlights = {
        error = "DiagnosticSignError",
        warn = "DiagnosticSignWarn",
        info = "DiagnosticSignInfo",
        hint = "DiagnosticSignHint",
      },
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = "NeoTreeFileName",
      highlight_opened_files = true, -- Geöffnete Dateien hervorheben
      highlight_diagnostics = true,
    },
    git_status = {
      symbols = {
        added = icons.git.addedsymbol,
        modified = icons.git.changesymbol,
        deleted = icons.git.deletesymbol,
        renamed = icons.git.renamed,
        untracked = icons.git.untracked,
        ignored = icons.git.ignored,
        unstaged = icons.git.unstaged,
        staged = icons.git.staged,
        conflict = icons.git.unmerged,
      },
    },
  },
  window = {
    position = "right",
    width = 40,
    mapping_options = {
      noremap = true,
      nowait = true,
    },
    mappings = {
      ["<space>"] = {
        "toggle_node",
        nowait = false,
      },
      ["<2-LeftMouse>"] = "open",
      ["<cr>"] = "open",
      ["S"] = "open_split",
      ["s"] = "open_vsplit",
      ["t"] = "open_tabnew",
      ["w"] = "open_with_window_picker",
      ["C"] = "close_node",
      ["a"] = "add",
      ["A"] = "add_directory",
      ["d"] = "delete",
      ["r"] = "rename",
      ["y"] = "copy_to_clipboard",
      ["x"] = "cut_to_clipboard",
      ["p"] = "paste_from_clipboard",
      ["c"] = "copy",
      ["m"] = "move",
      ["q"] = "close_window",
      ["R"] = "refresh",
      ["?"] = "show_help",
      ["<"] = "prev_source",
      [">"] = "next_source",
    },
  },
  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = true,
      hide_by_name = {
        "node_modules",
      },
      hide_by_pattern = {
        "*.meta",
      },
      always_show = {
        ".gitignored",
      },
      never_show = {
        ".DS_Store",
        "thumbs.db",
      },
      never_show_by_pattern = {
        "*.meta",
      },
    },
    follow_current_file = {
      enabled = true,
    },
    hijack_netrw_behavior = "open_default",
    use_libuv_file_watcher = true, -- Aktiviert den File-Watcher für automatische Aktualisierung
  },
  buffers = {
    follow_current_file = {
      enabled = true,
    },
    group_empty_dirs = true,
    show_unloaded = true,
  },
  git_status = {
    window = {
      position = "float",
    },
  },
}

-- Benutzerdefinierte Farben für Neo-tree
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Neon-Orange Farbe für Einrückungslinien
    vim.api.nvim_set_hl(0, "NeoTreeIndentMarker", { fg = "#ff9e64" }) -- Neon-Orange
    vim.api.nvim_set_hl(0, "NeoTreeExpander", { fg = "#ff9e64" }) -- Neon-Orange
  end,
})

-- Führen Sie die Funktion auch sofort aus (nicht nur beim ColorScheme-Event)
vim.api.nvim_set_hl(0, "NeoTreeIndentMarker", { fg = "#ff9e64" })
vim.api.nvim_set_hl(0, "NeoTreeExpander", { fg = "#ff9e64" })

require("neo-tree").setup(options)