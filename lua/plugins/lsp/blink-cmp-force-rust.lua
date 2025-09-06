-- Force Rust Implementation für blink.cmp - ORIGINAL FUNKTIONIERENDE VERSION
local function force_rust_implementation()
    vim.defer_fn(function()
        local ok, fuzzy = pcall(require, 'blink.cmp.fuzzy')
        if ok then
            local rust_ok, _ = pcall(require, 'blink_cmp_fuzzy')
            if rust_ok then
                fuzzy.set_implementation('rust')
                -- Silent success - Rust performance aktiv
            else
                vim.notify("Blink.cmp: Rust-Module nicht verfügbar - Fallback zu Lua", vim.log.levels.WARN)
            end
        end
    end, 500)
end

-- Hook in die blink.cmp setup - ORIGINAL METHODE
local original_setup = require('blink.cmp').setup
require('blink.cmp').setup = function(opts)
    original_setup(opts)
    force_rust_implementation()
end