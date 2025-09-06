-- ~/.config/VelocityNvim/lua/plugins/conform.lua
-- Ultra-schneller Autoformatter

require("conform").setup({
  -- Formatter pro Dateityp
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    less = { "prettier" },
    vue = { "prettier" },
    svelte = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    fish = { "fish_indent" },
    toml = { "taplo" },
    xml = { "xmlformat" },
    sql = { "sqlformat" },
    go = { "goimports", "gofmt" },
    rust = { "rustfmt" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    -- Fallback für unbekannte Dateitypen
    ["_"] = { "trim_whitespace" },
  },

  -- Globale Formatter-Einstellungen
  format_on_save = {
    -- Automatisches Formatieren beim Speichern
    timeout_ms = 2000,
    lsp_fallback = true,
  },

  -- Format nach Delay im Insert-Modus (optional)
  format_after_save = {
    lsp_fallback = true,
  },

  -- Notify-Level für Formatierungs-Fehler
  notify_on_error = true,

  -- Custom Formatter-Konfigurationen
  formatters = {
    -- StyLua für Lua (bessere Performance-Einstellungen)
    stylua = {
      prepend_args = {
        "--column-width",
        "100",
        "--line-endings",
        "Unix",
        "--indent-type",
        "Spaces",
        "--indent-width",
        "2",
        "--quote-style",
        "AutoPreferDouble",
      },
    },

    -- Prettier mit Standard-Einstellungen (ohne prettierd)
    prettier = {
      args = {
        "--stdin-filepath",
        "$FILENAME",
        "--tab-width=2",
        "--use-tabs=false",
        "--single-quote=false",
        "--trailing-comma=es5",
        "--bracket-spacing=true",
        "--prose-wrap=preserve",
      },
    },

    -- Ruff Format - Ultraschneller Python Formatter (10-100x schneller als black)
    ruff_format = {
      command = "ruff",
      args = {
        "format",
        "--line-length=88",
        "--stdin-filename",
        "$FILENAME",
        "-",
      },
      stdin = true,
    },

    -- Ruff Import Organizer - Ersetzt isort (deutlich schneller)
    ruff_organize_imports = {
      command = "ruff",
      args = {
        "check",
        "--select=I",
        "--fix",
        "--stdin-filename",
        "$FILENAME",
        "-",
      },
      stdin = true,
    },

    -- Shfmt für Shell-Scripts
    shfmt = {
      prepend_args = { "-i", "2", "-ci" },
    },

    -- ClangFormat für C/C++
    clang_format = {
      prepend_args = {
        "--style={IndentWidth: 2, TabWidth: 2, UseTab: Never}",
      },
    },
  },
})

-- Keymaps für manuelles Formatieren
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 2000,
  })
end, { desc = "Format file or range (in visual mode)" })

-- Toggle auto-format on save
vim.keymap.set("n", "<leader>uf", function()
  local conform = require("conform")
  if conform.will_fallback_lsp() then
    -- Silent success - Auto-format toggle ist erwartetes Verhalten
    conform.setup({ format_on_save = false })
  else
    -- Silent success - Auto-format toggle ist erwartetes Verhalten
    conform.setup({
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end
end, { desc = "Toggle auto-format on save" })

-- Format specific language
vim.keymap.set("n", "<leader>ml", function()
  require("conform").format({
    formatters = { "stylua" },
    timeout_ms = 2000,
  })
end, { desc = "Format with StyLua" })

-- Format nur bestimmte Zeilen (Visual Mode)
vim.keymap.set("v", "<leader>mp", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 2000,
    range = {
      start = vim.fn.line("'<"),
      ["end"] = vim.fn.line("'>"),
    },
  })
end, { desc = "Format selected lines" })

-- Trailing whitespace wird jetzt in core/autocmds.lua behandelt

-- ConformInfo Command wird jetzt in core/commands.lua als FormatInfo behandelt
