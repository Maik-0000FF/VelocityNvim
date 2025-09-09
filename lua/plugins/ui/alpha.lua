-- ~/.config/VelocityNvim/lua/plugins/alpha.lua
-- Alpha Dashboard Konfiguration

local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
local icons = require("core.icons")

-- Header aus icons.lua verwenden
dashboard.section.header.val = icons.alpha.header

-- Menü-Buttons
dashboard.section.buttons.val = {
  dashboard.button("e", icons.status.file .. " New file", "<cmd>ene <BAR> startinsert <CR>"),
  dashboard.button("f", icons.status.find_file .. " Find file", "<cmd>Neotree reveal<CR>"),
  dashboard.button("r", icons.status.recent_file .. " Recent files", "<cmd>FzfLua oldfiles<CR>"),
  dashboard.button("c", icons.status.gear .. " Configuration", "<cmd>e $MYVIMRC<CR>"),
  dashboard.button("I", icons.status.info .. " Info & Version", "<cmd>VelocityInfo<CR>"),
  dashboard.button("h", icons.status.health .. " Health Check", "<cmd>checkhealth<CR>"),
  dashboard.button("q", icons.status.quit .. " Quit", "<cmd>qa<CR>"),
}

-- Dynamischer Footer mit Version-Info
local function get_footer()
  local version = require("core.version")
  local nvim_ver = version.get_nvim_version()
  local change_type = version.check_version_change()

  -- Plugin-Anzahl ermitteln
  local plugin_count = 0
  local ok, manage = pcall(require, "plugins.manage")
  if ok and manage.plugins then
    plugin_count = vim.tbl_count(manage.plugins)
  end

  -- LSP-Client Anzahl
  local lsp_count = #vim.lsp.get_clients()

  local footer = {
    "                                   ",
    "    " .. icons.status.rocket .. " " .. version.config_name .. " v" .. version.config_version,
    "    " .. icons.status.update .. " Updated: " .. version.last_updated,
    "    " .. icons.status.neovim .. " Neovim: " .. nvim_ver.string,
    "    " .. icons.misc.plugin .. " Plugins: " .. plugin_count .. " configured",
    "    " .. icons.status.gear .. " LSP: " .. lsp_count .. " active clients",
    "                                   ",
  }

  -- Status-Zeile basierend auf Version-Change
  local status_line = ""
  if change_type == "fresh_install" then
    status_line = "    " .. icons.status.fresh .. " Welcome to your fresh installation!"
  elseif change_type == "upgrade" then
    local stored = version.get_stored_version()
    status_line = "    "
      .. icons.status.trend_up
      .. " Upgraded from v"
      .. (stored and stored.version or "unknown")
  elseif change_type == "downgrade" then
    local stored = version.get_stored_version()
    status_line = "    "
      .. icons.status.trend_down
      .. " Downgraded from v"
      .. (stored and stored.version or "unknown")
  else
    status_line = "    " .. icons.status.current .. " Configuration up to date"
  end

  table.insert(footer, status_line)
  table.insert(footer, "                                   ")
  table.insert(footer, "    Powered by native vim.pack     ")

  return footer
end

dashboard.section.footer.val = get_footer()

-- Layout konfigurieren
dashboard.config.layout = {
  { type = "padding", val = 2 }, -- Standard-padding (bufferline lädt bereits vor alpha)
  dashboard.section.header,
  { type = "padding", val = 2 },
  dashboard.section.buttons,
  { type = "padding", val = 1 },
  dashboard.section.footer,
}

-- Dashboard aktivieren
alpha.setup(dashboard.config)
