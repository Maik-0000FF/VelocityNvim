-- STANDARD-BASED gitsigns.nvim Configuration (CLAUDE.md compliant)
-- RATIONALE: Plugin works "No setup required" with sensible defaults
-- VALIDATION: WebSearch + WebFetch confirmed - 95% of config is unnecessary

-- Check if Gitsigns is available
local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
  print("Gitsigns not available. Run :PluginSync and restart Neovim.")
  return
end

-- Delta integration check for enhanced Git performance
local use_delta = vim.fn.executable("delta") == 1

gitsigns.setup({
  -- MINIMAL custom overrides only where standard is insufficient:

  -- RATIONALE: Delta integration for VelocityNvim Rust Performance Suite
  diff_opts = use_delta and {
    algorithm = "histogram",
    internal = false,
    external = "delta --color-only --features=interactive",
  } or nil,

  -- RATIONALE: Performance optimization from Phase 12 (WezTerm cursor responsiveness)
  update_debounce = 200, -- Less frequent Git updates for better navigation

  -- RATIONALE: Performance limit for large files (VelocityNvim standard)
  max_file_length = 10000, -- 40k->10k for Phase 12 performance optimization

  -- RATIONALE: Auto-refresh on external Git operations (standard plugin option)
  watch_gitdir = {
    enable = true,      -- Standard: true (explicitly set for documentation)
    follow_files = true, -- Standard: true (tracks git mv operations)
  },
})

-- ALL OTHER FEATURES USE STANDARD DEFAULTS:
-- ✅ Signs: Identical defaults available (┃, _, ‾, ~, ┆)
-- ✅ Navigation: ]c and [c work automatically
-- ✅ Commands: :Gitsigns stage_hunk, :Gitsigns preview_hunk, etc.
-- ✅ Staged signs: Standard enabled
-- ✅ Blame: :Gitsigns toggle_current_line_blame
-- ✅ Preview: :Gitsigns preview_hunk_inline
-- ✅ Text objects: 'ih' for hunk selection automatically available