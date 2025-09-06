-- ~/.config/VelocityNvim/lua/utils/buffer.lua
-- Buffer management utilities

local M = {}

--- Get all valid buffers
---@param listed_only boolean|nil Only return listed buffers (default: true)
---@return table List of buffer numbers
function M.get_valid_buffers(listed_only)
  listed_only = listed_only ~= false

  local buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      if not listed_only or vim.bo[bufnr].buflisted then
        table.insert(buffers, bufnr)
      end
    end
  end
  return buffers
end

--- Check if buffer is modified
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return boolean
function M.is_modified(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.bo[bufnr].modified
end

--- Check if buffer is empty
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return boolean
function M.is_empty(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_line_count(bufnr) == 1
    and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ""
end

--- Check if buffer has a file name
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return boolean
function M.has_file(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name and name ~= ""
end

--- Get buffer file path
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return string|nil
function M.get_file_path(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name ~= "" and name or nil
end

--- Get buffer relative file path (relative to cwd)
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return string|nil
function M.get_relative_path(bufnr)
  local path = M.get_file_path(bufnr)
  if not path then return nil end

  local cwd = vim.fn.getcwd()
  if path:find(cwd, 1, true) == 1 then
    return path:sub(#cwd + 2) -- +2 to skip the separator
  end
  return path
end

--- Close buffer safely
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@param force boolean|nil Force close without saving
---@return boolean success
function M.close_buffer(bufnr, force)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  force = force or false

  -- Check if buffer is modified and not forcing
  if not force and M.is_modified(bufnr) then
    local name = M.get_file_path(bufnr) or "[No Name]"
    local choice = vim.fn.confirm(
      string.format("Buffer '%s' wurde geändert. Was möchten Sie tun?", vim.fn.fnamemodify(name, ":t")),
      "&Speichern\n&Verwerfen\n&Abbrechen",
      1
    )

    if choice == 1 then
      -- Save and close
      local ok = pcall(function() vim.cmd("w") end)
      if not ok then
        vim.notify("Fehler beim Speichern", vim.log.levels.ERROR)
        return false
      end
    elseif choice == 2 then
      -- Force close without saving
      force = true
    else
      -- Cancel
      return false
    end
  end

  -- Count normal buffers
  local valid_buffers = M.get_valid_buffers(true)
  local normal_buffers = vim.tbl_filter(function(buf)
    return vim.bo[buf].buftype == ""
  end, valid_buffers)

  if #normal_buffers <= 1 then
    -- Last normal buffer - create new empty buffer first
    vim.cmd("enew")
    local ok = pcall(vim.api.nvim_buf_delete, bufnr, { force = force })
    if ok then
      -- Silent success - Buffer-Ersetzung ist erwartetes Verhalten
    end
    return ok
  else
    -- Switch to previous buffer first
    vim.cmd("bprevious")
    local ok = pcall(vim.api.nvim_buf_delete, bufnr, { force = force })
    if ok then
      -- Silent success - Buffer schließen ist erwartetes Verhalten
    end
    return ok
  end
end

--- Close all buffers except current
---@param force boolean|nil Force close without saving
---@return number Number of closed buffers
function M.close_others(force)
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = M.get_valid_buffers(true)
  local closed_count = 0

  for _, bufnr in ipairs(buffers) do
    if bufnr ~= current_buf and vim.bo[bufnr].buftype == "" then
      local ok = pcall(vim.api.nvim_buf_delete, bufnr, { force = force or false })
      if ok then
        closed_count = closed_count + 1
      end
    end
  end

  return closed_count
end

--- Close all buffers
---@param force boolean|nil Force close without saving
---@return boolean success
function M.close_all(force)
  if not force then
    local choice = vim.fn.confirm(
      "Alle Buffer schließen? Ungespeicherte Änderungen gehen verloren!",
      "&Ja\n&Nein",
      2
    )
    if choice ~= 1 then
      return false
    end
  end

  vim.cmd("%bdelete" .. (force and "!" or ""))
  vim.cmd("enew")
  return true
end

--- Switch to next buffer
---@return boolean success
function M.next_buffer()
  local buffers = M.get_valid_buffers(true)
  if #buffers <= 1 then return false end

  vim.cmd("bnext")
  return true
end

--- Switch to previous buffer
---@return boolean success
function M.prev_buffer()
  local buffers = M.get_valid_buffers(true)
  if #buffers <= 1 then return false end

  vim.cmd("bprev")
  return true
end

--- Find buffer by file path
---@param path string File path to search for
---@return integer|nil Buffer number if found
function M.find_by_path(path)
  path = vim.fn.fnamemodify(path, ":p") -- Get absolute path

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local buf_path = vim.api.nvim_buf_get_name(bufnr)
      if buf_path ~= "" and vim.fn.fnamemodify(buf_path, ":p") == path then
        return bufnr
      end
    end
  end
  return nil
end

--- Switch to buffer by file path or create new one
---@param path string File path
---@return integer Buffer number
function M.switch_to_or_create(path)
  local bufnr = M.find_by_path(path)

  if bufnr then
    -- Switch to existing buffer
    vim.api.nvim_set_current_buf(bufnr)
    return bufnr
  else
    -- Create and switch to new buffer
    return vim.fn.bufnr(path, true)
  end
end

--- Get buffer statistics
---@return table Statistics about buffers
function M.get_stats()
  local all_buffers = vim.api.nvim_list_bufs()
  local valid_buffers = M.get_valid_buffers(false)
  local listed_buffers = M.get_valid_buffers(true)

  local modified_count = 0
  local file_buffers = 0
  local scratch_buffers = 0

  for _, bufnr in ipairs(valid_buffers) do
    if M.is_modified(bufnr) then
      modified_count = modified_count + 1
    end

    if vim.bo[bufnr].buftype == "" then
      if M.has_file(bufnr) then
        file_buffers = file_buffers + 1
      else
        scratch_buffers = scratch_buffers + 1
      end
    end
  end

  return {
    total = #all_buffers,
    valid = #valid_buffers,
    listed = #listed_buffers,
    modified = modified_count,
    files = file_buffers,
    scratch = scratch_buffers,
  }
end

--- Pretty print buffer information
---@param bufnr integer|nil Buffer number (current buffer if nil)
function M.print_info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local info = {
    bufnr = bufnr,
    name = vim.api.nvim_buf_get_name(bufnr),
    filetype = vim.bo[bufnr].filetype,
    modified = vim.bo[bufnr].modified,
    readonly = vim.bo[bufnr].readonly,
    lines = vim.api.nvim_buf_line_count(bufnr),
    size_bytes = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr)),
    buftype = vim.bo[bufnr].buftype,
    buflisted = vim.bo[bufnr].buflisted,
  }

  local icons = require("core.icons")
  print(icons.status.list .. " Buffer Information:")
  print("  Buffer Number: " .. info.bufnr)
  print("  File: " .. (info.name ~= "" and info.name or "[No Name]"))
  print("  Type: " .. (info.filetype ~= "" and info.filetype or "none"))
  print("  Buffer Type: " .. (info.buftype ~= "" and info.buftype or "normal"))
  print("  Lines: " .. info.lines)
  print("  Size: " .. math.floor(info.size_bytes / 1024) .. " KB")
  print("  Modified: " .. (info.modified and "Yes" or "No"))
  print("  Read-only: " .. (info.readonly and "Yes" or "No"))
  print("  Listed: " .. (info.buflisted and "Yes" or "No"))
end

return M