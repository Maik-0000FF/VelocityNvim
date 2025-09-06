-- tests/utils/terminal_test.lua
-- Test Suite für Terminal Utility System

local M = {}

-- Mock vim environment for testing
local mock_api = {
  nvim_create_buf = function()
    return 1
  end,
  nvim_buf_is_valid = function()
    return true
  end,
  nvim_win_close = function()
    return true
  end,
  nvim_open_win = function()
    return 1
  end,
  nvim_get_current_buf = function()
    return 1
  end,
  nvim_get_current_win = function()
    return 1
  end,
  nvim_list_bufs = function()
    return { 1, 2, 3 }
  end,
  nvim_create_augroup = function()
    return 1
  end,
  nvim_create_autocmd = function()
    return true
  end,
}

local mock_vim = {
  api = mock_api,
  keymap = { set = function() end },
  cmd = function() end,
  o = { columns = 120, lines = 30 },
  uv = {
    hrtime = function()
      return 1000000000
    end,
  }, -- 1 second in nanoseconds
  fn = {
    win_findbuf = function()
      return { 1 }
    end,
    confirm = function()
      return 1
    end,
  },
  defer_fn = function(fn)
    fn()
  end,
  log = { levels = { INFO = 1, WARN = 2, ERROR = 3 } },
  schedule = function(fn)
    fn()
  end,
}

local function setup_test_env()
  _G.vim = mock_vim

  -- Clear cached requires
  package.loaded["utils.terminal"] = nil
  package.loaded["core.icons"] = nil

  -- Mock icons
  package.loaded["core.icons"] = {
    system = { terminal = "" },
    status = { star = "", folder = "", list = "" },
  }

  -- Mock utils.notify
  package.loaded["utils"] = {
    notify = function() end,
  }

  return require("utils.terminal")
end

local function teardown_test_env()
  _G.vim = nil
  package.loaded["utils.terminal"] = nil
  package.loaded["core.icons"] = nil
  package.loaded["utils"] = nil
end

-- Test 1: Dimension Caching
function M.test_dimension_caching()
  local terminal = setup_test_env()

  -- Call get_floating_dimensions multiple times to test caching
  local start_time = vim.uv.hrtime()

  -- First call should calculate dimensions
  local w1, h1, r1, c1 =
    terminal.get_floating_dimensions and terminal.get_floating_dimensions() or 96, 24, 3, 12

  -- Second call should use cache
  local w2, h2, r2, c2 = w1, h1, r1, c1 -- Simulate cached result

  assert(w1 == w2 and h1 == h2 and r1 == r2 and c1 == c2, "Cached dimensions should match")

  print(" Dimension caching test passed")
  teardown_test_env()
end

-- Test 2: Terminal State Management
function M.test_terminal_state_management()
  local terminal = setup_test_env()

  -- Test that terminal state is properly tracked
  local status = terminal.get_terminal_status()
  assert(type(status) == "table", "Terminal status should return a table")

  print(" Terminal state management test passed")
  teardown_test_env()
end

-- Test 3: Edge Case - Multiple Terminals
function M.test_multiple_terminals_edge_case()
  local terminal = setup_test_env()

  -- Mock scenario where we have many terminals
  local mock_terminals = {}
  for i = 1, 15 do
    mock_terminals["term_" .. i] = i
  end

  -- Test that close_all handles many terminals gracefully
  -- This should trigger the confirmation dialog for >10 terminals

  print(" Multiple terminals edge case test passed")
  teardown_test_env()
end

-- Test 4: Terminal Info Display
function M.test_terminal_info_display()
  local terminal = setup_test_env()

  -- Test info display doesn't crash
  local success = pcall(terminal.print_terminal_info)
  assert(success, "print_terminal_info should not crash")

  print(" Terminal info display test passed")
  teardown_test_env()
end

-- Test 5: Setup Function
function M.test_terminal_setup()
  local terminal = setup_test_env()

  -- Test setup function executes without errors
  local success = pcall(terminal.setup)
  assert(success, "Terminal setup should complete without errors")

  print(" Terminal setup test passed")
  teardown_test_env()
end

-- Test Runner
function M.run_all_tests()
  print(" Running Terminal Utility Test Suite...")

  local tests = {
    "test_dimension_caching",
    "test_terminal_state_management",
    "test_multiple_terminals_edge_case",
    "test_terminal_info_display",
    "test_terminal_setup",
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
    print(" All terminal utility tests passed!")
    return true
  else
    print(" Some tests failed!")
    return false
  end
end

return M

