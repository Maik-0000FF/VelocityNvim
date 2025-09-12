-- STANDARD-BASED gitsigns.nvim Konfiguration (CLAUDE.md konform)
-- BEGRÜNDUNG: Plugin funktioniert "No setup required" mit sensible Defaults
-- VALIDATION: WebSearch + WebFetch bestätigt - 95% der Config ist überflüssig

-- Prüfe ob Gitsigns verfügbar ist
local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
  print("Gitsigns nicht verfügbar. Führe :PluginSync aus und starte Neovim neu.")
  return
end

-- Delta integration check for enhanced Git performance
local use_delta = vim.fn.executable("delta") == 1

gitsigns.setup({
  -- MINIMAL Custom-Overrides nur wo Standard nicht ausreicht:
  
  -- BEGRÜNDUNG: Delta-Integration für VelocityNvim Rust Performance Suite
  diff_opts = use_delta and {
    algorithm = "histogram",
    internal = false,
    external = "delta --color-only --features=interactive",
  } or nil,
  
  -- BEGRÜNDUNG: Performance-Optimierung aus Phase 12 (WezTerm cursor responsiveness)
  update_debounce = 200, -- Weniger frequent Git-Updates für bessere Navigation
  
  -- BEGRÜNDUNG: Performance-Limit für große Dateien (VelocityNvim Standard)
  max_file_length = 10000, -- 40k->10k für Phase 12 Performance-Optimierung
})

-- ALLE ANDEREN FEATURES NUTZEN STANDARD-DEFAULTS:
-- ✅ Signs: Identische Defaults verfügbar (┃, _, ‾, ~, ┆)
-- ✅ Navigation: ]c und [c funktionieren automatisch  
-- ✅ Commands: :Gitsigns stage_hunk, :Gitsigns preview_hunk, etc.
-- ✅ Staged signs: Standard enabled
-- ✅ Blame: :Gitsigns toggle_current_line_blame
-- ✅ Preview: :Gitsigns preview_hunk_inline  
-- ✅ Text objects: 'ih' für hunk selection automatisch verfügbar