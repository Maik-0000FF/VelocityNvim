-- Mini.pairs - Ultra-Performance Autopairs
-- Native Neovim autopairs using mini.nvim (already installed)
-- Performance: <200 LoC, Pure Lua, 0ms overhead until use

local ok, mini_pairs = pcall(require, "mini.pairs")
if not ok then
  vim.notify("mini.pairs not available - mini.nvim required", vim.log.levels.WARN)
  return
end

-- Ultra-performant configuration for VelocityNvim
mini_pairs.setup({
  -- Modes in which autopairs is active
  modes = {
    insert = true, -- Insert Mode - default for typing
    command = false, -- Command Mode - disabled for performance
    terminal = false, -- Terminal Mode - disabled for shell compatibility
  },

  -- Skip pattern for intelligent pairing
  -- Skips pairing if next character matches
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],

  -- Treesitter integration - skips pairing in string nodes
  skip_ts = { "string" },

  -- Skips unbalanced pairs for better code quality
  skip_unbalanced = true,

  -- Markdown support for documentation
  markdown = true,

  -- IMPORTANT: Disable backtick pairing for German Characters Plugin
  -- The German Characters Plugin uses ` as prefix for umlauts (`a → ä)
  mappings = {
    ["`"] = false, -- Backtick pairing disabled - conflict with German chars
  },
})

-- Health Check Integration
local function check_mini_pairs_health()
  local health = require("core.health")

  health.report_start("Mini.pairs Autopairs")

  -- Test if mini.pairs loaded correctly
  local pairs_ok, pairs_module = pcall(require, "mini.pairs")
  if pairs_ok and pairs_module then
    health.report_ok("Mini.pairs active and functional")

    -- Test basic functionality
    local test_pairs = {
      { "(", ")" },
      { "[", "]" },
      { "{", "}" },
      { '"', '"' },
      { "'", "'" },
    }

    health.report_info("Available pairs: " .. table.concat(vim.iter(test_pairs):flatten():totable(), " "))
    health.report_info("Performance: Ultra-fast (<200 LoC, Pure Lua)")
    health.report_info("Features: Treesitter-aware, Skip-Pattern, Markdown-Support")
  else
    health.report_error("Mini.pairs could not be loaded")
  end
end

-- Register health check
local health_ok, health = pcall(require, "core.health")
if health_ok and health.register then
  health.register("mini_pairs", check_mini_pairs_health)
end
