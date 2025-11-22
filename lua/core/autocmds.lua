-- ~/.config/VelocityNvim/lua/core/autocmds.lua
-- Autocommands and event handlers

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Cross-version compatibility layer für fs_stat access (cached at module level)
local fs_stat_func = rawget(vim.uv, 'fs_stat') or rawget(vim.loop, 'fs_stat')

-- VelocityNvim Autocommand Gruppen
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
    vim.cmd.substitute("\\s\\+$", "", "ge")
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

-- Colorscheme updates for plugins
autocmd("ColorScheme", {
  group = velocity_ui,
  desc = "Update plugin colors on colorscheme change",
  pattern = "*",
  callback = function()
    -- Trigger color updates for various plugins
    vim.defer_fn(function()
      vim.cmd.doautocmd("User", "ColorSchemeChanged")
    end, 100)
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

-- LSP-specific autocommands
autocmd("LspAttach", {
  group = velocity_lsp,
  desc = "LSP keymaps and options on attach",
  callback = function(event)
    local bufnr = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if not client then
      return
    end

    -- Buffer-local settings
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Enable inlay hints (if available)
    if client and client.supports_method then
      local supports_inlay = pcall(client.supports_method, client, "textDocument/inlayHint")
      if supports_inlay then
        vim.defer_fn(function()
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end, 500)
      end
    end
  end,
})

-- Diagnostics update for Neo-tree (performance-optimized)
local diagnostic_timer = nil
autocmd("DiagnosticChanged", {
  group = velocity_lsp,
  desc = "Update neo-tree diagnostics display (debounced)",
  callback = function()
    -- Debounced updates: Prevents excessive updates during rapid changes
    if diagnostic_timer then
      diagnostic_timer:stop()
    end
    diagnostic_timer = vim.defer_fn(function()
      if package.loaded["neo-tree"] then
        local ok, events = pcall(require, "neo-tree.events")
        if ok and events then
          events.fire_event("diagnostics_changed")
        end
      end
      diagnostic_timer = nil
    end, 500) -- Longer delay for less frequent updates
  end,
})

-- Performance: Optimize large files (aggressive)
autocmd("BufReadPre", {
  group = velocity_general,
  desc = "Optimize settings for large files (ultra-performance)",
  callback = function()
    local ok, stats = fs_stat_func and pcall(fs_stat_func, vim.fn.expand("<afile>")) or false, nil
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