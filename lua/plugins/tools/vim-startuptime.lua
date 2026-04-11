-- ~/.config/VelocityNvim/lua/plugins/tools/vim-startuptime.lua
-- Startup Time Profiling and Benchmark Analysis

local M = {}

function M.setup()
  local icons = require("core.icons")

  -- Command for quick access to detailed startup analysis
  vim.api.nvim_create_user_command("BenchmarkStartup", function()
    vim.cmd.StartupTime()
  end, {
    desc = "Analyze VelocityNvim startup performance (detailed plugin breakdown)",
  })

  -- Keybinding for benchmark analysis (optional, can be integrated in keymaps.lua)
  vim.keymap.set("n", "<leader>bs", "<cmd>StartupTime<CR>", {
    desc = icons.status.stats .. " Startup Benchmark",
    silent = true,
  })
end

return M
