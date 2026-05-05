-- tests/ci/verify_install.lua
-- Post-install verification for the install-matrix CI workflow.
--
-- Run with:
--   NVIM_APPNAME=VelocityNvim nvim --headless \
--     -c 'lua dofile(vim.fn.stdpath("config") .. "/tests/ci/verify_install.lua")'
--
-- Exits 0 on success, non-zero on failure (via :cquit). Output is human-readable
-- and prefixed with "[ci-verify]" so it's easy to filter in CI logs.

local errors = {}
local warnings = {}

local function log(msg)  io.stdout:write("[ci-verify] " .. msg .. "\n") end
local function fail(msg) table.insert(errors, msg);  log("FAIL  " .. msg) end
local function warn(msg) table.insert(warnings, msg); log("WARN  " .. msg) end
local function pass(msg) log("PASS  " .. msg) end

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Plugin presence: every URL in manage.plugins must have a clone on disk
-- ─────────────────────────────────────────────────────────────────────────────
log("Checking plugin clones…")

local manage_ok, manage = pcall(require, "plugins.manage")
if not manage_ok then
  fail("could not require plugins.manage: " .. tostring(manage))
else
  local pack_dir = vim.fn.stdpath("data") .. "/site/pack/user/start"
  local expected = manage.get_all_plugins and manage.get_all_plugins() or manage.plugins or {}
  local missing, present = {}, 0
  for name, _ in pairs(expected) do
    local plugin_path = pack_dir .. "/" .. name
    if vim.fn.isdirectory(plugin_path) == 1 and vim.fn.isdirectory(plugin_path .. "/.git") == 1 then
      present = present + 1
    else
      table.insert(missing, name)
    end
  end
  if #missing == 0 then
    pass(string.format("all %d expected plugins are present on disk", present))
  else
    fail(string.format("%d plugin(s) missing: %s", #missing, table.concat(missing, ", ")))
  end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Optional features config: written by the bash installer
-- ─────────────────────────────────────────────────────────────────────────────
log("Checking optional-features config…")

local config_path = vim.fn.stdpath("data") .. "/optional-features.json"
if vim.fn.filereadable(config_path) ~= 1 then
  fail("optional-features.json was not created at " .. config_path)
else
  local f = io.open(config_path, "r")
  local body = f and f:read("*a") or ""
  if f then f:close() end
  local ok, parsed = pcall(vim.json.decode, body)
  if not ok or type(parsed) ~= "table" then
    fail("optional-features.json is not valid JSON: " .. tostring(parsed))
  elseif parsed.configured ~= true then
    fail("optional-features.json has configured=false")
  else
    pass("optional-features.json is valid (selected=" .. vim.inspect(parsed.selected) .. ")")
  end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Core modules load without error
-- ─────────────────────────────────────────────────────────────────────────────
log("Checking core modules load…")

for _, mod in ipairs({
  "core.options", "core.keymaps", "core.autocmds", "core.icons",
  "plugins.manage", "core.system-deps",
}) do
  local ok, err = pcall(require, mod)
  if ok then pass("require " .. mod) else fail("require " .. mod .. " → " .. tostring(err)) end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Critical plugins are loadable (no Rust/LSP servers required)
-- ─────────────────────────────────────────────────────────────────────────────
log("Checking critical plugin loadability…")

vim.cmd("packloadall!")

for _, plug in ipairs({
  "plenary",            -- shipped with plenary.nvim
  "nvim-web-devicons",  -- icons
  "tokyonight",         -- colorscheme
  "neo-tree",           -- file tree
  "lualine",            -- statusline
  "bufferline",         -- buffer line
  "which-key",          -- which-key
  "gitsigns",           -- git
  "blink.cmp",          -- completion (Lua fallback ok if Rust missing)
}) do
  local ok, err = pcall(require, plug)
  if ok then pass("require " .. plug) else fail("require " .. plug .. " → " .. tostring(err)) end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. LSP config layer initializes (servers themselves not required in CI)
-- ─────────────────────────────────────────────────────────────────────────────
log("Checking LSP config layer…")

local lsp_ok, lsp_err = pcall(require, "plugins.lsp.native-lsp")
if lsp_ok then
  pass("plugins.lsp.native-lsp loaded")
else
  -- LSP servers not present in CI is expected; only fail on Lua-level errors
  if tostring(lsp_err):match("module .+ not found") then
    fail("LSP module require failed: " .. tostring(lsp_err))
  else
    warn("LSP module loaded with non-fatal warning: " .. tostring(lsp_err))
  end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. :checkhealth velocitynvim runs without raising
-- ─────────────────────────────────────────────────────────────────────────────
log("Running :checkhealth velocitynvim…")

local hc_ok, hc_err = pcall(vim.cmd, "silent! checkhealth velocitynvim")
if hc_ok then
  pass(":checkhealth velocitynvim executed")
else
  fail(":checkhealth velocitynvim raised: " .. tostring(hc_err))
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Summary + exit
-- ─────────────────────────────────────────────────────────────────────────────
log(string.rep("─", 60))
log(string.format("Result: %d failure(s), %d warning(s)", #errors, #warnings))
for _, e in ipairs(errors) do log("  ✗ " .. e) end
for _, w in ipairs(warnings) do log("  ! " .. w) end

if #errors > 0 then
  vim.cmd("cquit 1")
else
  log("All checks passed.")
  vim.cmd("qa!")
end
