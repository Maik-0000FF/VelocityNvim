# Web Server Setup - Quick Reference

## 🚀 One-Line Setup (New System)

```bash
bash ~/.config/VelocityNvim/scripts/setup-webserver.sh
```

This installs everything automatically.

**Supported Platforms:**
- ✅ Linux (Arch, Debian, Ubuntu)
- ✅ macOS (Intel & Apple Silicon M1/M2) → [See macOS Guide](./docs/MACOS_SETUP.md)

---

## 📋 Manual Installation

### Required Packages

```bash
# Arch Linux
sudo pacman -S nodejs npm curl lsof firefox
npm install -g live-server

# Ubuntu/Debian
sudo apt update
sudo apt install nodejs npm curl lsof firefox
npm install -g live-server

# macOS
brew install node curl
npm install -g live-server
brew install --cask firefox
```

---

## ✅ Verify Installation

```vim
" In Neovim
:checkhealth velocitynvim
```

Look for:
```
Web Development Server
  ✓ Web server fully functional
```

---

## 🎯 Usage

1. **Open HTML file**: `nvim index.html`
2. **Start server**: Press `<leader>ws`
3. **Browser opens automatically** with auto-reload ✨
4. **Edit & save**: Changes reload automatically
5. **Stop server**: Press `<leader>wS`

---

## 📦 Dependencies Summary

| Package | Purpose | Required |
|---------|---------|----------|
| **Node.js** | JavaScript runtime | ✅ Yes |
| **npm** | Package manager | ✅ Yes |
| **live-server** | Web server with auto-reload | ✅ Yes |
| **curl** | Server health checks | ✅ Yes |
| **lsof** | Port management | ✅ Yes |
| **firefox/xdg-open** | Browser opener | ✅ One of them |

---

## 🔧 Commands

```vim
:WebServerStart [port]  " Start (default: 8080)
:WebServerStop          " Stop
:WebServerInfo          " Show info
```

## ⌨️ Keybindings

```vim
<leader>ws  " Start server
<leader>wS  " Stop server
<leader>wo  " Open browser
<leader>wi  " Server info
```

---

## 📖 Full Documentation

See [docs/WEB_SERVER.md](./docs/WEB_SERVER.md) for:
- Detailed setup instructions
- Troubleshooting guide
- Architecture details
- Advanced configuration
- FAQ

---

## ⚡ Quick Test

```bash
# Create test file
echo '<h1>Test</h1>' > /tmp/test.html

# Open in Neovim
NVIM_APPNAME=VelocityNvim nvim /tmp/test.html

# In Neovim, press: <leader>ws
# Browser opens with http://localhost:8080/test.html
```

---

## 🆘 Troubleshooting

**Port already in use?**
```bash
lsof -ti:8080 | xargs kill -9
```

**live-server not found?**
```bash
npm install -g live-server
```

**Health check fails?**
```vim
:checkhealth velocitynvim
```

---

**Created**: 2025-11-21
**VelocityNvim Version**: 1.0.1+
