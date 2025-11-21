-- ~/.config/VelocityNvim/init.lua
-- Native Neovim Configuration Bootstrap

-- Track startup time for performance monitoring
vim.g.velocitynvim_start_time = vim.loop.hrtime()

-- Load core configuration
require("core")
