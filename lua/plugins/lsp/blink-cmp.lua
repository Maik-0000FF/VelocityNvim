-- ~/.config/VelocityNvim/lua/plugins/blink-cmp.lua
-- Ultra-performante Blink Completion

-- REMOVED: Force Rust script (replaced with prefer_rust_with_warning for graceful fallback)
-- require('plugins.lsp.blink-cmp-force-rust')

require("blink.cmp").setup({
    keymap = { preset = "default" },

    appearance = {
        nerd_font_variant = "mono",
    },

    completion = {
        documentation = {
            auto_show = false,
        },
    },

    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = {
        -- Use prefer_rust_with_warning for graceful fallback
        implementation = "prefer_rust_with_warning", -- Graceful fallback to Lua if Rust fails
        prebuilt_binaries = {
            download = false, -- Always use local compilation
            force_version = "1.*",
        },
    },

    cmdline = {
        enabled = true,
        keymap = {
            preset = "cmdline",
            -- SICHER: Tab-Navigation
            ["<Tab>"] = { "show_and_insert", "select_next" },
            ["<S-Tab>"] = { "show_and_insert", "select_prev" },
            -- KORRIGIERT: Pfeiltasten mit Fallback für History-Navigation
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
        completion = {
            trigger = {
                show_on_blocked_trigger_characters = {},
                show_on_x_blocked_trigger_characters = {},
            },
            list = {
                selection = {
                    preselect = true,
                    auto_insert = true,
                },
            },
            menu = { auto_show = true },
            ghost_text = { enabled = true },
        },
        sources = function()
            local type = vim.fn.getcmdtype()
            if type == "/" or type == "?" then
                return { "buffer" }
            end
            if type == ":" or type == "@" then
                return { "cmdline" }
            end
            return {}
        end,
    },
})