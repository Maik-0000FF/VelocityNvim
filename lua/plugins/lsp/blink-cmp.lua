-- ~/.config/VelocityNvim/lua/plugins/blink-cmp.lua
-- Ultra-performante Blink Completion

require("blink.cmp").setup({
    keymap = { preset = "default" },

    appearance = {
        nerd_font_variant = "mono",
    },

    completion = {
        menu = {
            scrollbar = false, -- Fix: noice.nvim cmdline position conflict
        },
        documentation = {
            auto_show = false,
        },
    },

    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = {
        -- v2: native matcher is built automatically by :PluginSync (see manage.lua).
        -- :BlinkCmp build is the manual fallback if the auto-build is skipped.
        implementation = "prefer_rust_with_warning", -- Graceful fallback to Lua if Rust fails
    },

    cmdline = {
        enabled = true,
        keymap = {
            preset = "cmdline",
            -- SICHER: Tab-Navigation
            ["<Tab>"] = { "show_and_insert", "select_next" },
            ["<S-Tab>"] = { "show_and_insert", "select_prev" },
            -- FIXED: Arrow keys with fallback for history navigation
            ["<Down>"] = { "select_next", "fallback" },
            ["<Up>"] = { "select_prev", "fallback" },
            ["<Right>"] = { "select_and_accept" }, -- Ghost-Text
            -- SICHER: Standard Vim completion keys
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            -- SICHER: Diese kollidieren nicht
            ["<C-j>"] = { "select_next" }, -- OK in cmdline
            ["<C-k>"] = { "select_prev" }, -- OK in cmdline
            -- Aktionen
            ["<C-y>"] = { "select_and_accept" },
            ["<C-e>"] = { "cancel" },
            ["<CR>"] = { "fallback" },
            -- Dokumentation scrollen (sicher)
            ["<C-d>"] = { "scroll_documentation_down" },
            ["<C-u>"] = { "scroll_documentation_up" },
        },
        -- v2: cmdline `sources` and `completion` are managed internally,
        -- no longer user-configurable on the cmdline config.
    },
})