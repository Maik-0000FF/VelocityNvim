-- ~/.config/VelocityNvim/lua/core/autocmds.lua
-- Autocommands and event handlers

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Modern Neovim 0.11+ uses vim.uv (libuv bindings)
local fs_stat = vim.uv.fs_stat

-- VelocityNvim Autocommand Groups
local velocity_general = augroup("VelocityGeneral", { clear = true })
local velocity_lsp = augroup("VelocityLsp", { clear = true })
local velocity_ui = augroup("VelocityUI", { clear = true })
local velocity_format = augroup("VelocityFormat", { clear = true })

-- General autocommands
autocmd("TextYankPost", {
  group = velocity_general,
  desc = "Highlight yanked text",
  pattern = "*",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

-- Restore cursor position when opening file
autocmd("BufReadPost", {
  group = velocity_general,
  desc = "Restore cursor position",
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Remove trailing whitespace before saving
autocmd("BufWritePre", {
  group = velocity_format,
  desc = "Remove trailing whitespace",
  pattern = "*.lua",
  callback = function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    -- Use pcall to avoid errors if no trailing whitespace found
    pcall(vim.cmd, [[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end,
})

-- UI improvements
autocmd("VimEnter", {
  group = velocity_ui,
  desc = "Setup UI on vim enter",
  pattern = "*",
  callback = function()
    -- Hide startup messages
    vim.opt.shortmess:append("I")
    -- Only report errors, successful loading is expected
  end,
})

-- PERFORMANCE: Centralized timer management with race-condition protection
local timers = {
  colorscheme = nil,
  diagnostic = nil,
}

local function safe_stop_timer(key)
  if timers[key] then
    pcall(function()
      if timers[key].stop then
        timers[key]:stop()
      end
    end)
    timers[key] = nil
  end
end

local function safe_start_timer(key, delay, callback)
  safe_stop_timer(key)
  timers[key] = vim.defer_fn(function()
    timers[key] = nil
    pcall(callback)
  end, delay)
end

-- Debounced colorscheme updates for plugins
autocmd("ColorScheme", {
  group = velocity_ui,
  desc = "Update plugin colors on colorscheme change (debounced)",
  pattern = "*",
  callback = function()
    safe_start_timer("colorscheme", 100, function()
      vim.cmd.doautocmd("User", "ColorSchemeChanged")
    end)
  end,
})

-- Buffer-specific settings
autocmd("FileType", {
  group = velocity_general,
  desc = "Set filetype specific options",
  pattern = { "qf", "help", "man", "lspinfo", "spectre_panel" },
  callback = function()
    vim.keymap.set(
      "n",
      "q",
      "<cmd>close<cr>",
      { buffer = true, silent = true, desc = "Close buffer" }
    )
  end,
})

-- Diagnostics update for Neo-tree (performance-optimized)
autocmd("DiagnosticChanged", {
  group = velocity_lsp,
  desc = "Update neo-tree diagnostics display (debounced)",
  callback = function()
    safe_start_timer("diagnostic", 300, function()
      if package.loaded["neo-tree"] then
        local ok, events = pcall(require, "neo-tree.events")
        if ok and events then
          events.fire_event("diagnostics_changed")
        end
      end
    end)
  end,
})

-- Timer cleanup on VimLeavePre (proper resource cleanup)
autocmd("VimLeavePre", {
  group = velocity_lsp,
  desc = "Clean up timers on exit",
  pattern = "*",
  callback = function()
    for key, _ in pairs(timers) do
      safe_stop_timer(key)
    end
  end,
})

-- Performance: Optimize large files (aggressive)
autocmd("BufReadPre", {
  group = velocity_general,
  desc = "Optimize settings for large files (ultra-performance)",
  callback = function()
    local ok, stats = pcall(fs_stat, vim.fn.expand("<afile>"))
    if ok and stats and stats.size > 512 * 1024 then -- 512KB (more aggressive than 1MB)
      -- Ultra-performance settings for large files
      vim.opt_local.swapfile = false
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.undolevels = -1
      vim.opt_local.undoreload = 0
      vim.opt_local.list = false
      vim.opt_local.cursorline = false  -- Disable cursor line
      vim.opt_local.cursorcolumn = false -- Disable cursor column
      vim.opt_local.relativenumber = false -- Disable relative numbers
      vim.opt_local.spell = false       -- Disable spell check
      vim.opt_local.synmaxcol = 200     -- Syntax only for first 200 columns
      vim.b.large_buf = true
      -- Silent success - no notification for better UX
    end
  end,
})

-- Terminal-specific settings
autocmd("TermOpen", {
  group = velocity_general,
  desc = "Terminal specific settings",
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- Web server cleanup on exit
autocmd("VimLeavePre", {
  group = velocity_general,
  desc = "Stop web server on Neovim exit",
  pattern = "*",
  callback = function()
    local ok, webserver = pcall(require, "utils.webserver")
    if ok and webserver and webserver.is_running() then
      -- Silent cleanup - stop server without notifications on exit
      if webserver.server_job_id then
        vim.fn.jobstop(webserver.server_job_id)
        -- Non-blocking port cleanup
        if webserver.server_port then
          vim.system(
            { "sh", "-c", string.format("lsof -ti:%d | xargs kill -9 2>/dev/null", webserver.server_port) },
            { detach = true }
          )
        end
      end
    end
  end,
})

-- LaTeX/Typst: Auto-compile on save (enabled on first opening of .tex/.typ file)
autocmd("FileType", {
  group = velocity_general,
  desc = "Enable LaTeX/Typst live preview",
  pattern = { "tex", "typst" },
  callback = function()
    -- Load the module (automatically enables the Live-Preview)
    pcall(require, "utils.latex-performance")
  end,
})