-- Force Rust implementation for blink.cmp - ORIGINAL WORKING VERSION
local function force_rust_implementation()
    vim.defer_fn(function()
        local ok, fuzzy = pcall(require, 'blink.cmp.fuzzy')
        if ok then
            local rust_ok, _ = pcall(require, 'blink_cmp_fuzzy')
            if rust_ok then
                fuzzy.set_implementation('rust')
                -- Silent success - Rust performance active
            else
                vim.notify("Blink.cmp: Rust module not available - Fallback to Lua", vim.log.levels.WARN)
            end
        end
    end, 500)
end

-- Hook into blink.cmp setup - ORIGINAL METHOD
local original_setup = require('blink.cmp').setup
require('blink.cmp').setup = function(opts)
    original_setup(opts)
    force_rust_implementation()
end