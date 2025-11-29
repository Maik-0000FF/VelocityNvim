-- ~/.config/VelocityNvim/lua/utils/latex-performance.lua
-- Ultra-performance LaTeX setup with Rust tools

local M = {}

-- Rust-basierte LaTeX-Tools
M.latex_tools = {
  tectonic = "tectonic", -- Rust LaTeX-Engine
  typst = "typst", -- Moderne LaTeX-Alternative
  zathura = "zathura", -- PDF-Viewer mit SyncTeX (Linux)
  skim = "/Applications/Skim.app", -- PDF-Viewer mit SyncTeX (macOS)
  fd = "fd", -- Schnelle File-Finding für LaTeX-Projekte
}

-- Check if PDF viewer is already open with this file
-- Returns: true if viewer is running with this PDF
function M.is_viewer_open(pdf_file)
  local is_macos = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
  local pdf_path = vim.fn.fnamemodify(pdf_file, ":p")

  if is_macos then
    -- macOS: Check if Skim has this file open via lsof
    local result = vim.fn.system(string.format(
      "lsof 2>/dev/null | grep -F %s | grep -q Skim && echo 'open'",
      vim.fn.shellescape(pdf_path)
    ))
    return result:match("open") ~= nil
  else
    -- Linux: Check via /proc if zathura has this file open
    local result = vim.fn.system(string.format(
      "for pid in $(pgrep -x zathura 2>/dev/null); do grep -qF %s /proc/$pid/cmdline 2>/dev/null && echo 'open' && break; done",
      vim.fn.shellescape(pdf_path)
    ))
    return result:match("open") ~= nil
  end
end

-- Cross-platform PDF viewer
-- Linux: zathura, macOS: Skim (falls installiert) oder Preview
-- Öffnet nur wenn Viewer nicht bereits mit dieser PDF läuft
function M.open_pdf(pdf_file, force)
  if vim.fn.filereadable(pdf_file) ~= 1 then
    return false
  end

  local is_macos = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1

  -- Wenn Viewer schon offen ist, nichts tun (Auto-Reload übernimmt)
  if not force and M.is_viewer_open(pdf_file) then
    return true -- Viewer läuft bereits, Auto-Reload aktiv
  end

  if is_macos then
    -- macOS: Skim bevorzugt, sonst Preview
    -- "open -a" öffnet kein neues Fenster wenn Datei schon offen
    if vim.fn.isdirectory("/Applications/Skim.app") == 1 then
      vim.fn.system(string.format("open -a Skim %s &", vim.fn.shellescape(pdf_file)))
    else
      vim.fn.system(string.format("open %s &", vim.fn.shellescape(pdf_file)))
    end
    return true
  else
    -- Linux: zathura (hat eingebautes Auto-Reload)
    if vim.fn.executable("zathura") == 1 then
      vim.fn.system(string.format("zathura %s &", vim.fn.shellescape(pdf_file)))
      return true
    end
  end

  return false
end

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

-- Live preview state
M.live_preview_active = false

-- Compile LaTeX/Typst file and open PDF
local function compile_and_preview(file, filetype)
  local file_dir = vim.fn.fnamemodify(file, ":h")
  local filename = vim.fn.fnamemodify(file, ":t")
  local basename = vim.fn.fnamemodify(file, ":t:r")
  local pdf_file = file_dir .. "/" .. basename .. ".pdf"

  local cmd
  if filetype == "tex" then
    if vim.fn.executable("tectonic") == 1 then
      cmd = string.format("cd %s && tectonic --synctex %s 2>&1",
        vim.fn.shellescape(file_dir), vim.fn.shellescape(filename))
    elseif vim.fn.executable("pdflatex") == 1 then
      cmd = string.format("cd %s && pdflatex -interaction=nonstopmode %s 2>&1",
        vim.fn.shellescape(file_dir), vim.fn.shellescape(filename))
    else
      return -- Keine Engine verfügbar
    end
  elseif filetype == "typ" then
    if vim.fn.executable("typst") ~= 1 then
      return
    end
    cmd = string.format("cd %s && typst compile %s 2>&1",
      vim.fn.shellescape(file_dir), vim.fn.shellescape(filename))
  else
    return
  end

  -- Asynchrone Kompilierung
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.schedule(function()
          M.open_pdf(pdf_file)
        end)
      else
        vim.schedule(function()
          vim.notify(filetype == "tex" and "LaTeX compilation failed" or "Typst compilation failed",
            vim.log.levels.ERROR)
        end)
      end
    end,
  })
end

-- Setup live preview (called automatically or manually)
-- silent: wenn true, keine Aktivierungsnachricht
function M.setup_live_preview(silent)
  -- Verhindere doppelte Aktivierung
  if M.live_preview_active then
    if not silent then
      vim.notify("Live preview already active", vim.log.levels.INFO)
    end
    return
  end

  -- Erstelle augroup für einfaches Deaktivieren
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
    local icons = require("core.icons")
    print(icons.status.success .. " Live preview activated (auto-compile on save)")
  end
end

-- Disable live preview
function M.disable_live_preview()
  local icons = require("core.icons")

  if not M.live_preview_active then
    vim.notify("Live preview not active", vim.log.levels.INFO)
    return
  end

  vim.api.nvim_create_augroup("LatexTypstLivePreview", { clear = true })
  M.live_preview_active = false

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

  -- Cross-platform PDF viewer status
  local is_macos = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
  if is_macos then
    local has_skim = vim.fn.isdirectory("/Applications/Skim.app") == 1
    print(
      "  • PDF viewer:  "
        .. (
          has_skim and icons.status.success .. " Skim (SyncTeX)"
          or icons.status.success .. " Preview (macOS default)"
        )
    )
  else
    print(
      "  • zathura:     "
        .. (
          status.available.zathura and icons.status.success .. " SyncTeX PDF viewer"
          or icons.status.error .. " No SyncTeX viewer"
        )
    )
  end
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

    -- Auto-open PDF (cross-platform)
    local pdf_file = file_dir .. "/" .. filename:gsub("%.tex$", ".pdf")
    M.open_pdf(pdf_file)

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

    -- Auto-open PDF (cross-platform)
    local pdf_file = file_dir .. "/" .. filename:gsub("%.typ$", ".pdf")
    M.open_pdf(pdf_file)

    return true
  else
    print(icons.status.error .. " Typst build failed:")
    print(output)
    return false
  end
end

return M
