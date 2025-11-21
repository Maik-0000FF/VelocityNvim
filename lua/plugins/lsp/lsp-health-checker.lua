-- ~/.config/VelocityNvim/lua/plugins/lsp/lsp-health-checker.lua
-- Robust LSP health checks with fallback strategies

local M = {}
local icons = require("core.icons")

-- LSP health check functions
local health_checks = {
  ts_ls = function()
    local cmd_ok = vim.fn.executable("typescript-language-server") == 1
    if not cmd_ok then
      return false,
        "typescript-language-server not found. Installation: npm install -g typescript-language-server"
    end

    -- TypeScript runtime check
    local ts_paths = {
      vim.fn.getcwd() .. "/node_modules/typescript/lib/tsserver.js",
      vim.fn.system("npm root -g 2>/dev/null"):gsub("%s+", "") .. "/typescript/lib/tsserver.js",
      "/usr/lib/node_modules/typescript/lib/tsserver.js",
    }

    for _, path in ipairs(ts_paths) do
      if vim.fn.filereadable(path) == 1 then
        return true, "TypeScript LSP: " .. path
      end
    end

    return false, "TypeScript runtime not found. Installation: npm install -g typescript"
  end,

  htmlls = function()
    local cmd_ok = vim.fn.executable("vscode-html-language-server") == 1
    if not cmd_ok then
      return false,
        "vscode-html-language-server not found. Installation: npm install -g vscode-langservers-extracted"
    end
    return true, "HTML LSP available"
  end,

  cssls = function()
    local cmd_ok = vim.fn.executable("vscode-css-language-server") == 1
    if not cmd_ok then
      return false,
        "vscode-css-language-server not found. Installation: npm install -g vscode-langservers-extracted"
    end
    return true, "CSS LSP available"
  end,

  jsonls = function()
    local cmd_ok = vim.fn.executable("vscode-json-language-server") == 1
    if not cmd_ok then
      return false,
        "vscode-json-language-server not found. Installation: npm install -g vscode-langservers-extracted"
    end
    return true, "JSON LSP available"
  end,

  pyright = function()
    local cmd_ok = vim.fn.executable("pyright-langserver") == 1
    if not cmd_ok then
      return false, "pyright-langserver not found. Installation: npm install -g pyright"
    end

    -- Python runtime check
    local python_ok = vim.fn.executable("python3") == 1 or vim.fn.executable("python") == 1
    if not python_ok then
      return false, "Python runtime not found. Installation: pacman -S python"
    end

    return true, "Python LSP available"
  end,

  rust_analyzer = function()
    local cmd_ok = vim.fn.executable("rust-analyzer") == 1
    if not cmd_ok then
      return false, "rust-analyzer not found. Installation: rustup component add rust-analyzer"
    end

    -- Rust toolchain check
    local rustc_ok = vim.fn.executable("rustc") == 1
    if not rustc_ok then
      return false,
        "Rust toolchain not found. Installation: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    end

    return true, "Rust LSP available"
  end,

  texlab = function()
    local cmd_ok = vim.fn.executable("texlab") == 1
    if not cmd_ok then
      return false, "texlab not found. Installation: pacman -S texlab"
    end

    -- LaTeX distribution check (optional, since texlab works without it)
    local latex_ok = vim.fn.executable("pdflatex") == 1 or vim.fn.executable("lualatex") == 1
    if not latex_ok then
      return true, "TeXLab available (LaTeX distribution recommended: pacman -S texlive-core)"
    end

    return true, "LaTeX LSP available with distribution"
  end,

  luals = function()
    local cmd_ok = vim.fn.executable("lua-language-server") == 1
    if not cmd_ok then
      return false,
        "lua-language-server not found. Installation: pacman -S lua-language-server"
    end
    return true, "Lua LSP available"
  end,
}

-- Check all LSPs at once
function M.check_all()
  local results = {}
  local healthy = 0
  local total = 0

  for lsp_name, check_fn in pairs(health_checks) do
    total = total + 1
    local ok, message = check_fn()

    results[lsp_name] = {
      healthy = ok,
      message = message,
    }

    if ok then
      healthy = healthy + 1
    end
  end

  -- Generate report
  local report_lines = {
    string.format("LSP Health Report: %d/%d healthy", healthy, total),
    "",
  }

  for lsp_name, result in pairs(results) do
    local status_icon = result.healthy and icons.status.success or icons.status.error
    local line = string.format("%s %s: %s", status_icon, lsp_name, result.message)
    table.insert(report_lines, line)
  end

  return results, report_lines
end

-- Check single LSP
function M.check_lsp(lsp_name)
  local check_fn = health_checks[lsp_name]
  if not check_fn then
    return false, "Unknown LSP: " .. lsp_name
  end

  return check_fn()
end

-- Auto-fix for common issues
function M.auto_fix()
  local fixes_applied = {}

  -- 1. Check npm global path
  local npm_global = vim.fn.system("npm config get prefix 2>/dev/null"):gsub("%s+", "")
  if vim.v.shell_error == 0 and npm_global ~= "" then
    local npm_bin = npm_global .. "/bin"
    local path_env = vim.env.PATH or ""
    if not path_env:find(npm_bin, 1, true) then
      vim.env.PATH = npm_bin .. ":" .. path_env
      table.insert(fixes_applied, "npm global bin path added")
    end
  end

  -- 2. Check cargo bin path
  local cargo_bin = vim.fn.expand("~/.cargo/bin")
  if vim.fn.isdirectory(cargo_bin) == 1 then
    local path_env = vim.env.PATH or ""
    if not path_env:find(cargo_bin, 1, true) then
      vim.env.PATH = cargo_bin .. ":" .. path_env
      table.insert(fixes_applied, "cargo bin path added")
    end
  end

  return fixes_applied
end

return M
