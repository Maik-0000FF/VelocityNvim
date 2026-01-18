-- ~/.config/VelocityNvim/lua/plugins/lualine.lua
-- Lualine Plugin Configuration

-- Load icons
local icons = require("core.icons")

-- PERFORMANCE: Cached LSP status with debouncing (avoids 100+ updates/sec during typing)
local lsp_status_cache = {
  text = "",
  last_bufnr = -1,
  last_update = 0,
}
local LSP_CACHE_TTL_MS = 500  -- Update at most every 500ms

local function get_lsp_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local now = vim.uv.now()

  -- Return cached value if still valid
  if bufnr == lsp_status_cache.last_bufnr and (now - lsp_status_cache.last_update) < LSP_CACHE_TTL_MS then
    return lsp_status_cache.text
  end

  -- Update cache
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local status = ""
  if #clients > 0 then
    -- Show first client name (most relevant)
    status = clients[1].name
    if #clients > 1 then
      status = status .. " +" .. (#clients - 1)
    end
  end

  lsp_status_cache.text = status
  lsp_status_cache.last_bufnr = bufnr
  lsp_status_cache.last_update = now

  return status
end

-- Re-enable statusline for lualine
vim.opt.laststatus = 3

-- Lualine Setup
require("lualine").setup({
  options = {
    theme = "tokyonight",
    component_separators = "",
    section_separators = {
      left = icons.lualine.section_separator_left,
      right = icons.lualine.section_separator_right,
    },
    globalstatus = true,
    disabled_filetypes = {
      statusline = { "dashboard", "alpha" },
      winbar = { "dashboard", "alpha", "neo-tree" },
    },
    ignore_focus = { "neo-tree" },
  },
  sections = {
    lualine_a = {
      {
        "mode",
        separator = {
          left = icons.lualine.section_separator_right,
        },
        right_padding = 2,
      },
    },
    lualine_b = {
      { "filename", path = 0 },
      {
        "branch",
        icon = icons.git.gitsymbol,
      },
      {
        "diff",
        symbols = {
          added = icons.git.addedsymbol .. " ",
          modified = icons.git.changesymbol .. " ",
          removed = icons.git.deletesymbol .. " ",
        },
        colored = true,
      },
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = {
          error = icons.diagnostics.error .. " ",
          warn = icons.diagnostics.warn .. " ",
          info = icons.diagnostics.info .. " ",
          hint = icons.diagnostics.hint .. " ",
        },
        colored = true,
        update_in_insert = false,
      },
    },
    lualine_c = {
      "%=", -- Balance left and right sections
    },
    lualine_x = {
      {
        get_lsp_status,
        icon = icons.lsp.code_action .. " ",
        cond = function() return get_lsp_status() ~= "" end,
      },
      { "filetype", colored = true, icon_only = false },
    },
    lualine_y = {
      "fileformat",
      "encoding",
      "progress",
    },
    lualine_z = {
      {
        "location",
        separator = {
          right = icons.lualine.section_separator_left,
        },
        left_padding = 2,
      },
    },
  },
  inactive_sections = {
    lualine_a = { "filename" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  tabline = {},
  extensions = { "neo-tree" },
})

