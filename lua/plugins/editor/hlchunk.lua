-- ~/.config/VelocityNvim/lua/plugins/hlchunk.lua
-- MINIMAL hlchunk config - NUR Standard-Funktionen + embedded icons

local ok, hlchunk = pcall(require, "hlchunk")
if not ok then
  return
end

-- Embedded icons (keine Abhängigkeit zu core.icons)
local hlchunk_icons = {
  horizontal_line = "─",
  vertical_line = "│",
  left_top = "╭",
  left_bottom = "╰",
  right_arrow = "─",
}

hlchunk.setup({
  chunk = {
    enable = true,
    use_treesitter = true,
    chars = hlchunk_icons,
    style = { { fg = "#00ffff" }, { fg = "#ff00ff" } }, -- Custom colors: Cyan + Magenta
    duration = 50, -- Keine Animation für instant highlighting
    delay = 150, -- Optimierte Verzögerung für responsive Navigation
    max_file_size = 1024 * 1024, -- Performance limit
    error_sign = true, -- Aktiviert: Farbumschlag bei Syntax-Fehlern (Cyan → Pink)
  },
  indent = {
    enable = false, -- Native leadmultispace übernimmt indent lines
  },
})