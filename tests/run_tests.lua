-- tests/run_tests.lua
-- Main Test Runner für VelocityNvim

local M = {}

-- Test-Suite Registry
local test_suites = {
  ["core.version"] = "tests.core.version_test",
  ["utils.terminal"] = "tests.utils.terminal_test",
}

-- Performance Benchmarks
local performance_thresholds = {
  version_parsing = 5, -- max 5ms
  terminal_creation = 50, -- max 50ms
  plugin_loading = 100, -- max 100ms
}

-- Test-Framework Utilities
local function measure_time(fn, name)
  local start_time = os.clock()
  local result = fn()
  local end_time = os.clock()
  local elapsed_ms = (end_time - start_time) * 1000

  return result, elapsed_ms
end

local function run_performance_test(name, fn, threshold_ms)
  local result, elapsed_ms = measure_time(fn, name)
  local passed = elapsed_ms <= threshold_ms

  local status = passed and "✓" or "✗"
  print(string.format("%s %s: %.2fms (threshold: %dms)", status, name, elapsed_ms, threshold_ms))

  return passed, elapsed_ms
end

-- Health Check Integration (using isolated testing)
function M.health_check()
  local isolated_runner = require("tests.isolated_test_runner")
  return isolated_runner.health_check()
end

-- Unit Test Runner (using isolated testing)
function M.run_unit_tests()
  local isolated_runner = require("tests.isolated_test_runner")
  return isolated_runner.run_unit_tests()
end

-- Performance Test Runner (using isolated testing)
function M.run_performance_tests()
  local isolated_runner = require("tests.isolated_test_runner")
  return isolated_runner.run_performance_tests()
end

-- Integration Test Runner (using isolated testing)
function M.run_integration_tests()
  local isolated_runner = require("tests.isolated_test_runner")
  return isolated_runner.run_integration_tests()
end

-- Main Test Runner (using isolated testing)
function M.run_all()
  local isolated_runner = require("tests.isolated_test_runner")
  return isolated_runner.run_all()
end

-- Neovim Command Integration
vim.api.nvim_create_user_command("VelocityTest", function(opts)
  local test_type = opts.args or "all"

  if test_type == "health" then
    M.health_check()
  elseif test_type == "unit" then
    M.run_unit_tests()
  elseif test_type == "performance" then
    M.run_performance_tests()
  elseif test_type == "integration" then
    M.run_integration_tests()
  else
    M.run_all()
  end
end, {
  nargs = "?",
  complete = function()
    return { "all", "health", "unit", "performance", "integration" }
  end,
  desc = "Run VelocityNvim test suite",
})

return M
