-- ~/.config/VelocityNvim/lua/utils/lsp.lua
-- LSP utilities and helpers

local M = {}

-- PERFORMANCE: Cache severity lookup table at module level
local severity_to_key = {
  [vim.diagnostic.severity.ERROR] = "error",
  [vim.diagnostic.severity.WARN] = "warn",
  [vim.diagnostic.severity.INFO] = "info",
  [vim.diagnostic.severity.HINT] = "hint",
}

--- Get active LSP clients for buffer
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return table List of LSP clients
function M.get_clients(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.lsp.get_clients({ bufnr = bufnr })
end


--- Check if client supports capability
---@param client table LSP client
---@param capability string Capability name
---@return boolean
function M.supports_capability(client, capability)
  return client.server_capabilities[capability] ~= nil
end


--- Get diagnostics for buffer
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@param severity integer|nil Severity filter
---@return table List of diagnostics
function M.get_diagnostics(bufnr, severity)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local opts = { bufnr = bufnr }

  if severity then
    opts.severity = severity
  end

  return vim.diagnostic.get(bufnr, opts)
end

--- Count diagnostics by severity
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return table Counts by severity
function M.count_diagnostics(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local diagnostics = M.get_diagnostics(bufnr)

  local counts = {
    error = 0,
    warn = 0,
    info = 0,
    hint = 0,
    total = #diagnostics
  }

  -- PERFORMANCE: Use lookup table instead of chained if-else
  for _, diagnostic in ipairs(diagnostics) do
    local key = severity_to_key[diagnostic.severity]
    if key then
      counts[key] = counts[key] + 1
    end
  end

  return counts
end

--- Get workspace diagnostics summary
---@return table Workspace diagnostics summary
function M.get_workspace_diagnostics()
  -- PERFORMANCE OPTIMIZED: Native vim.diagnostic.count() + lookup table
  local by_buffer = {}
  local total_counts = { error = 0, warn = 0, info = 0, hint = 0, total = 0 }

  local buffers = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local counts = vim.diagnostic.count(bufnr)
      if next(counts) then
        local buffer_counts = { error = 0, warn = 0, info = 0, hint = 0, total = 0 }

        -- PERFORMANCE: Use lookup table instead of chained if-else
        for severity, count in pairs(counts) do
          local key = severity_to_key[severity]
          if key then
            buffer_counts[key] = count
            total_counts[key] = total_counts[key] + count
          end
          buffer_counts.total = buffer_counts.total + count
        end

        by_buffer[bufnr] = buffer_counts
        total_counts.total = total_counts.total + buffer_counts.total
      end
    end
  end

  return {
    by_buffer = by_buffer,
    total = total_counts,
    buffer_count = vim.tbl_count(by_buffer)
  }
end

--- Check if LSP server is enabled/running
---@param server_name string Server name
---@return boolean
function M.is_server_configured(server_name)
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.name == server_name then
      return true
    end
  end
  return false
end

--- Get all configured LSP servers
---@return table List of configured servers
function M.get_configured_servers()
  local servers = {}

  -- Check common servers that might be configured
  local common_servers = {
    "luals", "pyright", "ts_ls", "htmlls", "cssls", "jsonls", "texlab"
  }

  for _, server in ipairs(common_servers) do
    if M.is_server_configured(server) then
      table.insert(servers, server)
    end
  end

  return servers
end

--- Pretty print LSP status
---@param bufnr integer|nil Buffer number (current buffer if nil)
function M.print_status(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = M.get_clients(bufnr)

  local icons = require("core.icons")
  print(icons.status.gear .. " LSP Status for Buffer " .. bufnr .. " (" .. vim.bo[bufnr].filetype .. "):")

  if #clients == 0 then
    print("  " .. icons.status.error .. " No LSP clients attached")
  else
    for _, client in ipairs(clients) do
      print("  " .. icons.status.success .. " " .. client.name .. " (ID: " .. client.id .. ")")
      if client.config.root_dir then
        print("    Root: " .. client.config.root_dir)
      end

      -- Show key capabilities
      local caps = {
        hover = "hoverProvider",
        definition = "definitionProvider",
        references = "referencesProvider",
        formatting = "documentFormattingProvider",
        symbols = "documentSymbolProvider"
      }

      print("    " .. icons.status.gear .. " Capabilities:")
      for name, cap in pairs(caps) do
        local has_cap = M.supports_capability(client, cap)
        print("      " .. name .. ": " .. (has_cap and icons.status.success or icons.status.error))
      end
    end
  end

  -- Show diagnostics
  local diagnostics = M.count_diagnostics(bufnr)
  print("  " .. icons.status.stats .. " Diagnostics:")
  print("    Errors: " .. diagnostics.error)
  print("    Warnings: " .. diagnostics.warn)
  print("    Info: " .. diagnostics.info)
  print("    Hints: " .. diagnostics.hint)
  print("    Total: " .. diagnostics.total)

  -- Show configured servers
  local configured = M.get_configured_servers()
  print("  " .. icons.status.config .. " Configured Servers: " .. table.concat(configured, ", "))
end

return M