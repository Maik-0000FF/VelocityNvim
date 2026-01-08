-- ~/.config/VelocityNvim/lua/utils/latex-performance.lua
-- LaTeX/Typst live preview with robust PDF viewer reload
-- Optimized: Cached platform detection, single icon load, async builds
-- Shell-independent: Works with fish, zsh, bash, and all POSIX shells

local M = {}

-- Cache platform detection (called once at load time)
local IS_MACOS = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1

-- Floating window for compiler errors
local error_buf = nil
local error_win = nil

-- Close error window
function M.close_error_window()
  if error_win and vim.api.nvim_win_is_valid(error_win) then
    vim.api.nvim_win_close(error_win, true)
  end
  if error_buf and vim.api.nvim_buf_is_valid(error_buf) then
    vim.api.nvim_buf_delete(error_buf, { force = true })
  end
  error_win = nil
  error_buf = nil
end

-- Show compiler output in floating window
function M.show_error_window(title, lines, is_error)
  -- Close existing window
  M.close_error_window()

  -- Filter empty lines at end, keep content
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end

  if #lines == 0 then
    return
  end

  -- Add title
  local content = { title, string.rep("─", #title), "" }
  for _, line in ipairs(lines) do
    table.insert(content, line)
  end

  -- Calculate window size
  local max_width = 80
  local width = 0
  for _, line in ipairs(content) do
    width = math.max(width, #line)
  end
  width = math.min(width + 2, max_width)
  local height = math.min(#content, 20)

  -- Create buffer
  error_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(error_buf, 0, -1, false, content)
  vim.bo[error_buf].modifiable = false
  vim.bo[error_buf].buftype = "nofile"
  vim.bo[error_buf].filetype = "typst-errors"

  -- Window position (centered)
  local ui = vim.api.nvim_list_uis()[1]
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((ui.width - width) / 2),
    row = math.floor((ui.height - height) / 2),
    style = "minimal",
    border = "rounded",
    title = is_error and " Compilation Error " or " Compilation Output ",
    title_pos = "center",
  }

  -- Open window WITH focus so user can yank errors
  error_win = vim.api.nvim_open_win(error_buf, true, win_opts)

  -- Make buffer readable but not modifiable (allows yanking)
  vim.bo[error_buf].modifiable = false
  vim.bo[error_buf].readonly = true

  -- Highlight title
  vim.api.nvim_buf_add_highlight(error_buf, -1, is_error and "ErrorMsg" or "WarningMsg", 0, 0, -1)
  vim.api.nvim_buf_add_highlight(error_buf, -1, "Comment", 1, 0, -1)

  -- Highlight error lines
  for i, line in ipairs(content) do
    if line:match("^error:") then
      vim.api.nvim_buf_add_highlight(error_buf, -1, "ErrorMsg", i - 1, 0, -1)
    elseif line:match("^warning:") then
      vim.api.nvim_buf_add_highlight(error_buf, -1, "WarningMsg", i - 1, 0, -1)
    elseif line:match("^%s*┌") or line:match("^%s*│") or line:match("^%s*└") then
      vim.api.nvim_buf_add_highlight(error_buf, -1, "Comment", i - 1, 0, -1)
    end
  end

  -- Keymap to close with q
  vim.keymap.set("n", "q", M.close_error_window, { buffer = error_buf, silent = true, desc = "Close error window" })

  -- Yank to system clipboard by default in this buffer
  vim.keymap.set("n", "y", '"+y', { buffer = error_buf, silent = true, desc = "Yank to clipboard" })
  vim.keymap.set("n", "yy", '"+yy', { buffer = error_buf, silent = true, desc = "Yank line to clipboard" })
  vim.keymap.set("v", "y", '"+y', { buffer = error_buf, silent = true, desc = "Yank selection to clipboard" })
  vim.keymap.set("n", "Y", '"+y$', { buffer = error_buf, silent = true, desc = "Yank to end to clipboard" })
end

-- Shell-independent command execution (works with fish, zsh, bash, etc.)
-- Wraps commands in /bin/sh -c to ensure POSIX compatibility
local function sh(cmd)
  return "/bin/sh -c " .. vim.fn.shellescape(cmd)
end

-- Cache icons module (lazy-loaded once)
local _icons
local function get_icons()
  if not _icons then
    local ok, icons = pcall(require, "core.icons")
    _icons = ok and icons or { status = { success = "[OK]", error = "[ERR]", sync = "[..]", info = "[i]", warning = "[!]", search = "[?]" }, misc = { gear = "[*]" }, lsp = { text = "[T]" } }
  end
  return _icons
end

-- Cache tool availability (lazy-loaded once per session)
local _tool_cache = {}
local function is_tool_available(tool)
  if _tool_cache[tool] == nil then
    if tool == "skim" then
      _tool_cache[tool] = IS_MACOS and vim.fn.isdirectory("/Applications/Skim.app") == 1
    else
      _tool_cache[tool] = vim.fn.executable(tool) == 1
    end
  end
  return _tool_cache[tool]
end

-- Document tools
M.latex_tools = {
  pdflatex = "pdflatex",
  typst = "typst",
  zathura = "zathura",
  skim = "/Applications/Skim.app",
  fd = "fd",
}

-- Check if PDF viewer is already open with this file
-- Returns: PID if viewer is running with this PDF, nil otherwise (Linux)
-- Returns: true if document is open (macOS, no PID needed for AppleScript)
function M.get_viewer_pid(pdf_file)
  local pdf_path = vim.fn.fnamemodify(pdf_file, ":p")

  if IS_MACOS then
    -- macOS: Use AppleScript to check if Skim has this document open
    local applescript = string.format([[
      tell application "System Events"
        if not (exists process "Skim") then return "not_running"
      end tell
      tell application "Skim"
        set docList to documents
        repeat with doc in docList
          if (path of doc) is "%s" then
            return "open"
          end if
        end repeat
      end tell
      return "not_open"
    ]], pdf_path)
    local result = vim.fn.system(string.format("osascript -e %s 2>/dev/null", vim.fn.shellescape(applescript)))
    return result:match("^open") and 1 or nil
  else
    -- Linux: Check via /proc if zathura has this file open, return PID
    local cmd = string.format(
      "for pid in $(pgrep -x zathura 2>/dev/null); do grep -qF %s /proc/$pid/cmdline 2>/dev/null && echo $pid && break; done",
      vim.fn.shellescape(pdf_path)
    )
    local result = vim.fn.system(sh(cmd))
    local pid = result:match("(%d+)")
    return pid and tonumber(pid) or nil
  end
end

-- Check if viewer has the PDF open
function M.is_viewer_open(pdf_file)
  return M.get_viewer_pid(pdf_file) ~= nil
end

-- Force PDF viewer to reload the file
-- Linux: Zathura auto-reloads via inotify (no signal needed)
-- macOS: Uses AppleScript to reload in Skim
function M.reload_viewer(pdf_file, viewer_pid)
  if IS_MACOS then
    local pdf_path = vim.fn.fnamemodify(pdf_file, ":p")
    -- macOS: Use AppleScript to reload specific document in Skim
    local applescript = string.format([[
      tell application "Skim"
        set docList to documents
        repeat with doc in docList
          if (path of doc) is "%s" then
            revert doc
            return "reloaded"
          end if
        end repeat
      end tell
    ]], pdf_path)
    local result = vim.fn.system(string.format("osascript -e %s 2>/dev/null", vim.fn.shellescape(applescript)))
    return result:match("reloaded") ~= nil
  else
    -- Linux: Zathura auto-reloads via inotify when file changes
    -- Use passed viewer_pid to avoid redundant check
    return viewer_pid ~= nil
  end
end

-- Cross-platform PDF viewer
-- Linux: zathura, macOS: Skim (if installed) or Preview
-- Opens only if viewer is not already running with this PDF
function M.open_pdf(pdf_file, force)
  if vim.fn.filereadable(pdf_file) ~= 1 then
    return false
  end

  -- Check if viewer already has this PDF open (cache PID for reload)
  if not force then
    local viewer_pid = M.get_viewer_pid(pdf_file)
    if viewer_pid then
      M.reload_viewer(pdf_file, viewer_pid)
      return true
    end
  end

  if IS_MACOS then
    if is_tool_available("skim") then
      -- AppleScript for reliable opening of new PDFs
      -- Fixes issue: Skim does not open new files when already active
      local pdf_path = vim.fn.fnamemodify(pdf_file, ":p")
      local applescript = string.format([[
        tell application "Skim"
          activate
          open POSIX file "%s"
        end tell
      ]], pdf_path)
      vim.fn.system(string.format("osascript -e %s 2>/dev/null &", vim.fn.shellescape(applescript)))
    else
      vim.fn.system(sh(string.format("open %s &", vim.fn.shellescape(pdf_file))))
    end
    return true
  else
    -- Linux: zathura
    if is_tool_available("zathura") then
      vim.fn.system(sh(string.format("zathura %s &", vim.fn.shellescape(pdf_file))))
      return true
    end
  end

  return false
end

-- Check available tools (uses cache)
function M.check_latex_tools()
  local available = {}
  local missing = {}

  for name, cmd in pairs(M.latex_tools) do
    if is_tool_available(name == "skim" and "skim" or cmd) then
      available[name] = cmd
    else
      missing[name] = cmd
    end
  end

  return {
    available = available,
    missing = missing,
  }
end

-- Live preview state
M.live_preview_active = false

-- Compile LaTeX/Typst file and open PDF (async)
local function compile_and_preview(file, filetype)
  local file_dir = vim.fn.fnamemodify(file, ":h")
  local filename = vim.fn.fnamemodify(file, ":t")
  local basename = vim.fn.fnamemodify(file, ":t:r")
  local pdf_file = file_dir .. "/" .. basename .. ".pdf"

  local cmd
  if filetype == "tex" then
    if not is_tool_available("pdflatex") then return end
    cmd = string.format("cd %s && pdflatex -interaction=nonstopmode %s 2>&1",
      vim.fn.shellescape(file_dir), vim.fn.shellescape(filename))
  elseif filetype == "typ" then
    if not is_tool_available("typst") then return end
    -- Find project root (git root or home directory as fallback)
    local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(file_dir) .. " rev-parse --show-toplevel 2>/dev/null")[1]
    local root = (git_root and git_root ~= "" and vim.fn.isdirectory(git_root) == 1) and git_root or vim.fn.expand("~")
    cmd = string.format("cd %s && typst compile --root %s %s 2>&1",
      vim.fn.shellescape(file_dir), vim.fn.shellescape(root), vim.fn.shellescape(filename))
  else
    return
  end

  -- Collect compiler output
  local output_lines = {}

  -- Asynchrone Kompilierung (shell-independent)
  vim.fn.jobstart({ "/bin/sh", "-c", cmd }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        local icons = get_icons()
        local engine = filetype == "tex" and "pdflatex" or "typst"

        -- Check if PDF was created (success even with warnings)
        local pdf_exists = vim.fn.filereadable(pdf_file) == 1

        if exit_code == 0 then
          -- Clean success
          M.close_error_window()
          M.open_pdf(pdf_file)
          vim.notify(icons.status.success .. " " .. engine .. " compiled", vim.log.levels.INFO)
        elseif pdf_exists then
          -- PDF created despite errors (warnings or recoverable errors)
          M.open_pdf(pdf_file)
          M.show_error_window(engine .. " compiled with warnings", output_lines, false)
          vim.notify(icons.status.warning .. " " .. engine .. " compiled with warnings", vim.log.levels.WARN)
        else
          -- Actual failure - show errors in floating window
          M.show_error_window(engine .. " compilation failed", output_lines, true)
          vim.notify(icons.status.error .. " " .. engine .. " compilation failed", vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

-- Setup live preview (called automatically or manually)
-- silent: if true, no activation message
function M.setup_live_preview(silent)
  if M.live_preview_active then
    if not silent then
      vim.notify("Live preview already active", vim.log.levels.INFO)
    end
    return
  end

  local group = vim.api.nvim_create_augroup("LatexTypstLivePreview", { clear = true })

  -- LaTeX (.tex) live preview
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.tex",
    callback = function()
      compile_and_preview(vim.fn.expand("%:p"), "tex")
    end,
  })

  -- Typst (.typ) live preview
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.typ",
    callback = function()
      compile_and_preview(vim.fn.expand("%:p"), "typ")
    end,
  })

  M.live_preview_active = true

  if not silent then
    local icons = get_icons()
    print(icons.status.success .. " Live preview activated (auto-compile on save)")
  end
end

-- Disable live preview
function M.disable_live_preview()
  if not M.live_preview_active then
    vim.notify("Live preview not active", vim.log.levels.INFO)
    return
  end

  vim.api.nvim_create_augroup("LatexTypstLivePreview", { clear = true })
  M.live_preview_active = false

  local icons = get_icons()
  print(icons.status.success .. " Live preview deactivated")
end

-- Toggle live preview
function M.toggle_live_preview()
  if M.live_preview_active then
    M.disable_live_preview()
  else
    M.setup_live_preview()
  end
end

-- Auto-aktiviere Live Preview beim Laden des Moduls
M.setup_live_preview(true)

-- Optimized LaTeX project search with fd
function M.find_latex_files(pattern)
  if is_tool_available("fd") then
    local cmd = string.format("fd -e tex -e bib -e cls -e sty '%s'", pattern or "")
    local result = vim.fn.system(sh(cmd))
    if vim.v.shell_error == 0 then
      return vim.split(result, "\n", { trimempty = true })
    end
  end

  -- Fallback zu standard find
  local cmd = "find . -name '*.tex' -o -name '*.bib' -o -name '*.cls' -o -name '*.sty'"
  local result = vim.fn.system(sh(cmd))
  return vim.split(result, "\n", { trimempty = true })
end

-- LaTeX-Performance Status
function M.get_latex_status()
  local icons = get_icons()
  local status = M.check_latex_tools()

  print(icons.misc.gear .. " VelocityNvim LaTeX/Typst Status:")
  print("")

  print(icons.lsp.text .. " Engines:")
  print("  - pdflatex:    " .. (status.available.pdflatex and icons.status.success .. " Available" or icons.status.error .. " Not installed (texlive-core)"))
  print("  - typst:       " .. (status.available.typst and icons.status.success .. " Available" or icons.status.error .. " Not installed (cargo install typst-cli)"))
  print("  - texlab:      " .. (vim.lsp.get_clients({ name = "texlab" })[1] and icons.status.success .. " LSP active" or icons.status.warning .. " LSP not active"))
  print("")

  print(icons.status.search .. " Tools:")
  print("  - fd:          " .. (status.available.fd and icons.status.success .. " Fast file search" or icons.status.error .. " Standard find"))

  if IS_MACOS then
    print("  - PDF viewer:  " .. (is_tool_available("skim") and icons.status.success .. " Skim (SyncTeX)" or icons.status.success .. " Preview (macOS default)"))
  else
    print("  - zathura:     " .. (status.available.zathura and icons.status.success .. " SyncTeX PDF viewer" or icons.status.error .. " No SyncTeX viewer"))
  end
  print("")

  print(icons.status.info .. " Live preview: " .. (M.live_preview_active and "Active" or "Inactive"))
end

-- LaTeX build with pdflatex (async version)
function M.build_latex(file)
  file = file or vim.fn.expand("%:p")

  if not is_tool_available("pdflatex") then
    vim.notify("pdflatex not installed - install texlive-core", vim.log.levels.ERROR)
    return false
  end

  local icons = get_icons()
  print(icons.status.sync .. " Building with pdflatex...")

  local file_dir = vim.fn.fnamemodify(file, ":h")
  local filename = vim.fn.fnamemodify(file, ":t")
  local pdf_file = file_dir .. "/" .. filename:gsub("%.tex$", ".pdf")

  -- Async build to avoid blocking UI (shell-independent)
  local cmd = string.format("cd %s && pdflatex -interaction=nonstopmode %s 2>&1",
    vim.fn.shellescape(file_dir), vim.fn.shellescape(filename))

  vim.fn.jobstart({ "/bin/sh", "-c", cmd }, {
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 then
          print(icons.status.success .. " PDF built successfully!")
          M.open_pdf(pdf_file)
        else
          print(icons.status.error .. " pdflatex build failed")
        end
      end)
    end,
  })

  return true
end

-- Typst build (async version)
function M.build_typst(file)
  file = file or vim.fn.expand("%:p")

  if not is_tool_available("typst") then
    vim.notify("Typst not installed - cargo install typst-cli", vim.log.levels.ERROR)
    return false
  end

  local icons = get_icons()
  print(icons.status.sync .. " Building with Typst...")

  local file_dir = vim.fn.fnamemodify(file, ":h")
  local filename = vim.fn.fnamemodify(file, ":t")
  local pdf_file = file_dir .. "/" .. filename:gsub("%.typ$", ".pdf")

  -- Find project root (git root or home directory as fallback)
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(file_dir) .. " rev-parse --show-toplevel 2>/dev/null")[1]
  local root = (git_root and git_root ~= "" and vim.fn.isdirectory(git_root) == 1) and git_root or vim.fn.expand("~")

  -- Async build to avoid blocking UI (shell-independent)
  local cmd = string.format("cd %s && typst compile --root %s %s 2>&1",
    vim.fn.shellescape(file_dir), vim.fn.shellescape(root), vim.fn.shellescape(filename))

  vim.fn.jobstart({ "/bin/sh", "-c", cmd }, {
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 then
          print(icons.status.success .. " Typst PDF built successfully!")
          M.open_pdf(pdf_file)
        else
          print(icons.status.error .. " Typst build failed")
        end
      end)
    end,
  })

  return true
end

return M
