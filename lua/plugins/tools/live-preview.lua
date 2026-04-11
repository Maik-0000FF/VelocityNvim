-- ~/.config/VelocityNvim/lua/plugins/tools/live-preview.lua
-- Live Markdown/HTML Browser Preview (Pure Lua, no external dependencies)

local ok, config = pcall(require, "livepreview.config")
if not ok then return end

config.set({
  port = 5500,
  browser = "default",
  sync_scroll = true,
  picker = "fzf-lua",
})

-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>up", function()
  vim.cmd("LivePreview start")
end, vim.tbl_extend("force", opts, { desc = "UI: Live Preview start" }))

map("n", "<leader>uP", function()
  vim.cmd("LivePreview close")
end, vim.tbl_extend("force", opts, { desc = "UI: Live Preview stop" }))
