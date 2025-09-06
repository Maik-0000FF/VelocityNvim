-- ~/.config/VelocityNvim/lua/utils/init.lua
-- Utility Module Loader - Common helper functions

local M = {}

-- Compatibility layer for uv -> vim.uv transition
local uv = vim.uv or vim.loop

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

--- Check if a command is executable
---@param cmd string Command to check
---@return boolean
function M.is_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

--- Safe require with error handling
---@param module string Module name to require
---@return boolean success, any module_or_error
function M.safe_require(module)
  local ok, result = pcall(require, module)
  return ok, result
end

--- Get the root directory of the current project
---@return string|nil
function M.get_root_dir()
  local markers = { ".git", "package.json", "Cargo.toml", "pyproject.toml", "go.mod" }

  local current_dir = vim.fn.expand("%:p:h")

  -- Walk up the directory tree
  while current_dir ~= "/" do
    for _, marker in ipairs(markers) do
      local marker_path = current_dir .. "/" .. marker
      if vim.fn.filereadable(marker_path) == 1 or vim.fn.isdirectory(marker_path) == 1 then
        return current_dir
      end
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end

  return nil
end

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

--- Check if a plugin is loaded
---@param plugin_name string Name of the plugin
---@return boolean
function M.is_plugin_loaded(plugin_name)
  return package.loaded[plugin_name] ~= nil
end

--- Get current buffer info
---@return table
function M.get_buffer_info()
  local bufnr = vim.api.nvim_get_current_buf()
  return {
    bufnr = bufnr,
    name = vim.api.nvim_buf_get_name(bufnr),
    filetype = vim.bo[bufnr].filetype,
    modified = vim.bo[bufnr].modified,
    readonly = vim.bo[bufnr].readonly,
    size = vim.api.nvim_buf_line_count(bufnr),
  }
end

--- Measure execution time of a function
---@param fn function Function to measure
---@param description string|nil Optional description
---@return any result, number time_ms
function M.measure_time(fn, description)
  local start_time = uv.hrtime()
  local result = fn()
  local end_time = uv.hrtime()
  local time_ms = (end_time - start_time) / 1000000

  if description then
    M.notify(string.format("%s: %.2fms", description, time_ms), vim.log.levels.DEBUG)
  end

  return result, time_ms
end

--- Deep merge two tables
---@param t1 table
---@param t2 table
---@return table
function M.deep_merge(t1, t2)
  local result = {}

  -- Copy t1
  for k, v in pairs(t1) do
    if type(v) == "table" then
      result[k] = vim.deepcopy(v)
    else
      result[k] = v
    end
  end

  -- Merge t2
  for k, v in pairs(t2) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = M.deep_merge(result[k], v)
    else
      result[k] = v
    end
  end

  return result
end

--- Check if current OS is macOS
---@return boolean
function M.is_macos()
  return uv.os_uname().sysname == "Darwin"
end

--- Check if current OS is Linux
---@return boolean
function M.is_linux()
  return uv.os_uname().sysname == "Linux"
end

--- Get system separator (always / for Unix systems)
---@return string
function M.path_separator()
  return "/"
end

--- Join path components
---@param ... string Path components
---@return string
function M.path_join(...)
  local components = { ... }
  return table.concat(components, M.path_separator())
end

--- Debounce a function call
---@param fn function Function to debounce
---@param timeout number Timeout in milliseconds
---@return function Debounced function
function M.debounce(fn, timeout)
  local timer
  return function(...)
    local args = { ... }
    if timer then
      uv.timer_stop(timer)
      uv.timer_close(timer)
    end

    timer = uv.new_timer()
    uv.timer_start(timer, timeout, 0, function()
      uv.timer_stop(timer)
      uv.timer_close(timer)
      timer = nil
      vim.schedule(function()
        fn(unpack(args))
      end)
    end)
  end
end

--- Throttle a function call
---@param fn function Function to throttle
---@param timeout number Timeout in milliseconds
---@return function Throttled function
function M.throttle(fn, timeout)
  local last_call = 0
  return function(...)
    local now = uv.hrtime() / 1000000
    if now - last_call >= timeout then
      last_call = now
      fn(...)
    end
  end
end

return M