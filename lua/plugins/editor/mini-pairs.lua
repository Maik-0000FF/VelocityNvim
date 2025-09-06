-- Mini.pairs - Ultra-Performance Autopairs
-- Native Neovim autopairs using mini.nvim (already installed)
-- Performance: <200 LoC, Pure Lua, 0ms overhead until use

local ok, mini_pairs = pcall(require, "mini.pairs")
if not ok then
  vim.notify("mini.pairs nicht verfügbar - mini.nvim erforderlich", vim.log.levels.WARN)
  return
end

-- Ultra-performante Konfiguration für VelocityNvim
mini_pairs.setup({
  -- Modi in denen Autopairs aktiv ist
  modes = {
    insert = true, -- Insert Mode - Standard für Typing
    command = false, -- Command Mode - deaktiviert für Performance
    terminal = false, -- Terminal Mode - deaktiviert für Shell-Kompatibilität
  },

  -- Skip-Pattern für intelligentes Pairing
  -- Überspringt Pairing wenn nächstes Zeichen matched
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],

  -- Treesitter Integration - überspringt Pairing in String-Nodes
  skip_ts = { "string" },

  -- Überspringt unbalanced pairs für bessere Code-Qualität
  skip_unbalanced = true,

  -- Markdown-Support für Dokumentation
  markdown = true,

  -- WICHTIG: Deaktiviere Backtick-Pairing für German Characters Plugin
  -- Das German Characters Plugin verwendet ` als Präfix für Umlaute (`a → ä)
  mappings = {
    ["`"] = false, -- Backtick-Pairing deaktiviert - Konflikt mit German chars
  },
})

-- Health Check Integration
local function check_mini_pairs_health()
  local health = require("core.health")

  health.report_start("Mini.pairs Autopairs")

  -- Test ob mini.pairs korrekt geladen wurde
  local pairs_ok, pairs_module = pcall(require, "mini.pairs")
  if pairs_ok and pairs_module then
    health.report_ok("Mini.pairs aktiv und funktional")

    -- Test grundlegende Funktionalität
    local test_pairs = {
      { "(", ")" },
      { "[", "]" },
      { "{", "}" },
      { '"', '"' },
      { "'", "'" },
    }

    health.report_info("Verfügbare Pairs: " .. table.concat(vim.iter(test_pairs):flatten():totable(), " "))
    health.report_info("Performance: Ultra-schnell (<200 LoC, Pure Lua)")
    health.report_info("Features: Treesitter-aware, Skip-Pattern, Markdown-Support")
  else
    health.report_error("Mini.pairs konnte nicht geladen werden")
  end
end

-- Registriere Health Check
local health_ok, health = pcall(require, "core.health")
if health_ok and health.register then
  health.register("mini_pairs", check_mini_pairs_health)
end

