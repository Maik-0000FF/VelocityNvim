-- ~/.config/VelocityNvim/lua/core/keymaps.lua
-- Native Neovim Keymaps - Minimal and functional

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Enter command mode easier
map("n", ";", ":", { desc = "CMD: Enter command mode" })

-- ESC with jk in insert mode
map("i", "jk", "<ESC>", { silent = true, desc = "Exit insert mode" })

-- Folding keymaps (Treesitter-based)
map("n", "zO", "zR", { desc = "Open all folds (global)" })
map("n", "zC", "zM", { desc = "Close all folds (global)" })

----------------------------------------
-- Navigation
----------------------------------------

-- More efficient line navigation
map("n", "j", "gj", { desc = "Move down visually" })
map("n", "k", "gk", { desc = "Move up visually" })

-- Faster horizontal movement
map("n", "<S-h>", "^", { desc = "Go to beginning of line" })
map("n", "<S-l>", "g_", { desc = "Go to end of line" })

-- Insert mode navigation
map("i", "<C-h>", "<left>", { desc = "Move left in insert mode" })
map("i", "<C-j>", "<down>", { desc = "Move down in insert mode" })
map("i", "<C-k>", "<up>", { desc = "Move up in insert mode" })
map("i", "<C-l>", "<right>", { desc = "Move right in insert mode" })

----------------------------------------
-- Window Navigation
----------------------------------------

-- Simple window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Window above" })

-- Resize windows
map("n", "<C-Up>", ":resize +1<CR>", opts)
map("n", "<C-Down>", ":resize -1<CR>", opts)
map("n", "<C-Left>", ":vertical resize -1<CR>", opts)
map("n", "<C-Right>", ":vertical resize +1<CR>", opts)

----------------------------------------
-- Text Editing
----------------------------------------

-- Turn off search highlighting
map("n", "<ESC>", ":nohlsearch<CR>", opts)

-- Better indenting
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Move text
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

----------------------------------------
-- Buffers and Files
----------------------------------------

-- Buffer navigation
map("n", "<leader>j", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>k", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New empty buffer" })
map("n", "<leader>bi", "<cmd>enew<CR><cmd>startinsert<CR>", { desc = "New buffer (insert mode)" })

-- Window operations
map("n", "<leader>s\\", ":vsplit<CR>", opts)
map("n", "<leader>s-", ":split<CR>", opts)
map("n", "<leader>q", ":q<CR>", opts)

-- File operations
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>wa", ":wa<CR>", { desc = "Save all files" })

-- Close buffer
map("n", "<leader>x", ":%bd|e#|bd#<CR>", { desc = "Close all buffers except current" })

-- Safe buffer close with confirmation prompt
map("n", "<leader>cc", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_name = vim.fn.expand("%:t")

  -- Check if buffer is modified
  if vim.bo[current_buf].modified then
    -- Ask user what to do
    local choice = vim.fn.confirm(
      "Buffer '" .. current_name .. "' has been modified. What do you want to do?",
      "&Save\n&Discard\n&Cancel",
      1 -- Default: Save
    )

    if choice == 1 then
      -- Save and close
      local ok, err = pcall(function()
        vim.api.nvim_command("w")
      end)
      if not ok then
        vim.notify("Error saving: " .. err, vim.log.levels.ERROR)
        return
      end
    elseif choice == 2 then
      -- Force close without saving
      vim.bo[current_buf].modified = false
    else
      -- Cancel
      return
    end
  end

  -- Count normal buffers (not special, valid and listed)
  local buf_count = #vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == ""
  end, vim.api.nvim_list_bufs())

  if buf_count <= 1 then
    -- It's the last normal buffer
    -- Save current buffer for deletion
    local buffer_to_delete = current_buf

    -- Create a new buffer first
    vim.api.nvim_command("enew")

    -- Delete the old buffer directly with its ID
    local ok, err = pcall(vim.api.nvim_buf_delete, buffer_to_delete, { force = true })
    if not ok then
      -- If deletion fails, inform the user
      vim.notify("Could not delete buffer: " .. tostring(err), vim.log.levels.WARN)
    end
    -- Silent success - no message on successful close
  else
    -- Multiple buffers present
    -- Save buffer ID before switching
    local buffer_to_delete = current_buf

    -- Switch to another buffer first
    vim.api.nvim_command("bprevious")

    -- Delete the specific buffer
    local ok, err = pcall(vim.api.nvim_buf_delete, buffer_to_delete, { force = true })
    if not ok then
      vim.notify("Error closing: " .. tostring(err), vim.log.levels.ERROR)
    end
    -- Silent success - no message on successful close
  end
end, { noremap = true, silent = true, desc = "Buffer: Safe close" })

----------------------------------------
-- Neo-tree (File Browser)
----------------------------------------

map("n", "<leader>e", "<cmd>Neotree focus<CR>", { desc = "Focus NeoTree" })
map("n", "<C-n>", "<cmd>Neotree toggle<CR>", { desc = "Toggle NeoTree" })
map("n", "<leader>ge", "<cmd>Neotree git_status<CR>", { desc = "Git Explorer" })
map("n", "<leader>be", "<cmd>Neotree buffers<CR>", { desc = "Buffer Explorer" })

-- Hop Navigation
map("n", "<leader>ll", "<cmd>HopLine<CR>", { desc = "Hop Line" })
map("n", "<leader>ww", "<cmd>HopWord<CR>", { desc = "Hop Word" })

-- Suda (Sudo Write)
map("n", "<leader>W", "<cmd>SudaWrite<CR>", { desc = "Write with sudo" })

-- LSP Diagnostic FZF Keymaps (diese wurden nach lsp-debug.lua verschoben)
-- <leader>le und <leader>lE werden in fzf-lua.lua definiert

----------------------------------------
-- LaTeX Keymaps (Leader: \)
----------------------------------------

-- LaTeX status and info
map("n", "\\s", "<cmd>LaTeXStatus<CR>", { desc = "LaTeX: Performance Status" })
map("n", "\\i", "<cmd>LaTeXLivePreviewToggle<CR>", { desc = "LaTeX: Toggle live preview" })

-- LaTeX building
map("n", "\\b", "<cmd>LaTeXBuildTectonic<CR>", { desc = "LaTeX: Build with Tectonic (ultra-fast)" })
map("n", "\\B", "<cmd>LaTeXBuildTypst<CR>", { desc = "LaTeX: Build with Typst (modern)" })

-- LaTeX compilation (traditional)
map("n", "\\c", function()
  local file = vim.fn.expand("%:p")
  local bufname = vim.fn.bufname()

  -- Check if it's a valid file buffer
  if not file or file == "" or bufname:match("^neo%-tree") then
    vim.notify("No LaTeX document open", vim.log.levels.WARN)
    return
  end

  -- Cache path components (optimized: batch fnamemodify calls)
  local file_dir, filename, basename =
    vim.fn.fnamemodify(file, ":h"),
    vim.fn.fnamemodify(file, ":t"),
    vim.fn.fnamemodify(file, ":t:r")

  if file:match("%.tex$") then
    -- Check if pdflatex is available
    if vim.fn.executable("pdflatex") ~= 1 then
      vim.notify("pdflatex not found - install texlive-core", vim.log.levels.ERROR)
      return
    end

    -- Change to .tex file directory for pdflatex
    local original_dir = vim.fn.getcwd()
    vim.fn.chdir(file_dir)
    vim.api.nvim_command("!pdflatex " .. filename)
    vim.fn.chdir(original_dir)

    -- Open PDF after successful compilation (cross-platform)
    vim.defer_fn(function()
      local pdf_file = file_dir .. "/" .. basename .. ".pdf"
      local latex_perf = require("utils.latex-performance")
      if not latex_perf.open_pdf(pdf_file) then
        vim.notify("PDF not found: " .. pdf_file, vim.log.levels.ERROR)
      end
    end, 1000) -- 1s delay for pdflatex completion
  elseif file:match("%.typ$") then
    vim.api.nvim_command("LaTeXBuildTypst")
    -- PDF opening is now handled by build_with_typst()
  else
    vim.notify("Not a LaTeX/Typst file", vim.log.levels.WARN)
  end
end, { desc = "LaTeX: Compile current file + display" })

-- LaTeX viewer (cross-platform)
map("n", "\\v", function()
  local current_file = vim.fn.expand("%:p")
  local bufname = vim.fn.bufname()

  -- Check if it's a valid file buffer
  if not current_file or current_file == "" or bufname:match("^neo%-tree") then
    vim.notify("No LaTeX document open", vim.log.levels.WARN)
    return
  end

  -- Cache path components (optimized)
  local file_dir, basename =
    vim.fn.fnamemodify(current_file, ":h"),
    vim.fn.fnamemodify(current_file, ":t:r")
  local pdf_file = file_dir .. "/" .. basename .. ".pdf"

  local latex_perf = require("utils.latex-performance")
  if not latex_perf.open_pdf(pdf_file) then
    vim.notify("PDF not found: " .. pdf_file, vim.log.levels.ERROR)
  end
end, { desc = "LaTeX: Open PDF viewer" })

-- LaTeX cleanup
map("n", "\\x", function()
  local extensions =
    { "aux", "log", "out", "toc", "bbl", "blg", "fdb_latexmk", "fls", "synctex.gz" }
  local cleaned = {}
  local current_file = vim.fn.expand("%:p")
  -- Cache path components (optimized)
  local file_dir, basename =
    vim.fn.fnamemodify(current_file, ":h"),
    vim.fn.fnamemodify(current_file, ":t:r")

  for _, ext in ipairs(extensions) do
    local file = file_dir .. "/" .. basename .. "." .. ext
    if vim.fn.filereadable(file) == 1 then
      vim.fn.delete(file)
      table.insert(cleaned, ext)
    end
  end

  if #cleaned > 0 then
    vim.notify("Auxiliary files cleaned: " .. table.concat(cleaned, ", "), vim.log.levels.INFO)
  else
    vim.notify("No auxiliary files found", vim.log.levels.INFO)
  end
end, { desc = "LaTeX: Clean auxiliary files" })

-- LaTeX quick compilation + display
map("n", "\\<CR>", function()
  local latex_perf = require("utils.latex-performance")
  local current_file = vim.fn.expand("%:p")
  latex_perf.build_with_tectonic(current_file)
  -- Opening PDF is already integrated in build_with_tectonic()
end, { desc = "LaTeX: Quick build + display" })

----------------------------------------
-- Web Development Server (Leader: <leader>w)
----------------------------------------

-- Web server control
map("n", "<leader>ws", "<cmd>WebServerStart<CR>", { desc = "Web: Start server" })
map("n", "<leader>wS", "<cmd>WebServerStop<CR>", { desc = "Web: Stop server" })
map("n", "<leader>wo", "<cmd>WebServerOpen<CR>", { desc = "Web: Open browser" })
map("n", "<leader>wi", "<cmd>WebServerInfo<CR>", { desc = "Web: Server info" })