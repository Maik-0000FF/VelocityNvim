-- ~/.config/VelocityNvim/lua/plugins/conform.lua
-- Prettier-based Formatter System

require("conform").setup({
  -- Formatter per file type (Performance Optimized with Intelligent Fallback)
  formatters_by_ft = {
    -- Lua (Rust-based, fast)
    lua = { "stylua" },

    -- Python (Ruff does everything: format + imports + lint)
    python = { "ruff_organize_imports", "ruff_format" },

    -- JavaScript/TypeScript (Prettier)
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },

    -- JSON/CSS (Prettier)
    json = { "prettier" },
    jsonc = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },

    -- Fallback to Prettier for unsupported languages
    html = { "prettier" },
    vue = { "prettier" },
    svelte = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
    less = { "prettier" },
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
    typst = { "typstyle" },
    -- Fallback for unknown file types
    ["_"] = { "trim_whitespace" },
  },

  -- Global formatter settings
  format_on_save = {
    -- PERFORMANCE: Reduced from 2000ms - most formatters complete in <500ms
    timeout_ms = 1000,
    lsp_fallback = true,
  },

  -- Format after delay in insert mode (optional)
  format_after_save = {
    lsp_fallback = true,
  },

  -- Notify level for formatting errors
  notify_on_error = true,

  -- Custom formatter configurations
  formatters = {

    -- StyLua for Lua (better performance settings)
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

    -- Prettier (fallback for unsupported languages)
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

    -- Ruff Import Organizer - Replaces isort (significantly faster)
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

    -- Shfmt for shell scripts
    shfmt = {
      prepend_args = { "-i", "2", "-ci" },
    },

    -- ClangFormat for C/C++
    clang_format = {
      prepend_args = {
        "--style={IndentWidth: 2, TabWidth: 2, UseTab: Never}",
      },
    },
  },
})

-- Keymaps for manual formatting
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Format file or range (in visual mode)" })

-- Toggle auto-format on save
vim.keymap.set("n", "<leader>Tf", function()
  local conform = require("conform")
  if conform.will_fallback_lsp() then
    -- Silent success - auto-format toggle is expected behavior
    conform.setup({ format_on_save = false })
  else
    -- Silent success - auto-format toggle is expected behavior
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
    timeout_ms = 1000,
  })
end, { desc = "Format with StyLua" })

-- Format only specific lines (Visual Mode)
vim.keymap.set("v", "<leader>mp", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
    range = {
      start = vim.fn.line("'<"),
      ["end"] = vim.fn.line("'>"),
    },
  })
end, { desc = "Format selected lines" })

-- Trailing whitespace is now handled in core/autocmds.lua

-- ConformInfo command is now handled in core/commands.lua as FormatInfo

-- Performance Status Command
vim.api.nvim_create_user_command("FormatterPerformanceStatus", function()
  local prettier_available = vim.fn.executable("prettier") == 1
  local ruff_available = vim.fn.executable("ruff") == 1

  print("VelocityNvim Formatter Status:")
  print(
    "──────────────────────────────────────"
  )

  if prettier_available then
    print(" Prettier: ACTIVE (JS/TS/CSS/JSON/HTML/Vue/Svelte/Markdown/YAML)")
  else
    print(" Prettier: NOT FOUND (install via: npm install -g prettier)")
  end

  if ruff_available then
    print(" Ruff: ACTIVE (~10-100x faster Python formatting)")
  else
    print(" Ruff: NOT FOUND (install via: pip install ruff)")
  end

  print(
    "──────────────────────────────────────"
  )
  local performance_score = (prettier_available and 50 or 0) + (ruff_available and 30 or 0)
  print("Performance Score: " .. performance_score .. "/80")

  if performance_score >= 70 then
    print("Status: OPTIMAL")
  elseif performance_score >= 40 then
    print("Status: GOOD")
  else
    print("Status: INCOMPLETE - Install missing formatters")
  end
end, { desc = "Show formatter status" })

-- Benchmark command for testing
vim.api.nvim_create_user_command("FormatterBenchmark", function()
  local start_time = vim.fn.reltime()
  require("conform").format({
    bufnr = 0,
    timeout_ms = 5000,
  })
  local elapsed = vim.fn.reltimestr(vim.fn.reltime(start_time))
  vim.notify("Format completed in " .. elapsed .. "s", vim.log.levels.INFO)
end, { desc = "Benchmark current file formatting" })
