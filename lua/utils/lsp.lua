-- ~/.config/VelocityNvim/lua/utils/lsp.lua
-- LSP utilities and helpers

local M = {}

--- Get active LSP clients for buffer
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return table List of LSP clients
function M.get_clients(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.lsp.get_clients({ bufnr = bufnr })
end

--- Check if LSP is attached to buffer
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return boolean
function M.is_attached(bufnr)
  return #M.get_clients(bufnr) > 0
end

--- Get LSP client by name
---@param name string Client name
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return table|nil LSP client
function M.get_client_by_name(name, bufnr)
  local clients = M.get_clients(bufnr)

  for _, client in ipairs(clients) do
    if client.name == name then
      return client
    end
  end
  return nil
end

--- Check if client supports capability
---@param client table LSP client
---@param capability string Capability name
---@return boolean
function M.supports_capability(client, capability)
  return client.server_capabilities[capability] ~= nil
end

--- Check if any client supports capability
---@param capability string Capability name
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return boolean, table|nil Has capability, client
function M.has_capability(capability, bufnr)
  local clients = M.get_clients(bufnr)

  for _, client in ipairs(clients) do
    if M.supports_capability(client, capability) then
      return true, client
    end
  end
  return false, nil
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

  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      counts.error = counts.error + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      counts.warn = counts.warn + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      counts.hint = counts.hint + 1
    end
  end

  return counts
end

--- Get workspace diagnostics summary
---@return table Workspace diagnostics summary
function M.get_workspace_diagnostics()
  local all_diagnostics = vim.diagnostic.get()
  local by_buffer = {}
  local total_counts = { error = 0, warn = 0, info = 0, hint = 0, total = 0 }

  for _, diagnostic in ipairs(all_diagnostics) do
    local bufnr = diagnostic.bufnr
    if not bufnr then
      goto continue
    end

    if not by_buffer[bufnr] then
      by_buffer[bufnr] = { error = 0, warn = 0, info = 0, hint = 0, total = 0 }
    end

    by_buffer[bufnr].total = by_buffer[bufnr].total + 1
    total_counts.total = total_counts.total + 1

    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      by_buffer[bufnr].error = by_buffer[bufnr].error + 1
      total_counts.error = total_counts.error + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      by_buffer[bufnr].warn = by_buffer[bufnr].warn + 1
      total_counts.warn = total_counts.warn + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      by_buffer[bufnr].info = by_buffer[bufnr].info + 1
      total_counts.info = total_counts.info + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      by_buffer[bufnr].hint = by_buffer[bufnr].hint + 1
      total_counts.hint = total_counts.hint + 1
    end
    ::continue::
  end

  return {
    by_buffer = by_buffer,
    total = total_counts,
    buffer_count = vim.tbl_count(by_buffer)
  }
end

--- Jump to next diagnostic
---@param severity integer|nil Severity filter
---@param wrap boolean|nil Wrap around
---@return boolean success
function M.goto_next_diagnostic(severity, wrap)
  local opts = { float = true }
  if severity then opts.severity = severity end
  if wrap ~= nil then opts.wrap = wrap end

  vim.diagnostic.jump({ count = 1, float = opts.float, severity = opts.severity, wrap = opts.wrap })
  return true
end

--- Jump to previous diagnostic
---@param severity integer|nil Severity filter
---@param wrap boolean|nil Wrap around
---@return boolean success
function M.goto_prev_diagnostic(severity, wrap)
  local opts = { float = true }
  if severity then opts.severity = severity end
  if wrap ~= nil then opts.wrap = wrap end

  vim.diagnostic.jump({ count = -1, float = opts.float, severity = opts.severity, wrap = opts.wrap })
  return true
end

--- Format buffer using LSP
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@param timeout integer|nil Timeout in milliseconds
---@return boolean success
function M.format_buffer(bufnr, timeout)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  timeout = timeout or 2000

  local has_format = M.has_capability("documentFormattingProvider", bufnr)
  if not has_format then
    return false
  end

  vim.lsp.buf.format({
    bufnr = bufnr,
    timeout_ms = timeout,
    async = false
  })
  return true
end

--- Get symbol information at cursor
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return table|nil Symbol information
function M.get_symbol_at_cursor(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = M.get_clients(bufnr)

  if #clients == 0 then return nil end

  local params = vim.lsp.util.make_position_params(0, nil)
  local results = {}

  for _, client in ipairs(clients) do
    if M.supports_capability(client, "hoverProvider") then
      local result = client.request_sync("textDocument/hover", params, 1000, bufnr)
      if result and result.result then
        table.insert(results, {
          client = client.name,
          content = result.result
        })
      end
    end
  end

  return #results > 0 and results or nil
end

--- Get document symbols
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return table|nil Document symbols
function M.get_document_symbols(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local has_symbols = M.has_capability("documentSymbolProvider", bufnr)

  if not has_symbols then return nil end

  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  local clients = M.get_clients(bufnr)

  for _, client in ipairs(clients) do
    if M.supports_capability(client, "documentSymbolProvider") then
      local result = client.request_sync("textDocument/documentSymbol", params, 2000, bufnr)
      if result and result.result then
        return result.result
      end
    end
  end

  return nil
end

--- Restart LSP clients
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return boolean success
function M.restart_clients(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = M.get_clients(bufnr)

  if #clients == 0 then
    return false
  end

  for _, client in ipairs(clients) do
    client.stop()
  end

  -- Wait a bit then restart
  vim.defer_fn(function()
    vim.cmd("edit") -- This will trigger LSP attach again
  end, 1000)

  return true
end

--- Get LSP server status
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@return table Server status information
function M.get_server_status(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = M.get_clients(bufnr)
  local status = {}

  for _, client in ipairs(clients) do
    local server_info = {
      name = client.name,
      id = client.id,
      is_stopped = client.is_stopped(),
      root_dir = client.config.root_dir,
      capabilities = {},
      workspace_folders = client.workspace_folders or {}
    }

    -- Check key capabilities
    local caps = {
      "hoverProvider",
      "definitionProvider",
      "referencesProvider",
      "documentFormattingProvider",
      "documentSymbolProvider",
      "codeActionProvider",
      "renameProvider"
    }

    for _, cap in ipairs(caps) do
      server_info.capabilities[cap] = M.supports_capability(client, cap)
    end

    table.insert(status, server_info)
  end

  return status
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

--- Enable inlay hints for buffer
---@param bufnr integer|nil Buffer number (current buffer if nil)
---@param enable boolean|nil Enable or disable
---@return boolean success
function M.toggle_inlay_hints(bufnr, enable)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.lsp.inlay_hint then
    if enable ~= nil then
      vim.lsp.inlay_hint.enable(enable, { bufnr = bufnr })
    else
      local current = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
      vim.lsp.inlay_hint.enable(not current, { bufnr = bufnr })
    end
    return true
  end

  return false
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

--- Show diagnostics in FZF with copy all functionality
---@param workspace boolean|nil Show workspace diagnostics (default: current buffer only)
function M.show_diagnostics_fzf(workspace)
  workspace = workspace or false

  local diagnostics = workspace and vim.diagnostic.get() or M.get_diagnostics()

  if #diagnostics == 0 then
    vim.notify("Keine Diagnosen gefunden", vim.log.levels.INFO)
    return
  end

  -- Format diagnostics for FZF
  local icons = require("core.icons")
  local items = {}
  local severity_icons = {
    [vim.diagnostic.severity.ERROR] = icons.status.error,
    [vim.diagnostic.severity.WARN] = icons.status.warning,
    [vim.diagnostic.severity.INFO] = icons.status.info,
    [vim.diagnostic.severity.HINT] = icons.status.hint
  }

  for _, diagnostic in ipairs(diagnostics) do
    local filename = workspace and vim.api.nvim_buf_get_name(diagnostic.bufnr) or vim.fn.bufname(diagnostic.bufnr)
    if filename == "" then filename = "current buffer" end

    local line = diagnostic.lnum + 1
    local col = diagnostic.col + 1
    local icon = severity_icons[diagnostic.severity] or "?"

    -- Clean message (remove newlines for display)
    local clean_message = diagnostic.message:gsub('\n', ' | ')

    local formatted_line = string.format("%s %s:%d:%d - %s",
      icon, filename, line, col, clean_message)

    table.insert(items, {
      display = formatted_line,
      diagnostic = diagnostic,
      filename = filename,
      line = line,
      col = col
    })
  end

  -- Setup FZF with custom actions
  local fzf = require("fzf-lua")

  local function copy_all_to_clipboard()
    local all_text = {}
    local title = workspace and "=== WORKSPACE DIAGNOSTICS ===" or "=== BUFFER DIAGNOSTICS ==="
    table.insert(all_text, title)
    table.insert(all_text, "Generated: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(all_text, "")

    for _, item in ipairs(items) do
      local d = item.diagnostic
      table.insert(all_text, string.format("%s:%d:%d", item.filename, item.line, item.col))

      -- Split multi-line messages properly
      local message_lines = vim.split(d.message, '\n', { plain = true })
      for _, msg_line in ipairs(message_lines) do
        table.insert(all_text, "  " .. msg_line)
      end

      if d.source then
        table.insert(all_text, "  Source: " .. d.source)
      end
      if d.code then
        table.insert(all_text, "  Code: " .. d.code)
      end
      table.insert(all_text, "")
    end

    local clipboard_text = table.concat(all_text, '\n')
    vim.fn.setreg('+', clipboard_text)
    vim.fn.setreg('"', clipboard_text)
    vim.notify(icons.status.clipboard .. " Alle Diagnosen in Zwischenablage kopiert (" .. #items .. " Einträge)", vim.log.levels.INFO)
  end

  local display_items = {}
  for _, item in ipairs(items) do
    table.insert(display_items, item.display)
  end

  fzf.fzf_exec(display_items, {
    prompt = (workspace and "Workspace" or "Buffer") .. " Diagnostics❯ ",
    preview = function(item)
      -- Find the corresponding diagnostic
      local selected_item = nil
      for _, it in ipairs(items) do
        if it.display == item[1] then
          selected_item = it
          break
        end
      end

      if not selected_item then return "" end

      local d = selected_item.diagnostic
      local preview_lines = {
        "File: " .. selected_item.filename,
        "Position: " .. selected_item.line .. ":" .. selected_item.col,
        "Severity: " .. vim.diagnostic.severity[d.severity],
        "",
        "Message:"
      }

      -- Add message lines with proper formatting
      local message_lines = vim.split(d.message, '\n', { plain = true })
      for _, msg_line in ipairs(message_lines) do
        table.insert(preview_lines, "  " .. msg_line)
      end

      if d.source then
        table.insert(preview_lines, "")
        table.insert(preview_lines, "Source: " .. d.source)
      end
      if d.code then
        table.insert(preview_lines, "Code: " .. tostring(d.code))
      end

      return table.concat(preview_lines, '\n')
    end,
    actions = {
      ["ctrl-y"] = function()
        copy_all_to_clipboard()
        -- Visual feedback like normal yank with highlight
        vim.schedule(function()
          vim.cmd("echo 'yanked " .. #items .. " diagnostics'")
          vim.defer_fn(function()
            vim.cmd("echo ''")
          end, 1500)
        end)
        return false  -- Keep FZF window open
      end,
    },
    fzf_opts = {
      ["--multi"] = true,
      ["--bind"] = "ctrl-y:execute-silent(echo copy-all)",
      ["--header"] = "Ctrl-Y=copy all, ESC=quit"
    },
    winopts = {
      height = 0.9,
      width = 0.95,
      preview = {
        layout = "vertical",
        vertical = "up:40%",
        hidden = "nohidden"
      }
    }
  })
end

return M