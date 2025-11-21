-- ~/.config/VelocityNvim/lua/utils/init.lua
-- Utility Module Loader - Common helper functions

local M = {}

-- REMOVED: uv API compatibility variables (only used by removed functions)

-- Lazy loading utility modules
M.buffer = function()
  return require("utils.buffer")
end

M.window = function()
  return require("utils.window")
end

M.git = function()
  return require("utils.git")
end

M.lsp = function()
  return require("utils.lsp")
end

M.file = function()
  return require("utils.file")
end

M.terminal = function()
  return require("utils.terminal")
end

-- Common utility functions that don't need separate modules

-- REMOVED: is_executable() - Unused
-- REMOVED: safe_require() - Unused (plugins/init.lua has local version)
-- REMOVED: get_root_dir() - Unused

--- Create a notification with consistent styling
---@param message string Message to show
---@param level integer|nil Log level (vim.log.levels)
---@param title string|nil Optional title
function M.notify(message, level, title)
  level = level or vim.log.levels.INFO
  title = title or "VelocityNvim"

  vim.notify(message, level, {
    title = title,
    timeout = 3000,
  })
end

-- REMOVED: is_plugin_loaded() - Unused
-- REMOVED: get_buffer_info() - Unused
-- REMOVED: measure_time() - Unused
-- REMOVED: deep_merge() - Unused (only recursive self-call)
-- REMOVED: is_macos() - Unused
-- REMOVED: is_linux() - Unused
-- REMOVED: path_separator() - Only used by path_join() which is unused
-- REMOVED: path_join() - Unused
-- REMOVED: debounce() - Unused (plugin configs use settings, not this function)
-- REMOVED: throttle() - Unused (plugin configs use settings, not this function)

return M