-- ~/.config/VelocityNvim/lua/utils/latex-performance.lua
-- Ultra-performance LaTeX setup with Rust tools

local M = {}

-- Rust-basierte LaTeX-Tools
M.latex_tools = {
  tectonic = "tectonic", -- Rust LaTeX-Engine
  typst = "typst", -- Moderne LaTeX-Alternative
  zathura = "zathura", -- PDF-Viewer mit SyncTeX
  fd = "fd", -- Schnelle File-Finding für LaTeX-Projekte
}

-- Check available LaTeX tools
function M.check_latex_tools()
  local available = {}
  local missing = {}

  for name, cmd in pairs(M.latex_tools) do
    if vim.fn.executable(cmd) == 1 then
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

-- Setup live preview with Rust performance
function M.setup_live_preview()
  local icons = require("core.icons")
  local status = M.check_latex_tools()

  -- Tectonic-based live compilation
  if status.available.tectonic then
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.tex",
      callback = function()
        local file = vim.fn.expand("%")
        local cmd = string.format("tectonic --synctex %s", file)

        vim.fn.system(cmd)
        if vim.v.shell_error == 0 then
          vim.notify("PDF updated", vim.log.levels.DEBUG)

          -- Auto-refresh Zathura if available
          if status.available.zathura then
            vim.fn.system("pkill -HUP zathura 2>/dev/null")
          end
        else
          vim.notify("LaTeX compilation failed", vim.log.levels.ERROR)
        end
      end,
    })

    print(icons.status.success .. " Tectonic live preview activated")
  end

  -- Typst-based live preview (even more modern)
  if status.available.typst then
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.typ",
      callback = function()
        local file = vim.fn.expand("%")
        local cmd = string.format("typst compile %s", file)

        vim.fn.system(cmd)
        if vim.v.shell_error == 0 then
          vim.notify("Typst PDF updated", vim.log.levels.DEBUG)
        end
      end,
    })

    print(icons.status.success .. " Typst live preview activated")
  end
end

-- Optimized LaTeX project search with fd
function M.find_latex_files(pattern)
  local status = M.check_latex_tools()

  if status.available.fd then
    -- Rust-based fd is 3-10x faster than find
    local cmd = string.format("fd -e tex -e bib -e cls -e sty '%s'", pattern or "")
    local result = vim.fn.system(cmd)

    if vim.v.shell_error == 0 then
      return vim.split(result, "\n", { trimempty = true })
    end
  end

  -- Fallback zu standard find
  local cmd =
    string.format("find . -name '*.tex' -o -name '*.bib' -o -name '*.cls' -o -name '*.sty'")
  local result = vim.fn.system(cmd)
  return vim.split(result, "\n", { trimempty = true })
end

-- LaTeX-Performance Status
function M.get_latex_status()
  local icons = require("core.icons")
  local status = M.check_latex_tools()

  print(icons.misc.gear .. " VelocityNvim LaTeX Performance Status:")
  print("")

  print(icons.lsp.text .. " LaTeX-Engines:")
  print(
    "  • tectonic:    "
      .. (
        status.available.tectonic and icons.status.success .. " Ultra-fast Rust engine"
        or icons.status.error .. " Not installed (cargo install tectonic)"
      )
  )
  print(
    "  • typst:       "
      .. (
        status.available.typst and icons.status.success .. " Modern alternative"
        or icons.status.error .. " Not installed (cargo install typst-cli)"
      )
  )
  print(
    "  • texlab:      "
      .. (
        vim.lsp.get_clients({ name = "texlab" })[1] and icons.status.success .. " LSP active"
        or icons.status.warning .. " LSP not active"
      )
  )
  print("")

  print(icons.status.search .. " Performance-Tools:")
  print(
    "  • fd:          "
      .. (
        status.available.fd and icons.status.success .. " Fast file search"
        or icons.status.error .. " Standard find"
      )
  )
  print(
    "  • zathura:     "
      .. (
        status.available.zathura and icons.status.success .. " SyncTeX PDF viewer"
        or icons.status.error .. " No SyncTeX viewer"
      )
  )
  print("")

  if next(status.missing) then
    print(icons.status.hint .. " Installation for maximum performance:")
    print("  cargo install tectonic typst-cli")
    print("  sudo pacman -S zathura zathura-pdf-mupdf fd")
  else
    print(icons.status.success .. " All LaTeX performance tools available!")
  end
end

-- LaTeX build with Tectonic (ultra-performance)
function M.build_with_tectonic(file)
  file = file or vim.fn.expand("%:p")

  if vim.fn.executable("tectonic") ~= 1 then
    vim.notify("Tectonic not installed", vim.log.levels.WARN)

    -- Fallback to pdflatex if available
    if vim.fn.executable("pdflatex") == 1 then
      vim.notify("Using pdflatex as fallback", vim.log.levels.INFO)
      local file_dir = vim.fn.fnamemodify(file, ":h")
      local filename = vim.fn.fnamemodify(file, ":t")
      local original_dir = vim.fn.getcwd()

      vim.fn.chdir(file_dir)
      local cmd = string.format("pdflatex %s", filename)
      local output = vim.fn.system(cmd)
      vim.fn.chdir(original_dir)

      if vim.v.shell_error == 0 then
        local icons = require("core.icons")
        print(icons.status.success .. " PDF created with pdflatex!")
        return true
      else
        print("pdflatex build failed:")
        print(output)
        return false
      end
    else
      vim.notify(
        "No LaTeX engine available - install texlive-core or tectonic",
        vim.log.levels.ERROR
      )
      return false
    end
  end

  local icons = require("core.icons")
  print(icons.status.sync .. " Building with Tectonic...")

  -- Change to .tex file directory
  local file_dir = vim.fn.fnamemodify(file, ":h")
  local filename = vim.fn.fnamemodify(file, ":t")
  local original_dir = vim.fn.getcwd()

  vim.fn.chdir(file_dir)
  local cmd = string.format("tectonic --synctex %s", filename)
  local output = vim.fn.system(cmd)
  vim.fn.chdir(original_dir)

  if vim.v.shell_error == 0 then
    print(icons.status.success .. " PDF built successfully!")

    -- Auto-open with Zathura
    if vim.fn.executable("zathura") == 1 then
      local pdf_file = file_dir .. "/" .. filename:gsub("%.tex$", ".pdf")
      if vim.fn.filereadable(pdf_file) == 1 then
        vim.fn.system(string.format("zathura %s &", pdf_file))
      end
    end

    return true
  else
    print(icons.status.error .. " Tectonic build failed:")
    print(output)
    return false
  end
end

-- Typst build (alternative)
function M.build_with_typst(file)
  file = file or vim.fn.expand("%:p")

  if vim.fn.executable("typst") ~= 1 then
    vim.notify("Typst not installed - cargo install typst-cli", vim.log.levels.ERROR)
    return false
  end

  local icons = require("core.icons")
  print(icons.status.sync .. " Building with Typst...")

  -- Change to .typ file directory
  local file_dir = vim.fn.fnamemodify(file, ":h")
  local filename = vim.fn.fnamemodify(file, ":t")
  local original_dir = vim.fn.getcwd()

  vim.fn.chdir(file_dir)
  local cmd = string.format("typst compile %s", filename)
  local output = vim.fn.system(cmd)
  vim.fn.chdir(original_dir)

  if vim.v.shell_error == 0 then
    print(icons.status.success .. " Typst PDF built successfully!")
    return true
  else
    print(icons.status.error .. " Typst build failed:")
    print(output)
    return false
  end
end

return M
