-- tests/run_tests.lua
-- Main test runner for VelocityNvim

local M = {}

-- Note: Test-Suite Registry and Performance Benchmarks are reserved for future use
-- when direct test execution is needed. Currently delegating to isolated_test_runner.

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
