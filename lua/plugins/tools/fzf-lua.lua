-- ~/.config/VelocityNvim/lua/plugins/fzf-lua.lua
-- Ultra-schneller Fuzzy Finder

-- Icons laden
local icons = require("core.icons")

-- Delta integration check for enhanced Git performance
local use_delta = vim.fn.executable("delta") == 1
local delta_cmd = use_delta and "delta --features=interactive --width=$FZF_PREVIEW_COLUMNS" or "cat"

require("fzf-lua").setup({
  -- Globale Einstellungen
  global_resume = true,
  global_resume_query = true,

  -- Native fzf für maximale Performance (Rust-basiert)
  fzf_bin = "fzf", -- Nutze native fzf binary
  fzf_opts = {
    ["--ansi"] = true,
    ["--info"] = "inline",
    ["--height"] = "~40%",
    ["--layout"] = "reverse",
    ["--border"] = "none",
    ["--prompt"] = "❯ ",
    ["--pointer"] = "▶",
    ["--marker"] = "⚬",
  },

  -- Winopts
  winopts = {
    height = 0.85,
    width = 0.80,
    row = 0.35,
    col = 0.50,
    border = "rounded",
    preview = {
      default = "bat",
      border = "border",
      wrap = "nowrap",
      hidden = "nohidden",
      vertical = "down:45%",
      horizontal = "right:60%",
      layout = "flex",
      flip_columns = 120,
    },
  },

  -- Keymap
  keymap = {
    builtin = {
      ["<F1>"] = "toggle-help",
      ["<F2>"] = "toggle-fullscreen",
      ["<F3>"] = "toggle-preview-wrap",
      ["<F4>"] = "toggle-preview",
      ["<F5>"] = "toggle-preview-ccw",
      ["<F6>"] = "toggle-preview-cw",
      ["<C-d>"] = "preview-page-down",
      ["<C-u>"] = "preview-page-up",
      ["<S-left>"] = "preview-page-reset",
      ["<C-j>"] = "down",
      ["<C-k>"] = "up",
    },
    fzf = {
      ["ctrl-z"] = "abort",
      ["ctrl-u"] = "unix-line-discard",
      ["ctrl-f"] = "half-page-down",
      ["ctrl-b"] = "half-page-up",
      ["ctrl-a"] = "beginning-of-line",
      ["ctrl-e"] = "end-of-line",
      ["alt-a"] = "toggle-all",
      ["f3"] = "toggle-preview-wrap",
      ["f4"] = "toggle-preview",
      ["shift-down"] = "preview-page-down",
      ["shift-up"] = "preview-page-up",
      ["ctrl-j"] = "down",
      ["ctrl-k"] = "up",
      ["alt-j"] = "down",
      ["alt-k"] = "up",
      ["esc"] = "abort",
    },
  },

  -- Dateien
  files = {
    prompt = "Files❯ ",
    multiprocess = true,
    git_icons = true,
    file_icons = true,
    color_icons = true,
    find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
    rg_opts = "--color=never --files --hidden --follow -g '!.git'",
    fd_opts = "--color=never --type f --hidden --follow --exclude .git",
  },

  -- Git
  git = {
    files = {
      prompt = "GitFiles❯ ",
      cmd = "git ls-files --exclude-standard",
      multiprocess = true,
      git_icons = true,
      file_icons = true,
      color_icons = true,
    },
    status = {
      prompt = "GitStatus❯ ",
      preview_pager = delta_cmd,
    },
    commits = {
      prompt = "GitCommits❯ ",
      cmd = "git log --color=always --pretty=format:'%C(yellow)%h%C(reset) - %C(green)(%cr)%C(reset) %s %C(bold blue)<%an>%C(reset)'",
      preview = use_delta and "git show --color=always {1} | delta --features=interactive"
        or "git show --color=always {1}",
    },
    bcommits = {
      prompt = "GitBufCommits❯ ",
      cmd = "git log --color=always --pretty=format:'%C(yellow)%h%C(reset) - %C(green)(%cr)%C(reset) %s %C(bold blue)<%an>%C(reset)' <file>",
      preview = use_delta
          and "git show --color=always {1} -- <file> | delta --features=interactive"
        or "git show --color=always {1} -- <file>",
    },
    branches = {
      prompt = "Branches❯ ",
    },
  },

  -- Grep
  grep = {
    prompt = "Rg❯ ",
    input_prompt = "Grep For❯ ",
    multiprocess = true,
    git_icons = true,
    file_icons = true,
    color_icons = true,
    grep_opts = "--binary-files=without-match --line-number --recursive --color=always --extended-regexp -e",
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
  },

  -- Buffer
  buffers = {
    prompt = "Buffers❯ ",
    file_icons = true,
    color_icons = true,
    sort_lastused = true,
    ignore_current_buffer = false,
  },

  -- Tags
  tags = {
    prompt = "Tags❯ ",
    ctags_file = "tags",
    multiprocess = true,
  },

  -- LSP
  lsp = {
    prompt_postfix = "❯ ",
    cwd_only = false,
    async_or_timeout = 5000,
    file_icons = true,
    git_icons = false,
    color_icons = true,
    includeDeclaration = false,
    symbols = {
      async_or_timeout = true,
      symbol_style = 1,
      symbol_icons = {
        File = icons.files.default,
        Module = icons.misc.plugin,
        Namespace = "󰌗",
        Package = "󰏖",
        Class = "󰌗",
        Method = "󰆧",
        Property = "󰜢",
        Field = "󰆨",
        Constructor = "",
        Enum = "󰻂",
        Interface = "󰜰",
        Function = "󰊕",
        Variable = "󰀫",
        Constant = "󰏿",
        String = "󰀬",
        Number = "󰎠",
        Boolean = "◩",
        Array = "󰅪",
        Object = "󰅩",
        Key = "󰌋",
        Null = "󰟢",
        EnumMember = "󰖽",
        Struct = "󰌗",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "󰊄",
      },
    },
  },

  -- Diagnostics
  diagnostics = {
    prompt = "Diagnostics❯ ",
    cwd_only = false,
    file_icons = true,
    git_icons = false,
    color_icons = true,
    diag_icons = true,
    icon_padding = "",
    multiline = true,
    signs = {
      ["Error"] = { text = icons.diagnostics.error, texthl = "DiagnosticError" },
      ["Warn"] = { text = icons.diagnostics.warn, texthl = "DiagnosticWarn" },
      ["Info"] = { text = icons.diagnostics.info, texthl = "DiagnosticInfo" },
      ["Hint"] = { text = icons.diagnostics.hint, texthl = "DiagnosticHint" },
    },
  },
})

-- Keymaps für fzf-lua
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
