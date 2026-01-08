-- ~/.config/VelocityNvim/lua/plugins/hlchunk.lua
-- MINIMAL hlchunk config - standard features + embedded icons

local ok, hlchunk = pcall(require, "hlchunk")
if not ok then
  return
end

-- Embedded icons (no dependency on core.icons)
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
    duration = 50, -- No animation for instant highlighting
    delay = 150, -- Optimized delay for responsive navigation
    max_file_size = 1024 * 1024, -- Performance limit
    error_sign = true, -- Color change on syntax errors (Cyan → Pink)
  },
  indent = {
    enable = false, -- Native leadmultispace handles indent lines
  },
})
