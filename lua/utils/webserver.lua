-- ~/.config/VelocityNvim/lua/utils/webserver.lua
-- Web Development Server with Auto-Reload (live-server)

local M = {}

-- Track running server process
M.server_job_id = nil
M.server_port = nil

--- Start live-server with auto-reload
---@param port number|nil Port number (default: 8080)
---@return boolean success
function M.start_server(port)
  port = port or 8080

  -- Check if live-server is available
  if vim.fn.executable("live-server") ~= 1 then
    vim.notify(
      "live-server not found. Install: npm install -g live-server",
      vim.log.levels.ERROR
    )
    return false
  end

  -- Get current file info
  local file_path = vim.fn.expand("%:p")
  local file_dir = vim.fn.expand("%:p:h")
  local file_name = vim.fn.expand("%:t")

  -- Check if current buffer is a valid web file
  if file_path == "" or not file_name:match("%.html?$") then
    vim.notify("Please open an HTML file first", vim.log.levels.WARN)
    return false
  end

  -- Stop existing server if running
  if M.server_job_id then
    M.stop_server()
    -- Wait a bit for port to be released
    vim.wait(500)
  end

  -- Kill any process using the port (in case of orphaned server)
  vim.fn.system(string.format("lsof -ti:%d | xargs kill -9 2>/dev/null", port))

  -- Start live-server with auto-reload in background
  -- Options:
  -- --port: Server port
  -- --host: Listen on localhost
  -- --watch: Watch directory for changes (auto-reload)
  -- --no-css-inject: Reload page instead of injecting CSS
  -- --no-browser: Don't auto-open (we handle it manually for better control)
  local cmd = string.format(
    "cd %s && live-server --port=%d --host=127.0.0.1 --watch=. --no-css-inject --no-browser",
    vim.fn.shellescape(file_dir),
    port
  )

  M.server_job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      -- Capture server output for debugging if needed
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line:match("Serving") then
            vim.notify(
              string.format("Web server running: http://localhost:%d (Auto-Reload active)", port),
              vim.log.levels.INFO
            )
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 and exit_code ~= 143 then -- 143 = SIGTERM (normal stop)
        vim.notify("Web server stopped with code: " .. exit_code, vim.log.levels.WARN)
      end
      M.server_job_id = nil
      M.server_port = nil
    end,
  })

  if M.server_job_id > 0 then
    M.server_port = port

    -- Open browser after server has started (with delay)
    vim.defer_fn(function()
      -- Build URL to specific file
      local url = string.format("http://localhost:%d/%s", port, file_name)

      -- Verify server is actually running before opening browser
      local check_cmd = string.format("curl -s -o /dev/null -w '%%{http_code}' %s", url)
      local response = vim.fn.system(check_cmd)

      if vim.v.shell_error == 0 and response:match("200") then
        vim.notify(
          string.format(
            "Web server started: %s\nAuto-Reload: Active (watching: %s)",
            url,
            file_dir
          ),
          vim.log.levels.INFO
        )
        -- Open browser with specific file URL
        M.open_browser_url(url)
      else
        vim.notify("Server started but not yet ready, opening browser...", vim.log.levels.INFO)
        -- Try opening anyway after a bit more delay
        vim.defer_fn(function()
          M.open_browser_url(url)
        end, 500)
      end
    end, 1500) -- Wait 1.5s for server to fully start

    return true
  else
    vim.notify("Failed to start web server", vim.log.levels.ERROR)
    return false
  end
end

--- Stop web server
function M.stop_server()
  if M.server_job_id then
    vim.fn.jobstop(M.server_job_id)
    local port = M.server_port
    M.server_job_id = nil
    M.server_port = nil

    -- Ensure port is released (kill any orphaned processes)
    if port then
      vim.fn.system(string.format("lsof -ti:%d | xargs kill -9 2>/dev/null", port))
    end

    vim.notify("Web server stopped", vim.log.levels.INFO)
  else
    vim.notify("No web server running", vim.log.levels.WARN)
  end
end

--- Get server status
---@return boolean running
function M.is_running()
  return M.server_job_id ~= nil
end

--- Get current server port
---@return number|nil port
function M.get_port()
  return M.server_port
end

--- Open browser with specific URL
---@param url string Full URL to open
function M.open_browser_url(url)
  -- Detect OS and use appropriate browser opener
  local is_macos = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1

  if is_macos then
    -- macOS: Use 'open' command (built-in)
    vim.fn.system(string.format("open '%s'", url))
  elseif vim.fn.executable("firefox") == 1 then
    -- Linux: Try Firefox first
    vim.fn.system(string.format("firefox '%s' &", url))
  elseif vim.fn.executable("xdg-open") == 1 then
    -- Linux: Fallback to xdg-open
    vim.fn.system(string.format("xdg-open '%s' &", url))
  else
    vim.notify("No browser found. URL: " .. url, vim.log.levels.WARN)
  end
end

--- Open browser at localhost
---@param port number|nil Port number (default: last used port or 8080)
function M.open_browser(port)
  port = port or M.server_port or 8080
  local url = string.format("http://localhost:%d", port)
  M.open_browser_url(url)
end

--- Print detailed server info
function M.print_info()
  local icons = require("core.icons")

  print(icons.status.list .. " Web Server Information:")
  print()

  -- Server status
  if M.is_running() then
    print(icons.status.success .. " Status: Running")
    print(icons.status.info .. " Port: " .. (M.server_port or "Unknown"))
    print(icons.status.info .. " URL: http://localhost:" .. (M.server_port or "8080"))
    print(icons.status.info .. " Auto-Reload: Active")
  else
    print(icons.status.error .. " Status: Not running")
  end

  print()
  print(icons.status.list .. " Available Commands:")
  print("  :WebServerStart [port]  - Start server (default: 8080)")
  print("  :WebServerStop          - Stop server")
  print("  :WebServerStatus        - Check status")
  print("  :WebServerOpen [port]   - Open browser")
  print("  :WebServerInfo          - This information")

  print()
  print(icons.status.list .. " Keybindings:")
  print("  <leader>ws  - Start server")
  print("  <leader>wS  - Stop server")
  print("  <leader>wo  - Open browser")
  print("  <leader>wi  - Server info")

  print()
  print(icons.status.list .. " Requirements:")
  local has_live_server = vim.fn.executable("live-server") == 1
  print(
    (has_live_server and icons.status.success or icons.status.error)
      .. " live-server: "
      .. (has_live_server and "Installed" or "Not found (npm install -g live-server)")
  )
end

return M
