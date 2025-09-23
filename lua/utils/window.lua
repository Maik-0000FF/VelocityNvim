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

--- Resize window
---@param direction string Direction: 'h', 'j', 'k', 'l' or 'left', 'down', 'up', 'right'
---@param amount integer|nil Amount to resize (default: 2)
---@return boolean success
function M.resize(direction, amount)
  amount = amount or 2

  local resize_maps = {
    h = string.format("vertical resize -%d", amount),
    left = string.format("vertical resize -%d", amount),
    l = string.format("vertical resize +%d", amount),
    right = string.format("vertical resize +%d", amount),
    j = string.format("resize +%d", amount),
    down = string.format("resize +%d", amount),
    k = string.format("resize -%d", amount),
    up = string.format("resize -%d", amount),
  }

  local cmd = resize_maps[direction:lower()]
  if not cmd then
    vim.notify("Invalid resize direction: " .. direction, vim.log.levels.ERROR)
    return false
  end

  vim.api.nvim_command(cmd)
  return true
end

--- Split window
---@param direction string Direction: 'horizontal', 'vertical', 'h', 'v'
---@param size integer|nil Size of new split
---@return integer|nil New window ID
function M.split(direction, size)
  local directions = {
    horizontal = "split",
    h = "split",
    vertical = "vsplit",
    v = "vsplit"
  }

  local cmd = directions[direction:lower()]
  if not cmd then
    vim.notify("Invalid split direction: " .. direction, vim.log.levels.ERROR)
    return nil
  end

  local size_cmd = size and tostring(size) .. cmd or cmd
  vim.api.nvim_command(size_cmd)
  return vim.api.nvim_get_current_win()
end

--- Close window
---@param winid integer|nil Window ID (current window if nil)
---@param force boolean|nil Force close
---@return boolean success
function M.close(winid, force)
  winid = winid or vim.api.nvim_get_current_win()

  -- Don't close if it's the last window (use native API directly)
  local normal_windows = vim.tbl_filter(function(w)
    return not M.is_floating(w)
  end, vim.api.nvim_list_wins())

  if #normal_windows <= 1 then
    vim.notify("Cannot close last window", vim.log.levels.WARN)
    return false
  end

  local ok = pcall(vim.api.nvim_win_close, winid, force or false)
  return ok
end

--- Center window on screen (for floating windows)
---@param width integer Window width
---@param height integer Window height
---@return table Window configuration
function M.centered_config(width, height)
  local screen_width = vim.o.columns
  local screen_height = vim.o.lines - vim.o.cmdheight - 1 -- Subtract for command line

  local col = math.floor((screen_width - width) / 2)
  local row = math.floor((screen_height - height) / 2)

  return {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  }
end

--- Create floating window
---@param bufnr integer Buffer to display
---@param config table Window configuration
---@return integer Window ID
function M.create_floating(bufnr, config)
  local default_config = {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    style = "minimal",
    border = "rounded",
  }

  config = vim.tbl_deep_extend("force", default_config, config or {})

  -- Center if position not specified
  if not config.col or not config.row then
    local centered = M.centered_config(config.width, config.height)
    config.col = centered.col
    config.row = centered.row
  end

  return vim.api.nvim_open_win(bufnr, true, config)
end

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
    -- Silent success - window operations sind erwartetes Verhalten
  else
    -- Maximize
    vim.api.nvim_command("wincmd |")
    vim.api.nvim_command("wincmd _")
    vim.w[winid].zoomed = true
    -- Silent success - window operations sind erwartetes Verhalten
  end

  return true
end

--- Switch to window by number
---@param num integer Window number
---@return boolean success
function M.switch_to(num)
  -- Get non-floating windows directly
  local windows = vim.tbl_filter(function(w)
    return not M.is_floating(w)
  end, vim.api.nvim_list_wins())

  if num < 1 or num > #windows then
    vim.notify("Window " .. num .. " does not exist", vim.log.levels.ERROR)
    return false
  end

  vim.api.nvim_set_current_win(windows[num])
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

--- Find windows containing specific buffer
---@param bufnr integer Buffer number
---@param include_floating boolean|nil Include floating windows
---@return table List of window IDs
function M.find_by_buffer(bufnr, include_floating)
  -- Get windows with inline filtering (native API)
  local all_windows = vim.api.nvim_list_wins()
  local windows = include_floating and all_windows or vim.tbl_filter(function(w)
    return not M.is_floating(w)
  end, all_windows)

  local result = {}
  for _, winid in ipairs(windows) do
    if vim.api.nvim_win_get_buf(winid) == bufnr then  -- Native check
      table.insert(result, winid)
    end
  end

  return result
end

-- REMOVED: balance() - Use vim.cmd('wincmd =') directly

--- Get window statistics
---@return table Window statistics
function M.get_stats()
  local all_windows = vim.api.nvim_list_wins()
  -- Calculate directly with native API
  local normal_windows = vim.tbl_filter(function(w)
    return not M.is_floating(w)
  end, all_windows)

  local floating_count = #all_windows - #normal_windows
  local zoomed_count = 0

  for _, winid in ipairs(normal_windows) do
    if vim.w[winid].zoomed then
      zoomed_count = zoomed_count + 1
    end
  end

  return {
    total = #all_windows,
    normal = #normal_windows,
    floating = floating_count,
    zoomed = zoomed_count,
    current = vim.api.nvim_get_current_win(),
  }
end

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

  print("🪟 Window Information:")
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