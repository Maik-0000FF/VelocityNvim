-- ~/.config/VelocityNvim/lua/core/commands/editor.lua
-- Buffer, window, terminal, file, and git commands

local cmd = vim.api.nvim_create_user_command
local icons = require("core.icons")

-- Buffer Management Commands
cmd("BufferCloseOthers", function()
  local utils = require("utils")
  local closed_count = utils.buffer().close_others()
  utils.notify(
    icons.status.folder .. " " .. closed_count .. " buffers closed",
    vim.log.levels.INFO
  )
end, {
  desc = "Close all buffers except current",
})

cmd("BufferCloseAll", function()
  local utils = require("utils")
  local success = utils.buffer().close_all()
  if success then
    utils.notify(icons.status.folder .. " All buffers closed", vim.log.levels.INFO)
  end
end, {
  desc = "Close all buffers (force)",
})

cmd("BufferInfo", function()
  local utils = require("utils")
  utils.buffer().print_info()
end, {
  desc = "Show current buffer information",
})

cmd("BufferStats", function()
  local utils = require("utils")
  local stats = utils.buffer().get_stats()
  print(icons.status.stats .. " Buffer Statistics:")
  print("  Total: " .. stats.total)
  print("  Listed: " .. stats.listed)
  print("  Modified: " .. stats.modified)
  print("  Files: " .. stats.files)
  print("  Scratch: " .. stats.scratch)
end, {
  desc = "Show buffer statistics",
})

-- Icon Validation Command
cmd("IconValidate", function()
  local validator = require("utils.validate-icons")
  validator.validate()
end, {
  desc = "Validate all icon references in code",
})

-- Development Commands
cmd("EditConfig", function()
  vim.api.nvim_command("edit " .. vim.fn.stdpath("config") .. "/init.lua")
end, {
  desc = "Open init.lua",
})

cmd("ReloadConfig", function()
  -- Clear module cache
  for name, _ in pairs(package.loaded) do
    if name:match("^core") or name:match("^plugins") then
      package.loaded[name] = nil
    end
  end

  -- Reload configuration
  vim.api.nvim_command("source " .. vim.fn.stdpath("config") .. "/init.lua")
  vim.notify(icons.status.sync .. " Configuration reloaded", vim.log.levels.INFO)
end, {
  desc = "Reload Neovim configuration",
})

-- Git Integration Commands
cmd("GitInfo", function()
  local utils = require("utils")
  utils.git().print_info()
end, {
  desc = "Show git repository information",
})

cmd("GitStatus", function()
  local utils = require("utils")
  if utils.git().is_available() then
    vim.api.nvim_command("FzfLua git_status")
  else
    utils.notify("Git is not available", vim.log.levels.ERROR)
  end
end, {
  desc = "Show git status with fzf",
})

cmd("GitLog", function()
  local utils = require("utils")
  if utils.git().is_available() then
    vim.api.nvim_command("FzfLua git_commits")
  else
    utils.notify("Git is not available", vim.log.levels.ERROR)
  end
end, {
  desc = "Show git log with fzf",
})

-- Window Management Commands
cmd("WindowInfo", function()
  local utils = require("utils")
  utils.window().print_info()
end, {
  desc = "Show current window information",
})

cmd("WindowBalance", function()
  vim.cmd('wincmd =')
end, {
  desc = "Balance all windows",
})

cmd("WindowZoom", function()
  local utils = require("utils")
  utils.window().toggle_zoom()
end, {
  desc = "Toggle window zoom (maximize/restore)",
})

-- File Utilities Commands
cmd("FileInfo", function()
  local utils = require("utils")
  local current_file = vim.fn.expand("%:p")
  if current_file ~= "" then
    utils.file().print_info(current_file)
  else
    utils.notify("No file loaded in current buffer", vim.log.levels.WARN)
  end
end, {
  desc = "Show current file information",
})

-- Terminal Management Commands
cmd("TermH", function()
  local utils = require("utils")
  utils.terminal().toggle_horizontal_terminal()
end, {
  desc = "Toggle horizontal terminal",
})

cmd("TermV", function()
  local utils = require("utils")
  utils.terminal().toggle_vertical_terminal()
end, {
  desc = "Toggle vertical terminal",
})

cmd("TermF", function()
  local utils = require("utils")
  utils.terminal().toggle_floating_terminal()
end, {
  desc = "Toggle floating terminal",
})

cmd("TermClose", function()
  local utils = require("utils")
  utils.terminal().close_all_terminals()
end, {
  desc = "Close all terminals",
})

cmd("TermInfo", function()
  local utils = require("utils")
  utils.terminal().print_terminal_info()
end, {
  desc = "Show terminal information and keybindings",
})
