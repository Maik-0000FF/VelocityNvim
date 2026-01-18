-- ~/.config/VelocityNvim/lua/utils/file.lua
-- File operations and utilities

local M = {}

-- Modern Neovim 0.11+ uses vim.uv (libuv bindings)
local fs_stat_func = vim.uv.fs_stat
local new_fs_event_func = vim.uv.new_fs_event

--- Check if file exists
---@param path string File path
---@return boolean
function M.exists(path)
  -- Neovim 0.11+ optimized vim.validate()
  vim.validate({ path = { path, "string" } })

  -- Use fs_stat which is more reliable than vim.fs.exists (which doesn't exist in all versions)
  if not fs_stat_func then return false end
  local stat = fs_stat_func(path)
  return stat ~= nil
end

--- Check if directory exists
---@param path string Directory path
---@return boolean
function M.is_directory(path)
  vim.validate({ path = { path, "string" } })

  if not fs_stat_func then return false end
  local stat = fs_stat_func(path)
  return stat ~= nil and stat.type == "directory"
end

--- Get file size in bytes
---@param path string File path
---@return integer|nil File size in bytes
function M.get_size(path)
  vim.validate({ path = { path, "string" } })

  if not M.exists(path) then return nil end

  if not fs_stat_func then return nil end
  local stat = fs_stat_func(path)
  return stat and stat.size or nil
end

--- Get file modification time
---@param path string File path
---@return integer|nil Modification time (timestamp)
function M.get_mtime(path)
  vim.validate({ path = { path, "string" } })

  if not M.exists(path) then return nil end

  if not fs_stat_func then return nil end
  local stat = fs_stat_func(path)
  return stat and stat.mtime.sec or nil
end

--- Get file extension
---@param path string File path
---@return string|nil File extension (without dot)
function M.get_extension(path)
  vim.validate({ path = { path, "string" } })
  return path:match("%.([^%.]+)$")
end

--- Get file name without extension
---@param path string File path
---@return string File name without extension
function M.get_name_without_ext(path)
  vim.validate({ path = { path, "string" } })

  -- Use vim.fs.basename (0.11+ native API) instead of vim.fn.fnamemodify
  local name = vim.fs.basename(path)
  return name:match("(.+)%..+$") or name
end


--- Check if file is binary
---@param path string File path
---@return boolean
function M.is_binary(path)
  vim.validate({ path = { path, "string" } })

  if not M.exists(path) then return false end

  -- Read first 1KB to check for null bytes
  local file = io.open(path, "rb")
  if not file then return false end

  local chunk = file:read(1024)
  file:close()

  if not chunk then return false end

  -- Check for null bytes
  return chunk:find("\0") ~= nil
end

--- Get file info
---@param path string File path
---@return table|nil File information
function M.get_info(path)
  vim.validate({ path = { path, "string" } })

  if not M.exists(path) then return nil end

  if not fs_stat_func then return nil end
  local stat = fs_stat_func(path)
  if not stat then return nil end

  return {
    path = path,
    absolute_path = vim.fs.abspath(path),  -- Native vim.fs API (0.11+)
    name = vim.fs.basename(path),  -- Native vim.fs API (0.11+)
    name_without_ext = M.get_name_without_ext(path),
    extension = M.get_extension(path),
    directory = vim.fs.dirname(path),  -- Native vim.fs API (0.11+)
    size = stat.size,
    mtime = stat.mtime.sec,
    is_directory = M.is_directory(path),
    is_binary = M.is_binary(path),
    readable = vim.fn.filereadable(path) == 1,
    writable = vim.fn.filewritable(path) == 1,
  }
end


--- Pretty print file information
---@param path string File path
function M.print_info(path)
  vim.validate({ path = { path, "string" } })

  local info = M.get_info(path)
  if not info then
    local icons = require("core.icons")
    print(icons.status.error .. " File not found: " .. path)
    return
  end

  local icons = require("core.icons")
  print(icons.status.info .. " File Information:")
  print("  Path: " .. info.path)
  print("  Name: " .. info.name)
  print("  Extension: " .. (info.extension or "none"))
  print("  Directory: " .. info.directory)
  print("  Size: " .. info.size .. " bytes (" .. math.floor(info.size / 1024 * 100) / 100 .. " KB)")
  print("  Modified: " .. os.date("%Y-%m-%d %H:%M:%S", info.mtime))
  print("  Type: " .. (info.is_directory and "Directory" or "File"))
  print("  Binary: " .. (info.is_binary and "Yes" or "No"))
  print("  Readable: " .. (info.readable and "Yes" or "No"))
  print("  Writable: " .. (info.writable and "Yes" or "No"))
end

return M