-- ~/.config/VelocityNvim/lua/plugins/tools/vim-startuptime.lua
-- Startup Time Profiling und Benchmark-Analyse

local M = {}

function M.setup()
  local icons = require("core.icons")

  -- Command für schnellen Zugriff auf detaillierte Startup-Analyse
  vim.api.nvim_create_user_command("BenchmarkStartup", function()
    vim.cmd("StartupTime")
  end, {
    desc = "Analyze VelocityNvim startup performance (detailed plugin breakdown)",
  })

  -- Keybinding für Benchmark-Analyse (optional, kann in keymaps.lua integriert werden)
  vim.keymap.set("n", "<leader>bs", "<cmd>StartupTime<CR>", {
    desc = icons.status.stats .. " Startup Benchmark",
    silent = true,
  })
end

return M
