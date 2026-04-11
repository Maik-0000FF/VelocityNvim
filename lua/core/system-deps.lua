-- ~/.config/VelocityNvim/lua/core/system-deps.lua
-- System Dependencies Manager for VelocityNvim
-- Handles detection and installation of all required system tools

local M = {}

-- Detect operating system
M.detect_os = function()
  local os_name = "unknown"
  local distro = "unknown"
  local pkg_manager = nil

  if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
    os_name = "macos"
    distro = "macos"
    pkg_manager = vim.fn.executable("brew") == 1 and "brew" or nil
  elseif vim.fn.has("unix") == 1 then
    os_name = "linux"
    -- Detect Linux distribution
    if vim.fn.filereadable("/etc/os-release") == 1 then
      local os_release = vim.fn.readfile("/etc/os-release")
      for _, line in ipairs(os_release) do
        local id = line:match("^ID=(.+)$")
        if id then
          distro = id:gsub('"', ''):lower()
          break
        end
      end
    end
    -- Detect package manager
    if vim.fn.executable("pacman") == 1 then
      pkg_manager = "pacman"
    elseif vim.fn.executable("apt") == 1 then
      pkg_manager = "apt"
    elseif vim.fn.executable("dnf") == 1 then
      pkg_manager = "dnf"
    elseif vim.fn.executable("brew") == 1 then
      pkg_manager = "brew"
    end
  end

  return {
    os = os_name,
    distro = distro,
    pkg_manager = pkg_manager,
    is_arch = distro == "arch" or distro == "archlinux" or distro == "manjaro" or distro == "endeavouros",
    is_debian = distro == "ubuntu" or distro == "debian" or distro == "linuxmint" or distro == "pop",
    is_fedora = distro == "fedora" or distro == "rhel" or distro == "centos",
    is_macos = os_name == "macos",
  }
end

-- Package definitions with install commands for different systems
-- Categories: core, search, git, rust, lsp, formatters, clipboard, pdf, web, latex, typst
M.packages = {
  -- ═══════════════════════════════════════════════════════════════════════════
  -- CORE (Required for basic functionality)
  -- ═══════════════════════════════════════════════════════════════════════════
  core = {
    title = "Core Tools",
    description = "Essential tools required for VelocityNvim to function",
    required = true,
    packages = {
      {
        name = "git",
        check_cmd = "git",
        description = "Version control system",
        arch = "git",
        debian = "git",
        fedora = "git",
        macos = "git",
      },
      {
        name = "gcc",
        check_cmd = "gcc",
        description = "C compiler for Treesitter parsers",
        arch = "gcc",
        debian = "build-essential",
        fedora = "gcc",
        macos = nil, -- Xcode command line tools
      },
      {
        name = "make",
        check_cmd = "make",
        description = "Build automation tool",
        arch = "make",
        debian = "make",
        fedora = "make",
        macos = nil, -- Xcode command line tools
      },
      {
        name = "curl",
        check_cmd = "curl",
        description = "URL transfer tool",
        arch = "curl",
        debian = "curl",
        fedora = "curl",
        macos = "curl",
      },
      {
        name = "unzip",
        check_cmd = "unzip",
        description = "Archive extraction",
        arch = "unzip",
        debian = "unzip",
        fedora = "unzip",
        macos = nil, -- Built-in
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- SEARCH (Fast file and content search)
  -- ═══════════════════════════════════════════════════════════════════════════
  search = {
    title = "Search Tools",
    description = "High-performance search utilities (Rust-powered)",
    required = true,
    packages = {
      {
        name = "fzf",
        check_cmd = "fzf",
        description = "Fuzzy finder for files and commands",
        arch = "fzf",
        debian = "fzf",
        fedora = "fzf",
        macos = "fzf",
      },
      {
        name = "ripgrep",
        check_cmd = "rg",
        description = "Ultra-fast text search (grep replacement)",
        arch = "ripgrep",
        debian = "ripgrep",
        fedora = "ripgrep",
        macos = "ripgrep",
      },
      {
        name = "fd",
        check_cmd = "fd",
        description = "Fast file finder (find replacement)",
        arch = "fd",
        debian = "fd-find",
        fedora = "fd-find",
        macos = "fd",
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- GIT ENHANCEMENT
  -- ═══════════════════════════════════════════════════════════════════════════
  git_tools = {
    title = "Git Enhancement",
    description = "Better git diffs and syntax highlighting",
    required = false,
    packages = {
      {
        name = "bat",
        check_cmd = "bat",
        description = "Syntax-highlighted file viewer (cat replacement)",
        arch = "bat",
        debian = "bat",
        fedora = "bat",
        macos = "bat",
      },
      {
        name = "delta",
        check_cmd = "delta",
        description = "Beautiful git diffs with syntax highlighting",
        arch = "git-delta",
        debian = nil, -- cargo install git-delta
        fedora = nil, -- cargo install git-delta
        macos = "git-delta",
        cargo = "git-delta",
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- RUST TOOLCHAIN (for blink.cmp performance - needs nightly)
  -- ═══════════════════════════════════════════════════════════════════════════
  rust = {
    title = "Rust Toolchain",
    description = "Required for blink.cmp ultra-fast completion (needs nightly)",
    required = false,
    packages = {
      {
        name = "rustup",
        check_cmd = "rustup",
        description = "Rust toolchain manager (for nightly support)",
        arch = "rustup",
        debian = nil, -- Use curl installer
        fedora = "rustup",
        macos = "rustup",
        rustup = true, -- Fallback to curl installer
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CLIPBOARD (System clipboard integration)
  -- ═══════════════════════════════════════════════════════════════════════════
  clipboard = {
    title = "Clipboard Support",
    description = "System clipboard integration for copy/paste",
    required = true,
    packages = {
      {
        name = "xclip",
        check_cmd = "xclip",
        description = "X11 clipboard tool",
        arch = "xclip",
        debian = "xclip",
        fedora = "xclip",
        macos = nil, -- pbcopy/pbpaste built-in
        wayland_alt = "wl-clipboard",
        condition = function()
          -- Only needed on Linux with X11
          local sys = M.detect_os()
          if sys.is_macos then return false end
          return vim.env.XDG_SESSION_TYPE ~= "wayland"
        end,
      },
      {
        name = "wl-clipboard",
        check_cmd = "wl-copy",
        description = "Wayland clipboard tool",
        arch = "wl-clipboard",
        debian = "wl-clipboard",
        fedora = "wl-clipboard",
        macos = nil,
        condition = function()
          local sys = M.detect_os()
          if sys.is_macos then return false end
          return vim.env.XDG_SESSION_TYPE == "wayland"
        end,
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- NODE.JS (for LSP servers and web tools)
  -- ═══════════════════════════════════════════════════════════════════════════
  nodejs = {
    title = "Node.js Runtime",
    description = "Required for TypeScript LSP and web development",
    required = false,
    packages = {
      {
        name = "nodejs",
        check_cmd = "node",
        description = "JavaScript runtime",
        arch = "nodejs",
        debian = "nodejs",
        fedora = "nodejs",
        macos = "node",
      },
      {
        name = "npm",
        check_cmd = "npm",
        description = "Node.js package manager",
        arch = "npm",
        debian = "npm",
        fedora = "npm",
        macos = nil, -- Included with node
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- LSP SERVERS
  -- ═══════════════════════════════════════════════════════════════════════════
  lsp = {
    title = "Language Servers",
    description = "IDE features: completion, diagnostics, go-to-definition",
    required = false,
    packages = {
      {
        name = "lua-language-server",
        check_cmd = "lua-language-server",
        description = "Lua LSP (for Neovim config editing)",
        arch = "lua-language-server",
        debian = nil, -- Manual install
        fedora = nil,
        macos = "lua-language-server",
      },
      {
        name = "pyright",
        check_cmd = "pyright",
        description = "Python LSP (type checking)",
        arch = "pyright",
        debian = nil, -- npm install
        fedora = nil,
        macos = "pyright",
        npm = "pyright",
      },
      {
        name = "rust-analyzer",
        check_cmd = "rust-analyzer",
        description = "Rust LSP",
        arch = "rust-analyzer",
        debian = nil,
        fedora = nil,
        macos = "rust-analyzer",
      },
      {
        name = "typescript-language-server",
        check_cmd = "typescript-language-server",
        description = "TypeScript/JavaScript LSP",
        arch = nil,
        debian = nil,
        fedora = nil,
        macos = nil,
        npm = "typescript typescript-language-server",
      },
      {
        name = "vscode-langservers",
        check_cmd = "vscode-html-language-server",
        description = "HTML/CSS/JSON LSP servers",
        arch = nil,
        debian = nil,
        fedora = nil,
        macos = nil,
        npm = "vscode-langservers-extracted",
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- FORMATTERS
  -- ═══════════════════════════════════════════════════════════════════════════
  formatters = {
    title = "Code Formatters",
    description = "Auto-format code on save",
    required = false,
    packages = {
      {
        name = "stylua",
        check_cmd = "stylua",
        description = "Lua code formatter",
        arch = "stylua",
        debian = nil,
        fedora = nil,
        macos = "stylua",
        cargo = "stylua",
      },
      {
        name = "prettier",
        check_cmd = "prettier",
        description = "JS/TS/HTML/CSS/JSON formatter",
        arch = nil,
        debian = nil,
        fedora = nil,
        macos = nil,
        npm = "prettier",
      },
      {
        name = "shfmt",
        check_cmd = "shfmt",
        description = "Shell script formatter",
        arch = "shfmt",
        debian = nil,
        fedora = nil,
        macos = "shfmt",
      },
      {
        name = "ruff",
        check_cmd = "ruff",
        description = "Ultra-fast Python linter and formatter",
        arch = "ruff",
        debian = nil,
        fedora = nil,
        macos = "ruff",
        pip = "ruff",
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- PDF VIEWER (for LaTeX/Typst preview)
  -- ═══════════════════════════════════════════════════════════════════════════
  pdf = {
    title = "PDF Viewer",
    description = "PDF viewing with SyncTeX support for LaTeX",
    required = false,
    packages = {
      {
        name = "zathura",
        check_cmd = "zathura",
        description = "Lightweight PDF viewer with SyncTeX",
        arch = "zathura zathura-pdf-mupdf",
        debian = "zathura",
        fedora = "zathura zathura-pdf-mupdf",
        macos = nil, -- Use Skim or Preview
      },
      {
        name = "xdg-utils",
        check_cmd = "xdg-open",
        description = "Default application opener",
        arch = "xdg-utils",
        debian = "xdg-utils",
        fedora = "xdg-utils",
        macos = nil, -- open command built-in
        condition = function()
          return not M.detect_os().is_macos
        end,
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- LATEX SUPPORT
  -- ═══════════════════════════════════════════════════════════════════════════
  latex = {
    title = "LaTeX Support",
    description = "Scientific writing with PDF compilation",
    required = false,
    packages = {
      {
        name = "texlab",
        check_cmd = "texlab",
        description = "LaTeX language server",
        arch = "texlab",
        debian = nil,
        fedora = nil,
        macos = "texlab",
        cargo = "texlab",
      },
      {
        name = "texlive",
        check_cmd = "pdflatex",
        description = "TeX Live distribution",
        arch = "texlive-basic texlive-binextra texlive-latex texlive-latexrecommended",
        debian = "texlive-latex-base texlive-latex-extra",
        fedora = "texlive-scheme-basic",
        macos = nil, -- mactex cask
        macos_cask = "mactex-no-gui",
      },
      {
        name = "latexmk",
        check_cmd = "latexmk",
        description = "LaTeX build automation",
        arch = "texlive-binextra",
        debian = "latexmk",
        fedora = "latexmk",
        macos = nil, -- Included in mactex
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- TYPST SUPPORT
  -- ═══════════════════════════════════════════════════════════════════════════
  typst = {
    title = "Typst Support",
    description = "Modern typesetting alternative to LaTeX",
    required = false,
    packages = {
      {
        name = "typst",
        check_cmd = "typst",
        description = "Typst compiler",
        arch = "typst",
        debian = nil,
        fedora = nil,
        macos = "typst",
        cargo = "typst-cli",
      },
      {
        name = "tinymist",
        check_cmd = "tinymist",
        description = "Typst language server",
        arch = "tinymist",
        debian = nil,
        fedora = nil,
        macos = nil,
        cargo = "tinymist",
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- WEB DEVELOPMENT
  -- ═══════════════════════════════════════════════════════════════════════════
  web = {
    title = "Web Development",
    description = "Live preview server and browser integration",
    required = false,
    packages = {
      {
        name = "live-server",
        check_cmd = "live-server",
        description = "Development server with live reload",
        arch = nil,
        debian = nil,
        fedora = nil,
        macos = nil,
        npm = "live-server",
      },
      {
        name = "browser",
        check_cmd = "firefox",
        description = "Web browser for preview",
        arch = "firefox",
        debian = "firefox",
        fedora = "firefox",
        macos = nil, -- Safari built-in
        alternatives = { "chromium", "google-chrome-stable", "brave" },
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════════════
  -- STRUDEL (Live Coding Music)
  -- ═══════════════════════════════════════════════════════════════════════════
  strudel = {
    title = "Strudel (Live Coding)",
    description = "Pattern-based music programming",
    required = false,
    packages = {
      {
        name = "chromium",
        check_cmd = "chromium",
        description = "Browser for Strudel audio",
        arch = "chromium",
        debian = "chromium-browser",
        fedora = "chromium",
        macos = nil,
        macos_cask = "chromium",
        alternatives = { "brave", "google-chrome-stable" },
      },
    },
  },
}

-- Installation profiles
M.profiles = {
  minimal = {
    name = "Minimal",
    description = "Core functionality only (editor + basic LSP)",
    categories = { "core", "search", "clipboard" },
  },
  standard = {
    name = "Standard",
    description = "Recommended for most developers",
    categories = { "core", "search", "clipboard", "git_tools", "rust", "nodejs", "lsp", "formatters" },
  },
  full = {
    name = "Full",
    description = "Everything including LaTeX, Typst, and web tools",
    categories = { "core", "search", "clipboard", "git_tools", "rust", "nodejs", "lsp", "formatters", "pdf", "latex", "typst", "web" },
  },
  custom = {
    name = "Custom",
    description = "Choose individual packages",
    categories = {},
  },
}

-- Check if a package is installed
M.is_installed = function(pkg)
  if pkg.condition and not pkg.condition() then
    return true -- Skip if condition not met
  end
  return vim.fn.executable(pkg.check_cmd) == 1
end

-- Get install command for a package
-- Note: assume_tools_available=true means npm/cargo/pip will be installed first
M.get_install_cmd = function(pkg, sys, assume_tools_available)
  local pkg_name = nil
  local method = "system"

  -- System package managers take priority
  if sys.is_arch and pkg.arch then
    pkg_name = pkg.arch
    method = "pacman"
  elseif sys.is_debian and pkg.debian then
    pkg_name = pkg.debian
    method = "apt"
  elseif sys.is_fedora and pkg.fedora then
    pkg_name = pkg.fedora
    method = "dnf"
  elseif sys.is_macos and pkg.macos then
    pkg_name = pkg.macos
    method = "brew"
  elseif sys.is_macos and pkg.macos_cask then
    pkg_name = pkg.macos_cask
    method = "brew_cask"
  -- For npm/cargo/pip: always include if assume_tools_available or if tool exists
  elseif pkg.npm and (assume_tools_available or vim.fn.executable("npm") == 1) then
    pkg_name = pkg.npm
    method = "npm"
  elseif pkg.cargo and (assume_tools_available or vim.fn.executable("cargo") == 1) then
    pkg_name = pkg.cargo
    method = "cargo"
  elseif pkg.pip and (assume_tools_available or vim.fn.executable("pip3") == 1) then
    pkg_name = pkg.pip
    method = "pip"
  elseif pkg.rustup then
    method = "rustup"
  end

  if not pkg_name and method == "system" then
    return nil, nil
  end

  local cmd = nil
  if method == "pacman" then
    cmd = "sudo pacman -S --needed --noconfirm " .. pkg_name
  elseif method == "apt" then
    cmd = "sudo apt install -y " .. pkg_name
  elseif method == "dnf" then
    cmd = "sudo dnf install -y " .. pkg_name
  elseif method == "brew" then
    cmd = "brew install " .. pkg_name
  elseif method == "brew_cask" then
    cmd = "brew install --cask " .. pkg_name
  elseif method == "npm" then
    cmd = "npm install -g " .. pkg_name
  elseif method == "cargo" then
    cmd = "cargo install " .. pkg_name
  elseif method == "pip" then
    cmd = "pip3 install --user " .. pkg_name
  elseif method == "rustup" then
    cmd = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
  end

  return cmd, method
end

-- Get all missing packages for a list of categories
M.get_missing_packages = function(categories)
  local sys = M.detect_os()
  local missing = {}

  -- Check if nodejs/rust/python are in the categories being installed
  -- If so, npm/cargo/pip will be available after system packages install
  local will_have_npm = vim.tbl_contains(categories, "nodejs") or vim.fn.executable("npm") == 1
  local will_have_cargo = vim.tbl_contains(categories, "rust") or vim.fn.executable("cargo") == 1
  local assume_tools = will_have_npm or will_have_cargo

  for _, cat_name in ipairs(categories) do
    local category = M.packages[cat_name]
    if category then
      for _, pkg in ipairs(category.packages) do
        if not M.is_installed(pkg) then
          local cmd, method = M.get_install_cmd(pkg, sys, assume_tools)
          if cmd then
            table.insert(missing, {
              name = pkg.name,
              description = pkg.description,
              category = cat_name,
              category_title = category.title,
              cmd = cmd,
              method = method,
            })
          end
        end
      end
    end
  end

  return missing
end

-- Generate combined install command
M.generate_install_script = function(categories)
  local sys = M.detect_os()
  local missing = M.get_missing_packages(categories)

  if #missing == 0 then
    return nil, "All packages are already installed!"
  end

  -- Group by installation method
  local by_method = {}
  for _, pkg in ipairs(missing) do
    by_method[pkg.method] = by_method[pkg.method] or {}
    table.insert(by_method[pkg.method], pkg)
  end

  local script_lines = {
    "#!/bin/bash",
    "# VelocityNvim Dependency Installation Script",
    "# Generated for: " .. sys.distro .. " (" .. sys.os .. ")",
    "",
    "set -e",
    "",
  }

  -- Track if we need to refresh PATH
  local needs_path_refresh = false

  -- System packages first
  if by_method.pacman then
    local pkgs = {}
    for _, p in ipairs(by_method.pacman) do
      for pkg in p.cmd:gmatch("--noconfirm%s+(.+)$") do
        table.insert(pkgs, pkg)
      end
    end
    table.insert(script_lines, "# Arch Linux packages")
    table.insert(script_lines, "sudo pacman -S --needed --noconfirm " .. table.concat(pkgs, " "))
    table.insert(script_lines, "")
    needs_path_refresh = true
  end

  if by_method.apt then
    table.insert(script_lines, "# Debian/Ubuntu packages")
    table.insert(script_lines, "sudo apt update")
    local pkgs = {}
    for _, p in ipairs(by_method.apt) do
      for pkg in p.cmd:gmatch("-y%s+(.+)$") do
        table.insert(pkgs, pkg)
      end
    end
    table.insert(script_lines, "sudo apt install -y " .. table.concat(pkgs, " "))
    table.insert(script_lines, "")
    needs_path_refresh = true
  end

  if by_method.brew then
    local pkgs = {}
    for _, p in ipairs(by_method.brew) do
      for pkg in p.cmd:gmatch("install%s+(.+)$") do
        table.insert(pkgs, pkg)
      end
    end
    table.insert(script_lines, "# Homebrew packages")
    table.insert(script_lines, "brew install " .. table.concat(pkgs, " "))
    table.insert(script_lines, "")
    needs_path_refresh = true
  end

  -- Refresh PATH after system package installation (so npm, cargo etc. are found)
  if needs_path_refresh and (by_method.npm or by_method.cargo or by_method.pip) then
    table.insert(script_lines, "# Refresh PATH to find newly installed commands")
    table.insert(script_lines, "hash -r 2>/dev/null || true")
    table.insert(script_lines, "")
  end

  -- Rustup if needed
  if by_method.rustup then
    table.insert(script_lines, "# Rust toolchain")
    table.insert(script_lines, 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y')
    table.insert(script_lines, 'source "$HOME/.cargo/env"')
    table.insert(script_lines, "")
  end

  -- npm packages (use full path as fallback if npm was just installed)
  if by_method.npm then
    local pkgs = {}
    for _, p in ipairs(by_method.npm) do
      for pkg in p.cmd:gmatch("-g%s+(.+)$") do
        table.insert(pkgs, pkg)
      end
    end
    table.insert(script_lines, "# npm packages (global install requires sudo on Linux)")
    table.insert(script_lines, "# Find npm - check multiple locations for freshly installed npm")
    table.insert(script_lines, 'NPM_CMD=""')
    table.insert(script_lines, 'for npm_path in /usr/bin/npm /usr/local/bin/npm "$HOME/.local/bin/npm"; do')
    table.insert(script_lines, '  if [ -x "$npm_path" ]; then')
    table.insert(script_lines, '    NPM_CMD="$npm_path"')
    table.insert(script_lines, '    break')
    table.insert(script_lines, '  fi')
    table.insert(script_lines, 'done')
    table.insert(script_lines, '# Fallback to command -v')
    table.insert(script_lines, 'if [ -z "$NPM_CMD" ]; then')
    table.insert(script_lines, '  NPM_CMD=$(command -v npm 2>/dev/null || true)')
    table.insert(script_lines, 'fi')
    table.insert(script_lines, "")
    table.insert(script_lines, 'if [ -n "$NPM_CMD" ] && [ -x "$NPM_CMD" ]; then')
    table.insert(script_lines, '  echo "Found npm at: $NPM_CMD"')
    -- Use sudo on Linux, no sudo on macOS (uses ~/.npm-global)
    if sys.is_macos then
      table.insert(script_lines, '  "$NPM_CMD" install -g ' .. table.concat(pkgs, " "))
    else
      table.insert(script_lines, '  echo "Installing npm packages globally (requires sudo)..."')
      table.insert(script_lines, '  sudo "$NPM_CMD" install -g ' .. table.concat(pkgs, " "))
    end
    table.insert(script_lines, "else")
    table.insert(script_lines, '  echo "ERROR: npm not found! Please install nodejs/npm first."')
    table.insert(script_lines, '  echo "Arch Linux: sudo pacman -S nodejs npm"')
    table.insert(script_lines, '  echo "macOS: brew install node"')
    table.insert(script_lines, "fi")
    table.insert(script_lines, "")
  end

  -- Cargo packages (use full path as fallback)
  if by_method.cargo then
    table.insert(script_lines, "# Cargo packages")
    table.insert(script_lines, '# Find cargo (might be freshly installed)')
    table.insert(script_lines, 'CARGO_CMD=$(command -v cargo || echo "$HOME/.cargo/bin/cargo")')
    table.insert(script_lines, 'if [ -x "$CARGO_CMD" ]; then')
    for _, p in ipairs(by_method.cargo) do
      local pkg_name = p.cmd:match("cargo install%s+(.+)$")
      if pkg_name then
        table.insert(script_lines, '  "$CARGO_CMD" install ' .. pkg_name)
      end
    end
    table.insert(script_lines, "else")
    table.insert(script_lines, '  echo "Warning: cargo not found, skipping cargo packages"')
    table.insert(script_lines, "fi")
    table.insert(script_lines, "")
  end

  -- pip packages
  if by_method.pip then
    local pkgs = {}
    for _, p in ipairs(by_method.pip) do
      for pkg in p.cmd:gmatch("--user%s+(.+)$") do
        table.insert(pkgs, pkg)
      end
    end
    table.insert(script_lines, "# Python packages")
    table.insert(script_lines, 'PIP_CMD=$(command -v pip3 || command -v pip || echo "")')
    table.insert(script_lines, 'if [ -n "$PIP_CMD" ]; then')
    table.insert(script_lines, '  "$PIP_CMD" install --user ' .. table.concat(pkgs, " "))
    table.insert(script_lines, "else")
    table.insert(script_lines, '  echo "Warning: pip not found, skipping Python packages"')
    table.insert(script_lines, "fi")
    table.insert(script_lines, "")
  end

  table.insert(script_lines, 'echo "Installation complete!"')

  return table.concat(script_lines, "\n"), missing
end

-- Get status summary
M.get_status = function()
  local sys = M.detect_os()
  local status = {
    system = sys,
    categories = {},
    total_installed = 0,
    total_missing = 0,
  }

  for cat_name, category in pairs(M.packages) do
    local cat_status = {
      name = cat_name,
      title = category.title,
      description = category.description,
      required = category.required,
      installed = 0,
      missing = 0,
      packages = {},
    }

    for _, pkg in ipairs(category.packages) do
      local is_installed = M.is_installed(pkg)
      table.insert(cat_status.packages, {
        name = pkg.name,
        description = pkg.description,
        installed = is_installed,
      })
      if is_installed then
        cat_status.installed = cat_status.installed + 1
        status.total_installed = status.total_installed + 1
      else
        cat_status.missing = cat_status.missing + 1
        status.total_missing = status.total_missing + 1
      end
    end

    status.categories[cat_name] = cat_status
  end

  return status
end

-- Create user commands for system dependency management
vim.api.nvim_create_user_command("SystemDeps", function()
  local status = M.get_status()
  local sys = status.system

  local lines = {
    "╔══════════════════════════════════════════════════════════════════════════════╗",
    "║                     VelocityNvim System Dependencies                          ║",
    "╠══════════════════════════════════════════════════════════════════════════════╣",
    string.format("║  System: %-67s ║", sys.distro .. " (" .. (sys.pkg_manager or "no pkg manager") .. ")"),
    string.format("║  Installed: %-5d | Missing: %-5d                                        ║", status.total_installed, status.total_missing),
    "╠══════════════════════════════════════════════════════════════════════════════╣",
  }

  -- Category order for consistent display
  local order = { "core", "search", "clipboard", "git_tools", "rust", "nodejs", "lsp", "formatters", "pdf", "latex", "typst", "web", "strudel" }

  for _, cat_name in ipairs(order) do
    local cat = status.categories[cat_name]
    if cat then
      local status_icon = cat.missing == 0 and "✓" or "✗"
      local req_str = cat.required and " (required)" or ""
      table.insert(lines, string.format("║  %s %-20s %d/%d installed%-20s ║",
        status_icon,
        cat.title .. req_str,
        cat.installed,
        cat.installed + cat.missing,
        ""
      ))

      -- Show missing packages
      for _, pkg in ipairs(cat.packages) do
        if not pkg.installed then
          table.insert(lines, string.format("║      └─ %-66s ║", pkg.name .. " - " .. pkg.description))
        end
      end
    end
  end

  table.insert(lines, "╠══════════════════════════════════════════════════════════════════════════════╣")
  table.insert(lines, "║  Commands:                                                                   ║")
  table.insert(lines, "║    :SystemDepsInstall [profile]  - Install dependencies (minimal/standard/full) ║")
  table.insert(lines, "║    :SystemDepsScript [profile]   - Generate install script                   ║")
  table.insert(lines, "╚══════════════════════════════════════════════════════════════════════════════╝")

  -- Display in floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local width = 82
  local height = #lines
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  -- Close on q or Esc
  vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set('n', '<Esc>', function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end, { desc = "Show system dependency status" })

vim.api.nvim_create_user_command("SystemDepsInstall", function(opts)
  local profile = opts.args ~= "" and opts.args or "standard"

  if not M.profiles[profile] then
    vim.notify("Unknown profile: " .. profile .. ". Use: minimal, standard, or full", vim.log.levels.ERROR)
    return
  end

  local sys = M.detect_os()
  if not sys.pkg_manager then
    vim.notify("No supported package manager found", vim.log.levels.ERROR)
    return
  end

  local categories = M.profiles[profile].categories
  local missing = M.get_missing_packages(categories)

  if #missing == 0 then
    vim.notify("All packages for " .. profile .. " profile are already installed!", vim.log.levels.INFO)
    return
  end

  local script, _ = M.generate_install_script(categories)
  if script then
    local script_path = vim.fn.stdpath("data") .. "/velocity-install-deps.sh"
    vim.fn.writefile(vim.split(script, "\n"), script_path)
    vim.fn.setfperm(script_path, "rwxr-xr-x")

    vim.notify("Installing " .. #missing .. " packages for " .. profile .. " profile...", vim.log.levels.INFO)

    -- Open terminal in full buffer
    vim.cmd("enew | terminal bash " .. script_path)
    vim.cmd("startinsert")
  end
end, {
  nargs = "?",
  complete = function() return { "minimal", "standard", "full" } end,
  desc = "Install system dependencies for a profile",
})

vim.api.nvim_create_user_command("SystemDepsScript", function(opts)
  local profile = opts.args ~= "" and opts.args or "standard"

  if not M.profiles[profile] then
    vim.notify("Unknown profile: " .. profile .. ". Use: minimal, standard, or full", vim.log.levels.ERROR)
    return
  end

  local categories = M.profiles[profile].categories
  local script, missing = M.generate_install_script(categories)

  if not script then
    vim.notify(missing or "All packages already installed!", vim.log.levels.INFO)
    return
  end

  -- Copy to clipboard
  vim.fn.setreg("+", script)
  vim.fn.setreg("*", script)

  -- Also show in a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(script, "\n"))
  vim.bo[buf].filetype = "bash"

  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, buf)

  vim.notify("Install script copied to clipboard and shown in buffer", vim.log.levels.INFO)
end, {
  nargs = "?",
  complete = function() return { "minimal", "standard", "full" } end,
  desc = "Generate install script for a profile",
})

return M
