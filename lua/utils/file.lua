-- ~/.config/VelocityNvim/lua/utils/file.lua
-- File operations and utilities

local M = {}

-- Compatibility layer
local uv = vim.uv or vim.loop

--- Check if file exists
---@param path string File path
---@return boolean
function M.exists(path)
  -- Use uv.fs_stat which is more reliable than vim.fs.exists (which doesn't exist in all versions)
  local stat = uv.fs_stat(path)
  return stat ~= nil
end

--- Check if directory exists
---@param path string Directory path
---@return boolean
function M.is_directory(path)
  local stat = uv.fs_stat(path)
  return stat ~= nil and stat.type == "directory"
end

--- Get file size in bytes
---@param path string File path
---@return integer|nil File size in bytes
function M.get_size(path)
  if not M.exists(path) then return nil end

  local stat = uv.fs_stat(path)
  return stat and stat.size or nil
end

--- Get file modification time
---@param path string File path
---@return integer|nil Modification time (timestamp)
function M.get_mtime(path)
  if not M.exists(path) then return nil end

  local stat = uv.fs_stat(path)
  return stat and stat.mtime.sec or nil
end

--- Get file extension
---@param path string File path
---@return string|nil File extension (without dot)
function M.get_extension(path)
  return path:match("%.([^%.]+)$")
end

--- Get file name without extension
---@param path string File path
---@return string File name without extension
function M.get_name_without_ext(path)
  local name = vim.fn.fnamemodify(path, ":t")
  return name:match("(.+)%..+$") or name
end

--- Get file basename
---@param path string File path
---@return string File basename
function M.get_basename(path)
  return vim.fs.basename(path)  -- Native vim.fs function
end

--- Get directory name
---@param path string File path
---@return string Directory path
function M.get_dirname(path)
  return vim.fs.dirname(path)  -- Native vim.fs function
end

--- Get absolute path
---@param path string File path
---@return string Absolute path
function M.get_absolute_path(path)
  return vim.fs.abspath(path)  -- Native vim.fs function
end

--- Get relative path (relative to cwd)
---@param path string File path
---@return string Relative path
function M.get_relative_path(path)
  return vim.fs.relpath(path)  -- Native vim.fs function (much simpler!)
end

--- Create directory (mkdir -p)
---@param path string Directory path
---@param mode integer|nil File mode (default: 755)
---@return boolean success
function M.mkdir(path, mode)
  mode = mode or 493 -- 0755 in decimal

  local ok, _ = pcall(vim.fn.mkdir, path, "p", mode)
  return ok
end

--- Copy file
---@param src string Source file path
---@param dest string Destination file path
---@return boolean success
function M.copy(src, dest)
  if not M.exists(src) then return false end

  -- Read source file
  local content = M.read_file(src)
  if not content then return false end

  -- Write to destination
  return M.write_file(dest, content)
end

--- Move/rename file
---@param src string Source file path
---@param dest string Destination file path
---@return boolean success
function M.move(src, dest)
  if not M.exists(src) then return false end

  local ok = pcall(vim.fn.rename, src, dest)
  return ok
end

--- Delete file
---@param path string File path
---@return boolean success
function M.delete(path)
  if not M.exists(path) then return true end -- Already deleted

  local ok = pcall(vim.fn.delete, path)
  return ok
end

--- Read file content
---@param path string File path
---@return string|nil File content
function M.read_file(path)
  if not M.exists(path) then return nil end

  local file = io.open(path, "r")
  if not file then return nil end

  local content = file:read("*a")
  file:close()
  return content
end

--- Read file lines
---@param path string File path
---@return table|nil File lines
function M.read_lines(path)
  if not M.exists(path) then return nil end

  local lines = {}
  local file = io.open(path, "r")
  if not file then return nil end

  for line in file:lines() do
    table.insert(lines, line)
  end

  file:close()
  return lines
end

--- Write content to file
---@param path string File path
---@param content string Content to write
---@param mode string|nil Write mode (default: "w")
---@return boolean success
function M.write_file(path, content, mode)
  mode = mode or "w"

  -- Create directory if it doesn't exist
  local dir = M.get_dirname(path)
  if not M.is_directory(dir) then
    if not M.mkdir(dir) then
      return false
    end
  end

  local file = io.open(path, mode)
  if not file then return false end

  file:write(content)
  file:close()
  return true
end

--- Write lines to file
---@param path string File path
---@param lines table Lines to write
---@param mode string|nil Write mode (default: "w")
---@return boolean success
function M.write_lines(path, lines, mode)
  local content = table.concat(lines, "\n")
  return M.write_file(path, content, mode)
end

--- Append content to file
---@param path string File path
---@param content string Content to append
---@return boolean success
function M.append_file(path, content)
  return M.write_file(path, content, "a")
end

--- Find files by pattern
---@param pattern string Glob pattern
---@param path string|nil Search path (default: current directory)
---@param recursive boolean|nil Search recursively
---@return table List of matching files
function M.find_files(pattern, path, recursive)
  path = path or vim.fn.getcwd()

  -- Use native vim.fs.find - much more efficient!
  local opts = { type = "file", path = path }
  if recursive == false then
    opts.limit = math.huge  -- No depth limit but stay in directory
  end

  return vim.fs.find(function(name)
    return name:match(pattern)
  end, opts)
end

--- Find directories by pattern
---@param pattern string Glob pattern
---@param path string|nil Search path (default: current directory)
---@param recursive boolean|nil Search recursively
---@return table List of matching directories
function M.find_directories(pattern, path, recursive)
  path = path or vim.fn.getcwd()

  -- Use native vim.fs.find - much more efficient!
  local opts = { type = "directory", path = path }
  if recursive == false then
    opts.limit = math.huge  -- No depth limit but stay in directory
  end

  return vim.fs.find(function(name)
    return name:match(pattern)
  end, opts)
end

--- Get files in directory
---@param path string Directory path
---@param include_hidden boolean|nil Include hidden files
---@return table List of files
function M.list_files(path, include_hidden)
  if not M.is_directory(path) then return {} end

  -- Use native vim.fs.dir for directory listing
  local files = {}
  for name, type in vim.fs.dir(path) do
    if type == "file" and (include_hidden or not name:match("^%.")) then
      table.insert(files, vim.fs.joinpath(path, name))
    end
  end
  return files
end

--- Get directories in directory
---@param path string Directory path
---@param include_hidden boolean|nil Include hidden directories
---@return table List of directories
function M.list_directories(path, include_hidden)
  if not M.is_directory(path) then return {} end

  -- Use native vim.fs.dir for directory listing
  local directories = {}
  for name, type in vim.fs.dir(path) do
    if type == "directory" and (include_hidden or not name:match("^%.")) then
      table.insert(directories, vim.fs.joinpath(path, name))
    end
  end
  return directories
end

--- Check if file is binary
---@param path string File path
---@return boolean
function M.is_binary(path)
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
  if not M.exists(path) then return nil end

  local stat = uv.fs_stat(path)
  if not stat then return nil end

  return {
    path = path,
    absolute_path = M.get_absolute_path(path),
    name = M.get_basename(path),
    name_without_ext = M.get_name_without_ext(path),
    extension = M.get_extension(path),
    directory = M.get_dirname(path),
    size = stat.size,
    mtime = stat.mtime.sec,
    is_directory = M.is_directory(path),
    is_binary = M.is_binary(path),
    readable = vim.fn.filereadable(path) == 1,
    writable = vim.fn.filewritable(path) == 1,
  }
end

--- Get disk usage for directory
---@param path string Directory path
---@return table|nil Usage information (size in bytes, file count)
function M.get_directory_size(path)
  if not M.is_directory(path) then return nil end

  local total_size = 0
  local file_count = 0
  local dir_count = 0

  local function scan_dir(dir)
    -- Use native vim.fs.dir for efficient directory traversal
    for name, type in vim.fs.dir(dir) do
      local item = vim.fs.joinpath(dir, name)  -- Native path joining
      if type == "directory" then
        dir_count = dir_count + 1
        scan_dir(item) -- Recursive scan
      elseif type == "file" then
        file_count = file_count + 1
        local size = M.get_size(item)
        if size then
          total_size = total_size + size
        end
      end
    end
  end

  scan_dir(path)

  return {
    total_size = total_size,
    file_count = file_count,
    directory_count = dir_count,
    size_mb = math.floor(total_size / 1024 / 1024 * 100) / 100,
    size_kb = math.floor(total_size / 1024 * 100) / 100,
  }
end

--- Watch file for changes
---@param path string File path
---@param callback function Callback function
---@return table|nil File watcher handle
function M.watch_file(path, callback)
  if not M.exists(path) then return nil end

  local handle = uv.new_fs_event()
  if not handle then return nil end

  local ok = handle:start(path, {}, function(err, filename, events)
    if err then
      vim.schedule(function()
        vim.notify("File watch error: " .. err, vim.log.levels.ERROR)
      end)
      return
    end

    vim.schedule(function()
      callback(filename, events)
    end)
  end)

  if not ok then
    handle:close()
    return nil
  end

  return handle
end

--- Stop file watcher
---@param handle table File watcher handle
function M.unwatch_file(handle)
  if handle and not handle:is_closing() then
    handle:stop()
    handle:close()
  end
end

--- Create temporary file
---@param content string|nil Initial content
---@param suffix string|nil File suffix/extension
---@return string|nil Temporary file path
function M.create_temp_file(content, suffix)
  local temp_dir = vim.fn.stdpath("cache") .. "/temp"
  if not M.is_directory(temp_dir) then
    if not M.mkdir(temp_dir) then
      return nil
    end
  end

  local timestamp = os.time()
  local random = math.random(1000, 9999)
  local filename = "velocitynvim_temp_" .. timestamp .. "_" .. random

  if suffix then
    filename = filename .. "." .. suffix:gsub("^%.", "")
  end

  local temp_path = vim.fs.joinpath(temp_dir, filename)  -- Native path joining

  if content then
    if M.write_file(temp_path, content) then
      return temp_path
    else
      return nil
    end
  else
    -- Create empty file
    local file = io.open(temp_path, "w")
    if file then
      file:close()
      return temp_path
    end
  end

  return nil
end

--- Pretty print file information
---@param path string File path
function M.print_info(path)
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