# VelocityNvim Web Development Server

## Overview

VelocityNvim includes a built-in web development server with **auto-reload** functionality for HTML/CSS/JS development.

**Platform Support:**
- ✅ Linux (Arch, Debian, Ubuntu, Fedora, etc.)
- ✅ macOS (Intel & Apple Silicon M1/M2) - [See macOS Setup Guide](./MACOS_SETUP.md)
- ⚠️ Windows (requires manual lsof alternative)

## Features

- ✅ **Auto-Reload**: Browser reloads automatically on file changes
- ✅ **Auto-Open**: Browser opens automatically on server start
- ✅ **Auto-Cleanup**: Server stops automatically when exiting Neovim
- ✅ **Multi-Format**: HTML, CSS, JavaScript, Markdown support
- ✅ **Port Management**: Automatic port cleanup and conflict resolution
- ✅ **File-Specific**: Opens the exact file you're editing

## Installation Requirements

### Required Dependencies

1. **Node.js** (v14.0.0 or higher)
   ```bash
   # Arch Linux
   sudo pacman -S nodejs npm

   # Ubuntu/Debian
   sudo apt install nodejs npm

   # macOS
   brew install node
   ```

2. **live-server** (npm global package)
   ```bash
   npm install -g live-server
   ```

3. **curl** (for health checks)
   ```bash
   # Arch Linux
   sudo pacman -S curl

   # Ubuntu/Debian (usually pre-installed)
   sudo apt install curl
   ```

4. **lsof** (for port management)
   ```bash
   # Arch Linux
   sudo pacman -S lsof

   # Ubuntu/Debian (usually pre-installed)
   sudo apt install lsof
   ```

5. **Firefox or xdg-open** (for browser opening)
   ```bash
   # Arch Linux
   sudo pacman -S firefox

   # Ubuntu/Debian
   sudo apt install firefox
   ```

### Verify Installation

Run the health check to verify all dependencies:

```vim
:checkhealth velocitynvim
```

Look for the "Web Development Server" section:

```
Web Development Server
  ✓ Web server utilities is available
  ✓ Node.js is installed
  ✓ npm is installed
  ✓ live-server is installed
  ✓ curl (for health checks) is installed
  ✓ lsof (for port management) is installed
  ✓ Firefox browser is installed
  ✓ Web server fully functional
    Commands: :WebServerStart, :WebServerStop, <leader>ws
    Node.js version: v25.2.1
    npm version: 11.6.3
    live-server version: 1.2.2
```

## Usage

### Commands

```vim
:WebServerStart [port]  " Start server (default: 8080)
:WebServerStop          " Stop server
:WebServerStatus        " Check if server is running
:WebServerOpen [port]   " Open browser manually
:WebServerInfo          " Show detailed server information
```

### Keybindings

```vim
<leader>ws  " Start server (auto-opens browser)
<leader>wS  " Stop server
<leader>wo  " Open browser
<leader>wi  " Show server info
```

### Workflow Example

1. **Open an HTML file**
   ```bash
   nvim index.html
   ```

2. **Start the server**
   - Press `<leader>ws` in normal mode
   - OR run `:WebServerStart`

3. **Browser opens automatically**
   - URL: `http://localhost:8080/index.html`
   - Server watches all files in the directory

4. **Edit and save**
   - Make changes to HTML/CSS/JS
   - Save with `:w`
   - Browser reloads automatically ✨

5. **Stop the server**
   - Press `<leader>wS`
   - OR run `:WebServerStop`

## Configuration

### Default Settings

- **Port**: 8080 (customizable)
- **Host**: 127.0.0.1 (localhost only)
- **Watch**: Current directory
- **Auto-Reload**: Enabled
- **CSS Inject**: Disabled (full page reload)

### Custom Port

```vim
:WebServerStart 3000  " Use port 3000 instead
```

Or in keybinding:
```lua
vim.keymap.set("n", "<leader>w3", function()
  require("utils.webserver").start_server(3000)
end, { desc = "Web: Start on port 3000" })
```

## Troubleshooting

### Port Already in Use

The server automatically kills processes on the target port before starting. If you encounter issues:

```bash
# Manually check port
lsof -ti:8080

# Manually kill process
kill -9 $(lsof -ti:8080)
```

### Browser Not Opening

1. Check browser installation:
   ```bash
   which firefox  # or xdg-open
   ```

2. Test manual opening:
   ```bash
   firefox http://localhost:8080
   ```

3. Check server status:
   ```vim
   :WebServerStatus
   ```

### Auto-Reload Not Working

1. Ensure live-server is running:
   ```bash
   ps aux | grep live-server
   ```

2. Check file watching:
   - Files must be in the same directory as the opened HTML file
   - Subdirectories are also watched

3. Browser console:
   - Should show live-server connection message
   - F12 → Console → Look for WebSocket connection

### Health Check Fails

Run detailed health check:
```vim
:checkhealth velocitynvim
```

Install missing dependencies based on the output.

## Architecture

### File Structure

```
lua/
├── utils/
│   └── webserver.lua       # Web server implementation
├── core/
│   ├── commands.lua        # :WebServer* commands
│   ├── keymaps.lua         # <leader>w* keybindings
│   └── health.lua          # Health checks
└── health/
    └── velocitynvim.lua    # Health registration
```

### How It Works

1. **Server Start**:
   - Validates HTML file is open
   - Kills any existing server on port
   - Starts live-server via jobstart()
   - Waits 1.5s for server startup
   - Performs health check (curl)
   - Opens browser with specific file URL

2. **Auto-Reload**:
   - live-server watches directory for changes
   - Injects WebSocket into HTML pages
   - Detects file modifications
   - Sends reload signal to browser

3. **Server Stop**:
   - Stops Neovim job
   - Kills process on port (cleanup)
   - Clears server state

4. **Auto-Cleanup on Exit**:
   - VimLeavePre autocmd detects Neovim exit
   - Automatically stops running server
   - Cleans up port (prevents orphaned processes)
   - Silent operation (no notifications on exit)

## Performance

- **Startup Impact**: ~0ms (loaded on demand)
- **Memory Usage**: ~15-20MB (Node.js process)
- **Auto-Reload Latency**: <100ms typical
- **Port Cleanup**: <500ms

## New System Setup

### Quick Setup Script

```bash
#!/bin/bash
# VelocityNvim Web Server Setup

# 1. Install Node.js and npm
sudo pacman -S nodejs npm  # Arch
# sudo apt install nodejs npm  # Ubuntu/Debian

# 2. Install live-server
npm install -g live-server

# 3. Install system tools (if not present)
sudo pacman -S curl lsof firefox  # Arch
# sudo apt install curl lsof firefox  # Ubuntu/Debian

# 4. Verify installation
node --version
npm --version
live-server --version
curl --version
lsof -v
firefox --version

# 5. Test in Neovim
echo '<h1>Test</h1>' > /tmp/test.html
NVIM_APPNAME=VelocityNvim nvim /tmp/test.html
# Then: <leader>ws
```

### Minimal Setup (no npm)

If you don't want Node.js/npm, you can use Python's built-in server (no auto-reload):

```lua
-- Alternative implementation without live-server
vim.keymap.set("n", "<leader>ws", function()
  local port = 8080
  local dir = vim.fn.expand("%:p:h")
  vim.fn.jobstart(string.format("python -m http.server %d --directory %s", port, dir))
  vim.defer_fn(function()
    vim.fn.system(string.format("firefox http://localhost:%d &", port))
  end, 1000)
end, { desc = "Start Python HTTP server" })
```

## FAQ

**Q: Does it work with CSS/JS files too?**
A: Yes! Edit any file in the directory and the browser reloads.

**Q: Can I use a different browser?**
A: Yes, modify `utils/webserver.lua` line 149 to use your preferred browser.

**Q: Does it support HTTPS?**
A: No, only HTTP for local development.

**Q: Can I serve multiple projects simultaneously?**
A: Yes, use different ports: `:WebServerStart 8080` and `:WebServerStart 3000`

**Q: Does it work on Windows?**
A: The code is designed for Linux/macOS. Windows support requires modifications to port management (lsof alternative).

## See Also

- [BENCHMARKS.md](./BENCHMARKS.md) - Performance testing
- [DEVELOPMENT.md](./DEVELOPMENT.md) - Development workflow
- [DEBUGGING.md](./DEBUGGING.md) - Troubleshooting guide
