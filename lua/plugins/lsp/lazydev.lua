-- lazydev.nvim: dynamic Lua library injection for lua_ls
-- Adds Neovim runtime + loaded plugins to lua_ls workspace.library on demand,
-- so vim.* / plugin APIs get correct signatures, hover docs, and diagnostics.

local ok, lazydev = pcall(require, "lazydev")
if not ok then
  return
end

lazydev.setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "wezterm-types",       mods = { "wezterm" } },
  },
  enabled = function(_)
    return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
  end,
})
