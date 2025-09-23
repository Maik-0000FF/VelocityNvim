-- ~/.config/VelocityNvim/lua/plugins/tools/fzf-lua.lua
-- DEFAULT-PROFILE fzf-lua Konfiguration (CLAUDE.md optimiert)
-- BEGRÜNDUNG: "default" Profile nutzt Standard fzf-lua Look mit NerdFont Icons
-- VALIDATION: WebSearch + Tests bestätigt - Ersetzt 200+ Zeilen Custom-Config

-- Icons laden für VelocityNvim-spezifische Features
local icons = require("core.icons")

-- Delta integration check for enhanced Git performance
local use_delta = vim.fn.executable("delta") == 1

-- DEFAULT-PROFILE OPTIMIERUNG: Minimale Standard-Konfiguration
require("fzf-lua").setup({
  -- MINIMAL Custom-Overrides nur wo VelocityNvim-spezifische Features erforderlich:

  -- BEGRÜNDUNG: VelocityNvim Rust Performance Suite - Delta Git Integration
  git = {
    status = {
      preview_pager = use_delta and "delta --features=interactive --width=$FZF_PREVIEW_COLUMNS" or nil,
    },
    commits = {
      preview = use_delta and "git show --color=always {1} | delta --features=interactive" or nil,
    },
    bcommits = {
      preview = use_delta and "git show --color=always {1} -- <file> | delta --features=interactive" or nil,
    },
  },

  -- BEGRÜNDUNG: VelocityNvim Diagnostic Icons Integration (aus core.icons)
  diagnostics = {
    signs = {
      ["Error"] = { text = icons.diagnostics.error, texthl = "DiagnosticError" },
      ["Warn"] = { text = icons.diagnostics.warn, texthl = "DiagnosticWarn" },
      ["Info"] = { text = icons.diagnostics.info, texthl = "DiagnosticInfo" },
      ["Hint"] = { text = icons.diagnostics.hint, texthl = "DiagnosticHint" },
    },
  },
})

-- ALLE ANDEREN FEATURES NUTZEN DEFAULT-PROFILE STANDARDS:
-- ✅ Winopts: Standard fzf window layout und border
-- ✅ Keymap: Standard fzf keybindings (Ctrl+j/k, F1-F6, etc.)
-- ✅ Fzf_opts: Native fzf prompt (> ), pointer, marker
-- ✅ Preview: Standard builtin previewer mit devicons
-- ✅ File Icons: Standard devicons integration (NerdFont - keine Emojis)
-- ✅ Git Icons: Standard git file indicators
-- ✅ LSP: Standard symbol icons und navigation
-- ✅ Performance: Optimized defaults ohne Custom-Overhead

-- VelocityNvim Standard-Keymaps (unverändert - funktionieren mit jedem Profile)
local map = vim.keymap.set

-- File navigation
map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>FzfLua git_files<CR>", { desc = "Find git files" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Find buffers" })

-- Search
map("n", "<leader>fw", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fs", "<cmd>FzfLua grep_string<CR>", { desc = "Grep string under cursor" })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>", { desc = "Help tags" })

-- LSP
map("n", "<leader>lr", "<cmd>FzfLua lsp_references<CR>", { desc = "LSP references" })
map("n", "<leader>ld", "<cmd>FzfLua lsp_definitions<CR>", { desc = "LSP definitions" })
map("n", "<leader>ls", "<cmd>FzfLua lsp_document_symbols<CR>", { desc = "Document symbols" })
map("n", "<leader>lw", "<cmd>FzfLua lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })
map("n", "<leader>le", "<cmd>FzfLua diagnostics_document<CR>", { desc = "Document diagnostics" })
map("n", "<leader>lE", "<cmd>FzfLua diagnostics_workspace<CR>", { desc = "Workspace diagnostics" })
map("n", "<leader>lR", "<cmd>LspRefresh<CR>", { desc = "Refresh LSP workspace scan" })

-- Git
map("n", "<leader>gs", "<cmd>FzfLua git_status<CR>", { desc = "Git status" })
map("n", "<leader>gc", "<cmd>FzfLua git_commits<CR>", { desc = "Git commits" })
map("n", "<leader>gb", "<cmd>FzfLua git_branches<CR>", { desc = "Git branches" })

-- Resume last search
map("n", "<leader>fl", "<cmd>FzfLua resume<CR>", { desc = "Resume last search" })