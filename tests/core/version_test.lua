-- tests/core/version_test.lua
-- Test Suite für Version Management System

local M = {}

-- Mock vim environment for testing
local mock_vim = {
  log = { levels = { INFO = 1, WARN = 2, ERROR = 3 } },
  fn = {
    stdpath = function()
      return "/tmp/velocitynvim_test"
    end,
    filereadable = function()
      return 0
    end,
    readfile = function()
      return {}
    end,
    writefile = function()
      return true
    end,
  },
  notify = function() end,
  json = {
    encode = function(t)
      return require("cjson").encode(t)
    end,
    decode = function(s)
      return require("cjson").decode(s)
    end,
  },
  version = function()
    return { major = 0, minor = 11, patch = 0 }
  end,
  api = {
    nvim__api_info = function()
      return { api_level = 12 }
    end,
  },
}

local function setup_test_env()
  -- Temporarily replace global vim
  _G.vim = mock_vim

  -- Clear any cached requires
  package.loaded["core.version"] = nil
  package.loaded["core.icons"] = nil

  return require("core.version")
end

local function teardown_test_env()
  -- Restore original vim (if any)
  _G.vim = nil
end

-- Test 1: Version Parsing
function M.test_version_parsing()
  local version = setup_test_env()

  -- Test normal version parsing
  local v1 = { major = 2, minor = 0, patch = 0, string = "2.0.0" }
  assert(version.version.major == v1.major, "Major version mismatch")
  assert(version.version.minor == v1.minor, "Minor version mismatch")
  assert(version.version.patch == v1.patch, "Patch version mismatch")

  print(" Version parsing test passed")
  teardown_test_env()
end

-- Test 2: Version Comparison
function M.test_version_comparison()
  local version = setup_test_env()

  -- Test version comparisons
  assert(version.compare_versions("2.0.0", "1.0.0") > 0, "Version comparison failed: 2.0.0 > 1.0.0")
  assert(version.compare_versions("1.0.0", "2.0.0") < 0, "Version comparison failed: 1.0.0 < 2.0.0")
  assert(
    version.compare_versions("1.0.0", "1.0.0") == 0,
    "Version comparison failed: 1.0.0 == 1.0.0"
  )

  -- Test version compatibility
  assert(version.is_version_newer("2.0.0", "1.0.0"), "Version newer check failed")
  assert(not version.is_version_newer("1.0.0", "2.0.0"), "Version newer check failed")

  print(" Version comparison test passed")
  teardown_test_env()
end

-- Test 3: Neovim Compatibility
function M.test_neovim_compatibility()
  local version = setup_test_env()

  local compat, msg = version.check_nvim_compatibility()
  assert(compat, "Neovim compatibility check should pass for 0.11.0")
  assert(msg == "compatible", "Compatibility message should be 'compatible'")

  print(" Neovim compatibility test passed")
  teardown_test_env()
end

-- Test 4: Version History
function M.test_version_history()
  local version = setup_test_env()

  assert(#version.version_history >= 3, "Version history should have at least 3 entries")

  local latest = version.get_latest_version()
  assert(latest.version == "2.0.0", "Latest version should be 2.0.0")
  assert(type(latest.changes) == "table", "Latest version should have changes table")

  print(" Version history test passed")
  teardown_test_env()
end

-- Test 5: Migration System
function M.test_migration_system()
  local version = setup_test_env()

  local migration_executed = false
  version.add_migration("1.0.0", "2.0.0", function()
    migration_executed = true
  end)

  local results = version.run_migrations("1.0.0", "2.0.0")
  assert(#results >= 1, "Migration should have been executed")
  assert(migration_executed, "Migration function should have been called")

  print(" Migration system test passed")
  teardown_test_env()
end

-- Test Runner
function M.run_all_tests()
  print(" Running Version System Test Suite...")

  local tests = {
    "test_version_parsing",
    "test_version_comparison",
    "test_neovim_compatibility",
    "test_version_history",
    "test_migration_system",
  }

  local passed = 0
  local failed = 0

  for _, test_name in ipairs(tests) do
    local success, err = pcall(M[test_name])
    if success then
      passed = passed + 1
    else
      failed = failed + 1
      print(" " .. test_name .. " FAILED: " .. tostring(err))
    end
  end

  print(string.format("\n Test Results: %d passed, %d failed", passed, failed))

  if failed == 0 then
    print(" All version system tests passed!")
    return true
  else
    print(" Some tests failed!")
    return false
  end
end

return M

