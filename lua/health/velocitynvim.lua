-- ~/.config/VelocityNvim/lua/health/velocitynvim.lua
-- Health check registration for VelocityNvim Configuration
-- This file is required for `:checkhealth velocitynvim` to work

local M = {}

-- Import the actual health check logic from core/health.lua
local core_health = require("core.health")

-- Register the health check function
-- This is the function that gets called by `:checkhealth velocitynvim`
function M.check()
  core_health.check()
end

return M