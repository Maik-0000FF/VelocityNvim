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

-- REMOVED: is_modified() - Only used by close_buffer() which is unused
-- REMOVED: is_empty() - Unused
-- REMOVED: has_file() - Unused
-- REMOVED: get_file_path() - Only used by close_buffer() which is unused
-- REMOVED: close_buffer() - Unused (keymaps use native bdelete commands)

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
      "Close all buffers? Unsaved changes will be lost!",
      "&Yes\n&No",
      2
    )
    if choice ~= 1 then
      return false
    end
  end

  vim.api.nvim_command("%bdelete" .. (force and "!" or ""))
  vim.api.nvim_command("enew")
  return true
end

-- REMOVED: next_buffer() - Unused (keymaps use native bnext command)
-- REMOVED: prev_buffer() - Unused (keymaps use native bprev command)
-- REMOVED: find_by_path() - Only used by switch_to_or_create() which is unused
-- REMOVED: switch_to_or_create() - Unused

--- Get buffer statistics
---@return table Statistics about buffers
function M.get_stats()
  local all_buffers = vim.api.nvim_list_bufs()

  -- PERFORMANCE: Single-pass counting instead of multiple function calls
  local stats = {
    total = #all_buffers,
    valid = 0,
    listed = 0,
    modified = 0,
    files = 0,
    scratch = 0,
  }

  for _, bufnr in ipairs(all_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      stats.valid = stats.valid + 1

      if vim.bo[bufnr].buflisted then
        stats.listed = stats.listed + 1
      end

      if vim.bo[bufnr].modified then
        stats.modified = stats.modified + 1
      end

      if vim.bo[bufnr].buftype == "" then
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name ~= "" then
          stats.files = stats.files + 1
        else
          stats.scratch = stats.scratch + 1
        end
      end
    end
  end

  return stats
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

