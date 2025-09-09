-- ~/.config/VelocityNvim/lua/plugins/noice.lua
-- Noice Plugin Konfiguration

-- Icons laden
local icons = require("core.icons")

-- Moderne UI-Einstellungen
vim.opt.cmdheight = 0

-- Noice Setup
require("noice").setup({
  -- ============================================================================
  -- CMDLINE-KONFIGURATION
  -- ============================================================================
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
    opts = {},
    format = {
      cmdline = { pattern = "^:", icon = "", lang = "vim" },
      search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
      search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
      filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
      lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
      help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
      input = {},
    },
  },

  -- ============================================================================
  -- NACHRICHTEN-HANDLING
  -- ============================================================================
  messages = {
    enabled = false, -- Deaktiviert für saubere UI
  },

  -- ============================================================================
  -- POPUP-MENÜ
  -- ============================================================================
  popupmenu = {
    enabled = true,
    backend = "nui",
    kind_icons = {},
  },

  -- ============================================================================
  -- WEITERLEITUNG
  -- ============================================================================
  redirect = {
    view = "popup",
    filter = { event = "msg_show" },
  },

  -- ============================================================================
  -- BEFEHLE
  -- ============================================================================
  commands = {
    history = {
      view = "split",
      opts = { enter = true, format = "details" },
      filter = {
        any = {
          { event = "notify" },
          { error = true },
          { warning = true },
          { event = "msg_show", kind = { "" } },
          { event = "lsp", kind = "message" },
        },
      },
    },
    last = {
      view = "popup",
      opts = { enter = true, format = "details" },
      filter = {
        any = {
          { event = "notify" },
          { error = true },
          { warning = true },
          { event = "msg_show", kind = { "" } },
          { event = "lsp", kind = "message" },
        },
      },
      filter_opts = { count = 1 },
    },
    errors = {
      view = "popup",
      opts = { enter = true, format = "details" },
      filter = { error = true },
      filter_opts = { reverse = true },
    },
  },

  -- ============================================================================
  -- BENACHRICHTIGUNGEN
  -- ============================================================================
  notify = {
    enabled = true,
    view = "notify",
  },

  -- ============================================================================
  -- LSP-INTEGRATION
  -- ============================================================================
  lsp = {
    progress = {
      enabled = true,
      format = "lsp_progress",
      format_done = "lsp_progress_done",
      throttle = 1000 / 30,
      view = "mini",
    },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    hover = {
      enabled = true,
      silent = false,
      view = nil,
      opts = {},
    },
    signature = {
      enabled = true,
      auto_open = {
        enabled = true,
        trigger = true,
        luasnip = true,
        throttle = 50,
      },
      view = nil,
      opts = {},
    },
    message = {
      enabled = true,
      view = "notify",
      opts = {},
    },
    documentation = {
      view = "hover",
      opts = {
        lang = "markdown",
        replace = true,
        render = "plain",
        format = { "{message}" },
        win_options = { concealcursor = "n", conceallevel = 3 },
      },
    },
  },

  -- ============================================================================
  -- MARKDOWN-UNTERSTÜTZUNG
  -- ============================================================================
  markdown = {
    hover = {
      ["|(%S-)|"] = vim.cmd.help,
      ["%[.-%]%((%S-)%)"] = function(url)
        vim.fn.system({ "xdg-open", url })
      end,
    },
    highlights = {
      ["|%S-|"] = "@text.reference",
      ["@%S+"] = "@parameter",
      ["^%s*(Parameters:)"] = "@text.title",
      ["^%s*(Return:)"] = "@text.title",
      ["^%s*(See also:)"] = "@text.title",
      ["{%S-}"] = "@parameter",
    },
  },

  -- ============================================================================
  -- SYSTEM-OPTIONEN
  -- ============================================================================
  health = {
    checker = false,
  },
  smart_move = {
    enabled = true,
    excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
  },
  presets = {
    bottom_search = false,
    command_palette = false,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = false,
  },
  throttle = 1000 / 30,

  -- ============================================================================
  -- VIEW-KONFIGURATION
  -- ============================================================================
  views = {
    cmdline_popup = {
      position = {
        row = "50%",
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
      },
    },
    popupmenu = {
      relative = "editor",
      position = {
        row = "60%",
        col = "50%",
      },
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
      },
    },
    cmdline_search = {
      position = {
        row = "50%",
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
      },
    },
  },

  -- ============================================================================
  -- ROUTE-FILTER
  -- ============================================================================
  routes = {
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
          { find = "%d fewer lines" },
          { find = "%d more lines" },
        },
      },
      opts = { skip = true },
    },
    {
      filter = {
        event = "notify",
        find = "No information available",
      },
      opts = { skip = true },
    },
    -- Unterdrücke Befehlsanzeige für Leader-Key Befehle
    {
      filter = {
        event = "msg_show",
        kind = "",
        any = {
          { find = "^:" },
          { find = "^/" },
          { find = "^%?" },
        },
      },
      opts = { skip = true },
    },
    -- Unterdrücke spezifische Befehle
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "BufferLine" },
          { find = "Noice" },
          { find = "Neotree" },
          { find = "checkhealth" },
        },
      },
      opts = { skip = true },
    },
  },
})

-- Removed force redraw - caused cursor jumping and performance impact

-- ============================================================================
-- STARTUP-CLEANUP
-- ============================================================================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd("messages clear")
    end, 100)
  end,
  once = true,
})

-- ============================================================================
-- NOICE-BEFEHLE
-- ============================================================================
-- NOTE: Noice Commands deaktiviert weil messages = false für saubere Statusline
-- vim.keymap.set("n", "<leader>nh", "<cmd>Noice history<cr>", { desc = "Noice History" })
-- vim.keymap.set("n", "<leader>nl", "<cmd>Noice last<cr>", { desc = "Noice Last Message" })  
-- vim.keymap.set("n", "<leader>ne", "<cmd>Noice errors<cr>", { desc = "Noice Errors" })

-- ============================================================================
-- NOTIFY-INTEGRATION
-- ============================================================================
local notify = require("notify")

notify.setup({
  background_colour = "NotifyBackground",
  fps = 30,
  level = 0,
  minimum_width = 60,
  max_width = 120,
  render = "wrapped-compact",
  stages = "fade_in_slide_out",
  timeout = 5000,
  top_down = true,
  icons = {
    ERROR = icons.diagnostics.error,
    WARN = icons.diagnostics.warn,
    INFO = icons.diagnostics.info,
    DEBUG = "󰆥",
    TRACE = "✎",
  },
})

-- Setze notify als Standard-Handler
vim.notify = notify
