-- ~/.config/VelocityNvim/lua/utils/terminal.lua
-- Native terminal functionality without external plugins (VelocityNvim optimized)

local M = {}

-- Compatibility layer
local uv = vim.uv or vim.loop
local api = vim.api
local icons = require("core.icons")

-- Stores active terminal buffers
local terminals = {
  horizontal = nil,
  vertical = nil,
  floating = nil,
}

-- Cached window dimensions for floating terminal (performance optimization)
local cached_dimensions = {
  width = nil,
  height = nil,
  row = nil,
  col = nil,
  last_update = 0
}

-- Cache TTL in milliseconds
local DIMENSION_CACHE_TTL = 1000

-- PERFORMANCE OPTIMIZATION: Cache terminal dimensions as vim.o.* accesses are relatively expensive
-- Noticeable improvement with frequent terminal toggle (Alt+i), especially on older systems
local function get_floating_dimensions()
  local now = uv.hrtime() / 1000000  -- High-resolution timer for precise TTL control

  -- CACHE-HIT: Dimensions are still current (TTL not expired)
  if cached_dimensions.width and (now - cached_dimensions.last_update) < DIMENSION_CACHE_TTL then
    return cached_dimensions.width, cached_dimensions.height, cached_dimensions.row, cached_dimensions.col
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Update cache
  cached_dimensions = {
    width = width,
    height = height,
    row = row,
    col = col,
    last_update = now
  }

  return width, height, row, col
end

-- Performance-optimized terminal configuration
local function configure_terminal_buffer(bufnr, win)
  -- Buffer options (batch-optimized)
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].filetype = "terminal"

  -- Window options (only if window is provided)
  if win then
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
  end
end

--- Toggle horizontal terminal
function M.toggle_horizontal_terminal()
  if terminals.horizontal and api.nvim_buf_is_valid(terminals.horizontal) then
    -- Terminal is open - find and close window
    local wins = vim.fn.win_findbuf(terminals.horizontal)
    for _, win in ipairs(wins) do
      api.nvim_win_close(win, false)
    end
    terminals.horizontal = nil
  else
    -- Open terminal
    vim.api.nvim_command("botright 12split")
    vim.api.nvim_command("terminal")

    local buf = api.nvim_get_current_buf()
    local win = api.nvim_get_current_win()

    terminals.horizontal = buf
    configure_terminal_buffer(buf, win)

    -- Start in terminal mode
    vim.api.nvim_command("startinsert")
  end
end

--- Toggle vertical terminal
function M.toggle_vertical_terminal()
  if terminals.vertical and api.nvim_buf_is_valid(terminals.vertical) then
    -- Terminal is open - find and close window
    local wins = vim.fn.win_findbuf(terminals.vertical)
    for _, win in ipairs(wins) do
      api.nvim_win_close(win, false)
    end
    terminals.vertical = nil
  else
    -- Open terminal
    vim.api.nvim_command("vertical botright 80vsplit")
    vim.api.nvim_command("terminal")

    local buf = api.nvim_get_current_buf()
    local win = api.nvim_get_current_win()

    terminals.vertical = buf
    configure_terminal_buffer(buf, win)

    -- Start in terminal mode
    vim.api.nvim_command("startinsert")
  end
end

--- Toggle floating terminal (with caching and optimized styling)
function M.toggle_floating_terminal()
  if terminals.floating and api.nvim_buf_is_valid(terminals.floating) then
    -- Terminal is open - find and close window
    local wins = vim.fn.win_findbuf(terminals.floating)
    for _, win in ipairs(wins) do
      api.nvim_win_close(win, false)
    end
    terminals.floating = nil
  else
    -- Open terminal
    local buf = api.nvim_create_buf(false, true)
    local width, height, row, col = get_floating_dimensions()

    local win = api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      title = " " .. icons.misc.terminal .. " Terminal ",
      title_pos = "center",
      zindex = 50,
    })

    -- Create terminal
    vim.api.nvim_command("terminal")
    terminals.floating = buf
    configure_terminal_buffer(buf, win)

    -- Start in terminal mode
    vim.api.nvim_command("startinsert")
  end
end

--- Close all terminal instances with extended edge cases
function M.close_all_terminals()
  local closed_count = 0
  local failed_count = 0

  -- EDGE CASE: More than 10 terminals could pose performance problem
  local terminal_count = 0
  for _ in pairs(terminals) do terminal_count = terminal_count + 1 end

  if terminal_count > 10 then
    local choice = vim.fn.confirm(
      string.format("Warning: %d terminal instances found. Close all?", terminal_count),
      "&Yes\n&No\n&Active only",
      2
    )
    if choice == 2 then return end
    if choice == 3 then
      -- Only close actually visible terminals
      for term_type, buf in pairs(terminals) do
        if buf and api.nvim_buf_is_valid(buf) then
          local wins = vim.fn.win_findbuf(buf)
          if #wins > 0 then
            for _, win in ipairs(wins) do
              local success = pcall(api.nvim_win_close, win, false)
              if success then
                closed_count = closed_count + 1
              else
                failed_count = failed_count + 1
              end
            end
            terminals[term_type] = nil
          end
        end
      end
      local utils = require("utils")
      utils.notify(string.format("%s %d active terminal(s) closed", icons.misc.terminal, closed_count), vim.log.levels.INFO)
      return
    end
  end

  for term_type, buf in pairs(terminals) do
    if buf and api.nvim_buf_is_valid(buf) then
      -- EDGE CASE: Terminal could be in uncloseable window
      local wins = vim.fn.win_findbuf(buf)
      for _, win in ipairs(wins) do
        local success = pcall(api.nvim_win_close, win, false)
        if not success then
          -- Force-close if normal close fails
          pcall(api.nvim_buf_delete, buf, { force = true })
          failed_count = failed_count + 1
        end
      end
      terminals[term_type] = nil
      closed_count = closed_count + 1
    else
      -- EDGE CASE: Clean up stale buffer references
      terminals[term_type] = nil
    end
  end

  if closed_count > 0 or failed_count > 0 then
    local utils = require("utils")
    local message = string.format("%s %d terminal(s) closed", icons.misc.terminal, closed_count)
    if failed_count > 0 then
      message = message .. string.format(" (%d force-closed)", failed_count)
    end
    utils.notify(message, vim.log.levels.INFO)
  end
end

--- Show terminal status
function M.get_terminal_status()
  local status = {}

  for term_type, buf in pairs(terminals) do
    if buf and api.nvim_buf_is_valid(buf) then
      local wins = vim.fn.win_findbuf(buf)
      table.insert(status, {
        type = term_type,
        buffer = buf,
        windows = #wins,
        icon = term_type == "floating" and icons.misc.terminal or
               term_type == "horizontal" and "─" or "│"
      })
    end
  end

  return status
end

--- Print terminal information
function M.print_terminal_info()
  local status = M.get_terminal_status()

  print(icons.misc.terminal .. " Terminal Status:")

  if #status == 0 then
    print("  " .. icons.status.info .. " No active terminals")
  else
    for _, term in ipairs(status) do
      print(string.format("  %s %s: Buffer %d (%d Window%s)",
        term.icon, term.type:gsub("^%l", string.upper), term.buffer,
        term.windows, term.windows == 1 and "" or "s"))
    end
  end

  -- Show keybindings
  print("\n" .. icons.status.list .. " Available commands:")
  print("  Alt+- - Horizontal terminal")
  print("  Alt+\\ - Vertical terminal")
  print("  Alt+i - Floating terminal")
  print("  <leader>tf - Floating terminal")
  print("  <leader>tc - Close all terminals")
end

--- Setup function with optimized autocommands and which-key integration
function M.setup()
  -- Terminal-specific autocommands (grouped for performance)
  local terminal_group = vim.api.nvim_create_augroup("VelocityTerminal", { clear = true })

  -- Automatically switch to terminal mode
  vim.api.nvim_create_autocmd("TermOpen", {
    group = terminal_group,
    desc = "Configure terminal on open",
    callback = function(ev)
      local bufnr = ev.buf

      -- Buffer configuration
      configure_terminal_buffer(bufnr)

      -- Start in insert mode
      vim.schedule(function()
        if api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_command("startinsert")
        end
      end)
    end,
  })

  -- Auto-Insert beim Betreten von Terminal-Buffern
  vim.api.nvim_create_autocmd("BufEnter", {
    group = terminal_group,
    pattern = "term://*",
    desc = "Auto insert in terminal buffers",
    callback = function()
      if vim.bo.buftype == "terminal" then
        vim.api.nvim_command("startinsert")
      end
    end,
  })

  -- Invalidate cache on resize
  vim.api.nvim_create_autocmd("VimResized", {
    group = terminal_group,
    desc = "Invalidate dimension cache on resize",
    callback = function()
      cached_dimensions.last_update = 0
    end,
  })

  -- Set up keymaps
  local keymap_opts = { silent = true, noremap = true }

  -- Alt key combinations (your desired keybindings)
  vim.keymap.set("n", "<A-->", M.toggle_horizontal_terminal,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal horizontal" }))
  vim.keymap.set("n", "<A-\\>", M.toggle_vertical_terminal,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal vertical" }))

  -- Floating terminal with Alt+i (most important terminal function)
  vim.keymap.set("n", "<A-i>", M.toggle_floating_terminal,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal floating" }))

  -- Leader-based keymaps for which-key grouping
  vim.keymap.set("n", "<leader>tf", M.toggle_floating_terminal,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal floating" }))
  vim.keymap.set("n", "<leader>tc", M.close_all_terminals,
    vim.tbl_extend("force", keymap_opts, { desc = "Close all terminals" }))
  vim.keymap.set("n", "<leader>ti", M.print_terminal_info,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal info" }))

  -- Terminal mode keymaps
  vim.keymap.set("t", "jk", [[<C-\><C-n>]],
    vim.tbl_extend("force", keymap_opts, { desc = "Exit terminal mode" }))
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]],
    vim.tbl_extend("force", keymap_opts, { desc = "Exit terminal mode" }))

  -- Window navigation from terminal
  vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-W>h]], { desc = "Left" })
  vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-W>j]], { desc = "Down" })
  vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-W>k]], { desc = "Up" })
  vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-W>l]], { desc = "Right" })

  -- Which-key registration (deferred for availability)
  vim.defer_fn(function()
    local ok, which_key = pcall(require, "which-key")
    if ok then
      which_key.add({
        { "<leader>t", group = icons.misc.terminal .. " Terminal" },
        { "<leader>tf", desc = "Floating Terminal" },
        { "<leader>tc", desc = "Close all" },
        { "<leader>ti", desc = "Terminal Info" },
      })
    end
  end, 100)
end

return M