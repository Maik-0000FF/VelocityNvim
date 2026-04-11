-- Strudel.nvim - Live Coding Music from Neovim
-- https://github.com/gruvw/strudel.nvim
-- Requires: npm, chromium-based browser

local ok, strudel = pcall(require, "strudel")
if not ok then
  return
end

-- Detect browser based on OS
local function detect_browser()
  -- macOS: Use default (Chrome/Chromium)
  if vim.fn.has("mac") == 1 then
    return "default"
  end
  -- Linux: Check for chromium/chrome
  if vim.fn.executable("chromium") == 1 then
    return "chromium"
  elseif vim.fn.executable("google-chrome-stable") == 1 then
    return "google-chrome-stable"
  elseif vim.fn.executable("brave") == 1 then
    return "brave"
  end
  return "default"
end

strudel.setup({
  -- Browser to use (auto-detected)
  browser = detect_browser(),

  -- Auto-start Strudel when opening .strudel files
  auto_start = false,

  -- Sync cursor position between Neovim and browser
  cursor_sync = true,
})

-- Keybindings for Strudel
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Custom launch function that also starts the sample server
local function strudel_launch_all()
  -- Start sample server in background
  vim.fn.jobstart("cd ~/strudel/samples && npx @strudel/sampler", { detach = true })
  -- Small delay then launch Strudel
  vim.defer_fn(function()
    vim.cmd("StrudelLaunch")
    vim.notify("Strudel + Sample Server started (Port 5432)", vim.log.levels.INFO)
  end, 500)
end

-- Custom quit function that also kills the sample server
local function strudel_quit_all()
  vim.cmd("StrudelQuit")
  vim.fn.jobstart("pkill -f 'npx.*sampler' 2>/dev/null", { detach = true })
  vim.notify("Strudel + Sample Server stopped", vim.log.levels.INFO)
end

-- Leader + m (music) prefix for Strudel commands
keymap("n", "<Leader>ms", strudel_launch_all, vim.tbl_extend("force", opts, { desc = "Strudel: Launch All" }))
keymap("n", "<Leader>mq", strudel_quit_all, vim.tbl_extend("force", opts, { desc = "Strudel: Quit All" }))
keymap("n", "<Leader>mp", "<cmd>StrudelToggle<CR>", vim.tbl_extend("force", opts, { desc = "Strudel: Play/Stop" }))
keymap("n", "<Leader>mu", "<cmd>StrudelUpdate<CR>", vim.tbl_extend("force", opts, { desc = "Strudel: Update" }))
keymap("n", "<Leader>mh", "<cmd>StrudelStop<CR>", vim.tbl_extend("force", opts, { desc = "Strudel: Stop" }))
keymap("n", "<Leader>me", "<cmd>StrudelExecute<CR>", vim.tbl_extend("force", opts, { desc = "Strudel: Execute" }))
keymap("n", "<Leader>mb", "<cmd>StrudelSetBuffer<CR>", vim.tbl_extend("force", opts, { desc = "Strudel: Set Buffer" }))

-- File type association
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.strudel", "*.str" },
  callback = function()
    vim.bo.filetype = "javascript"
    vim.notify("Strudel file detected. <Leader>ms to launch.", vim.log.levels.INFO)
  end,
})
