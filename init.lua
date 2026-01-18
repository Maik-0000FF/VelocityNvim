-- ~/.config/VelocityNvim/init.lua
-- Native Neovim Configuration Bootstrap

-- Track startup time for performance monitoring
vim.g.velocitynvim_start_time = vim.uv.hrtime()

-- Load core configuration
require("core")
