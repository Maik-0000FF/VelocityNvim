-- German Character Input Plugin
-- Provides US keyboard to German character mappings using backtick prefix
-- Based on original custom implementation for German typing support

local M = {}

function M.setup()
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true, desc = "German chars" }

  -- Configurable prefix for German character input
  local prefix = "`"

  -- German Umlauts (lowercase)
  map("i", prefix .. "a", "ä", vim.tbl_extend("force", opts, { desc = "Insert ä" }))
  map("i", prefix .. "o", "ö", vim.tbl_extend("force", opts, { desc = "Insert ö" }))
  map("i", prefix .. "u", "ü", vim.tbl_extend("force", opts, { desc = "Insert ü" }))

  -- German Umlauts (uppercase)
  map("i", prefix .. "A", "Ä", vim.tbl_extend("force", opts, { desc = "Insert Ä" }))
  map("i", prefix .. "O", "Ö", vim.tbl_extend("force", opts, { desc = "Insert Ö" }))
  map("i", prefix .. "U", "Ü", vim.tbl_extend("force", opts, { desc = "Insert Ü" }))

  -- German Eszett
  map("i", prefix .. "s", "ß", vim.tbl_extend("force", opts, { desc = "Insert ß" }))

  -- Additional special characters
  map("i", prefix .. "e", "€", vim.tbl_extend("force", opts, { desc = "Insert €" }))
  map("i", prefix .. "c", "©", vim.tbl_extend("force", opts, { desc = "Insert ©" }))
  map("i", prefix .. "r", "®", vim.tbl_extend("force", opts, { desc = "Insert ®" }))
  map("i", prefix .. "t", "™", vim.tbl_extend("force", opts, { desc = "Insert ™" }))

  -- Silent success - no notification needed for expected behavior
end

-- Register health check for the German characters plugin
local function check_german_chars_health()
  local health = require("core.health")

  health.report_start("German Characters")

  -- Check if keymaps are properly set
  local test_maps = {
    { "`a", "ä" },
    { "`s", "ß" },
    { "`e", "€" },
  }

  local working_maps = 0
  for _, map_test in ipairs(test_maps) do
    local keymap = vim.fn.maparg(map_test[1], "i")
    if keymap == map_test[2] then
      working_maps = working_maps + 1
    end
  end

  if working_maps == #test_maps then
    health.report_ok(
      "All German character mappings active (" .. working_maps .. "/" .. #test_maps .. ")"
    )
  else
    health.report_warn(
      "Some German character mappings missing (" .. working_maps .. "/" .. #test_maps .. ")"
    )
  end

  health.report_info("Usage: Type `a → ä, `s → ß, `e → €, etc.")
end

-- Register with health system
local ok, health = pcall(require, "core.health")
if ok and health.register then
  health.register("german_chars", check_german_chars_health)
end

-- Initialize the plugin
M.setup()

return M
