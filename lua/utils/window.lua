-- ~/.config/VelocityNvim/lua/utils/window.lua
-- Window management utilities

local M = {}

-- REMOVED: get_current_info() - Use native vim.api.nvim_win_get_* directly

--- Check if window is floating
---@param winid integer|nil Window ID (current window if nil)
---@return boolean
function M.is_floating(winid)
  winid = winid or vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(winid)
  return config.relative ~= ""
end

-- REMOVED: get_all_windows() - Use vim.api.nvim_list_wins() with inline filter

-- REMOVED: get_count() - Use #vim.api.nvim_list_wins() directly

-- REMOVED: navigate() - Use vim.cmd('wincmd ' .. direction) directly


--- Toggle window zoom (maximize/restore)
---@param winid integer|nil Window ID (current window if nil)
---@return boolean success
function M.toggle_zoom(winid)
  winid = winid or vim.api.nvim_get_current_win()

  -- Check if already zoomed (stored in window variable)
  local is_zoomed = vim.w[winid].zoomed

  if is_zoomed then
    -- Restore
    vim.api.nvim_command("wincmd =")
    vim.w[winid].zoomed = nil
    -- Silent success - window operations are expected behavior
  else
    -- Maximize
    vim.api.nvim_command("wincmd |")
    vim.api.nvim_command("wincmd _")
    vim.w[winid].zoomed = true
    -- Silent success - window operations are expected behavior
  end

  return true
end


--- Get window number (1-indexed)
---@param winid integer|nil Window ID (current window if nil)
---@return integer|nil Window number
function M.get_number(winid)
  winid = winid or vim.api.nvim_get_current_win()
  -- Get non-floating windows directly
  local windows = vim.tbl_filter(function(w)
    return not M.is_floating(w)
  end, vim.api.nvim_list_wins())

  for i, win in ipairs(windows) do
    if win == winid then
      return i
    end
  end
  return nil
end

-- REMOVED: contains_buffer() - Use vim.api.nvim_win_get_buf(winid) == bufnr directly

-- REMOVED: balance() - Use vim.cmd('wincmd =') directly

--- Print window information
---@param winid integer|nil Window ID (current window if nil)
function M.print_info(winid)
  winid = winid or vim.api.nvim_get_current_win()

  -- Use native APIs directly instead of removed get_current_info()
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local width = vim.api.nvim_win_get_width(winid)
  local height = vim.api.nvim_win_get_height(winid)
  local pos = vim.api.nvim_win_get_position(winid)
  local cursor = vim.api.nvim_win_get_cursor(winid)
  local is_float = M.is_floating(winid)
  local win_num = M.get_number(winid)
  local icons = require("core.icons")

  print(icons.status.info .. " Window Information:")
  print("  Window ID: " .. winid)
  print("  Window Number: " .. (win_num or "N/A (floating)"))
  print("  Buffer: " .. bufnr)
  print("  Dimensions: " .. width .. "x" .. height)
  print("  Position: " .. pos[1] .. "," .. pos[2])
  print("  Cursor: " .. cursor[1] .. ":" .. cursor[2])
  print("  Floating: " .. (is_float and "Yes" or "No"))
  print("  Zoomed: " .. (vim.w[winid].zoomed and "Yes" or "No"))
end

return M