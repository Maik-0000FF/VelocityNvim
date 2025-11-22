-- ~/.config/VelocityNvim/lua/plugins/alpha.lua
-- Alpha Dashboard Configuration

local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
local icons = require("core.icons")

-- Use header from core.icons
dashboard.section.header.val = icons.alpha.header

-- Menu buttons
dashboard.section.buttons.val = {
  dashboard.button("e", icons.status.file .. " New file", "<cmd>ene <BAR> startinsert <CR>"),
  dashboard.button("f", icons.status.find_file .. " Find file", "<cmd>FzfLua files<CR>"),
  dashboard.button("t", icons.misc.folder .. " Neo-tree", "<cmd>Neotree reveal<CR>"),
  dashboard.button("c", icons.status.gear .. " Configuration", "<cmd>e $MYVIMRC<CR>"),
  dashboard.button("I", icons.status.info .. " Info & Version", "<cmd>VelocityInfo<CR>"),
  dashboard.button("b", icons.performance.benchmark .. " Startup Benchmark", "<cmd>StartupTime<CR>"),
  dashboard.button("h", icons.status.health .. " Health Check", "<cmd>checkhealth<CR>"),
  dashboard.button("q", icons.status.quit .. " Quit", "<cmd>qa<CR>"),
}

-- Dynamic footer with system info
local function get_footer()
  -- Neovim version
  local nvim_ver = vim.version()
  local nvim_version_string = string.format("%d.%d.%d", nvim_ver.major, nvim_ver.minor, nvim_ver.patch)

  -- Determine plugin count
  local plugin_count = 0
  local ok, manage = pcall(require, "plugins.manage")
  if ok and manage.plugins then
    plugin_count = vim.tbl_count(manage.plugins)
  end

  -- Calculate native startup time (from init.lua start to now)
  local startup_time = "N/A"
  if vim.g.velocitynvim_start_time then
    local elapsed_ns = vim.loop.hrtime() - vim.g.velocitynvim_start_time
    local elapsed_ms = elapsed_ns / 1000000
    startup_time = string.format("%.2fms", elapsed_ms)
  end

  local footer = {
    "                                   ",
    "    " .. icons.status.rocket .. " VelocityNvim Native Configuration",
    "    " .. icons.status.neovim .. " Neovim: " .. nvim_version_string,
    "    " .. icons.misc.plugin .. " Plugins: " .. plugin_count .. " configured",
    "    " .. icons.performance.fast .. " Startup: " .. startup_time,
    "                                   ",
    "    Powered by native vim.pack     ",
  }

  return footer
end

dashboard.section.footer.val = get_footer()

-- Configure layout
dashboard.config.layout = {
  { type = "padding", val = 2 }, -- Standard padding (bufferline loads before alpha)
  dashboard.section.header,
  { type = "padding", val = 2 },
  dashboard.section.buttons,
  { type = "padding", val = 1 },
  dashboard.section.footer,
}

-- Activate dashboard
alpha.setup(dashboard.config)