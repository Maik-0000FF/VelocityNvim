-- ~/.config/VelocityNvim/lua/utils/latex-performance.lua
-- Ultra-Performance LaTeX Setup mit Rust-Tools

local M = {}

-- Rust-basierte LaTeX-Tools
M.latex_tools = {
  tectonic = "tectonic", -- Rust LaTeX-Engine
  typst = "typst", -- Moderne LaTeX-Alternative
  zathura = "zathura", -- PDF-Viewer mit SyncTeX
  fd = "fd", -- Schnelle File-Finding für LaTeX-Projekte
}

-- Prüfe verfügbare LaTeX-Tools
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

-- Setup Live-Preview mit Rust-Performance
function M.setup_live_preview()
  local icons = require("core.icons")
  local status = M.check_latex_tools()

  -- Tectonic-basierte Live-Compilation
  if status.available.tectonic then
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.tex",
      callback = function()
        local file = vim.fn.expand("%")
        local cmd = string.format("tectonic --synctex %s", file)

        vim.fn.system(cmd)
        if vim.v.shell_error == 0 then
          vim.notify("PDF updated", vim.log.levels.DEBUG)

          -- Auto-refresh Zathura wenn verfügbar
          if status.available.zathura then
            vim.fn.system("pkill -HUP zathura 2>/dev/null")
          end
        else
          vim.notify("LaTeX compilation failed", vim.log.levels.ERROR)
        end
      end,
    })

    print(icons.status.success .. " Tectonic Live-Preview aktiviert")
  end

  -- Typst-basierte Live-Preview (noch moderner)
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

    print(icons.status.success .. " Typst Live-Preview aktiviert")
  end
end

-- Optimierte LaTeX-Projektsuche mit fd
function M.find_latex_files(pattern)
  local status = M.check_latex_tools()

  if status.available.fd then
    -- Rust-basierte fd ist 3-10x schneller als find
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
        or icons.status.error .. " Nicht installiert (cargo install tectonic)"
      )
  )
  print(
    "  • typst:       "
      .. (
        status.available.typst and icons.status.success .. " Moderne Alternative"
        or icons.status.error .. " Nicht installiert (cargo install typst-cli)"
      )
  )
  print(
    "  • texlab:      "
      .. (
        vim.lsp.get_clients({ name = "texlab" })[1] and icons.status.success .. " LSP aktiv"
        or icons.status.warning .. " LSP nicht aktiv"
      )
  )
  print("")

  print(icons.status.search .. " Performance-Tools:")
  print(
    "  • fd:          "
      .. (
        status.available.fd and icons.status.success .. " Schnelle Dateisuche"
        or icons.status.error .. " Standard find"
      )
  )
  print(
    "  • zathura:     "
      .. (
        status.available.zathura and icons.status.success .. " SyncTeX PDF-Viewer"
        or icons.status.error .. " Kein SyncTeX-Viewer"
      )
  )
  print("")

  if next(status.missing) then
    print(icons.status.hint .. " Installation für maximale Performance:")
    print("  cargo install tectonic typst-cli")
    print("  sudo pacman -S zathura zathura-pdf-mupdf fd")
  else
    print(icons.status.success .. " Alle LaTeX-Performance-Tools verfügbar!")
  end
end

-- LaTeX-Build mit Tectonic (Ultra-Performance)
function M.build_with_tectonic(file)
  file = file or vim.fn.expand("%:p")

  if vim.fn.executable("tectonic") ~= 1 then
    vim.notify("Tectonic nicht installiert", vim.log.levels.WARN)

    -- Fallback zu pdflatex wenn verfügbar
    if vim.fn.executable("pdflatex") == 1 then
      vim.notify("Verwende pdflatex als Fallback", vim.log.levels.INFO)
      local file_dir = vim.fn.fnamemodify(file, ":h")
      local filename = vim.fn.fnamemodify(file, ":t")
      local original_dir = vim.fn.getcwd()

      vim.fn.chdir(file_dir)
      local cmd = string.format("pdflatex %s", filename)
      local output = vim.fn.system(cmd)
      vim.fn.chdir(original_dir)

      if vim.v.shell_error == 0 then
        local icons = require("core.icons")
        print(icons.status.success .. " PDF mit pdflatex erstellt!")
        return true
      else
        print("pdflatex build fehlgeschlagen:")
        print(output)
        return false
      end
    else
      vim.notify(
        "Keine LaTeX-Engine verfügbar - installiere texlive-core oder tectonic",
        vim.log.levels.ERROR
      )
      return false
    end
  end

  local icons = require("core.icons")
  print(icons.status.sync .. " Building with Tectonic...")

  -- Wechsle ins Verzeichnis der .tex-Datei
  local file_dir = vim.fn.fnamemodify(file, ":h")
  local filename = vim.fn.fnamemodify(file, ":t")
  local original_dir = vim.fn.getcwd()

  vim.fn.chdir(file_dir)
  local cmd = string.format("tectonic --synctex %s", filename)
  local output = vim.fn.system(cmd)
  vim.fn.chdir(original_dir)

  if vim.v.shell_error == 0 then
    print(icons.status.success .. " PDF built successfully!")

    -- Auto-open mit Zathura
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

-- Typst-Build (Alternative)
function M.build_with_typst(file)
  file = file or vim.fn.expand("%:p")

  if vim.fn.executable("typst") ~= 1 then
    vim.notify("Typst nicht installiert - cargo install typst-cli", vim.log.levels.ERROR)
    return false
  end

  local icons = require("core.icons")
  print(icons.status.sync .. " Building with Typst...")

  -- Wechsle ins Verzeichnis der .typ-Datei
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

