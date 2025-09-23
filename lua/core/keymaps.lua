-- ~/.config/VelocityNvim/lua/core/keymaps.lua
-- Native Neovim Keymaps - Minimal und funktional

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Befehlsmodus einfacher aufrufen
map("n", ";", ":", { desc = "CMD: Enter command mode" })

-- ESC mit jk im Insert-Modus
map("i", "jk", "<ESC>", { silent = true, desc = "Exit insert mode" })

-- Folding Keymaps (Treesitter-basiert)
map("n", "zO", "zR", { desc = "Alle Folds öffnen (global)" })
map("n", "zC", "zM", { desc = "Alle Folds schließen (global)" })

----------------------------------------
-- Navigation
----------------------------------------

-- Effizientere Zeilen-Navigation
map("n", "j", "gj", { desc = "Visuell nach unten" })
map("n", "k", "gk", { desc = "Visuell nach oben" })

-- Schnellere horizontale Bewegung
map("n", "<S-h>", "^", { desc = "Go to beginning of line" })
map("n", "<S-l>", "g_", { desc = "Go to end of line" })

-- Insert-Modus Navigation
map("i", "<C-h>", "<left>", { desc = "Move left in insert mode" })
map("i", "<C-j>", "<down>", { desc = "Move down in insert mode" })
map("i", "<C-k>", "<up>", { desc = "Move up in insert mode" })
map("i", "<C-l>", "<right>", { desc = "Move right in insert mode" })

----------------------------------------
-- Fenster-Navigation
----------------------------------------

-- Einfache Fenster-Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Fenster links" })
map("n", "<C-l>", "<C-w>l", { desc = "Fenster rechts" })
map("n", "<C-j>", "<C-w>j", { desc = "Fenster unten" })
map("n", "<C-k>", "<C-w>k", { desc = "Fenster oben" })

-- Fenster-Größe ändern
map("n", "<C-Up>", ":resize +1<CR>", opts)
map("n", "<C-Down>", ":resize -1<CR>", opts)
map("n", "<C-Left>", ":vertical resize -1<CR>", opts)
map("n", "<C-Right>", ":vertical resize +1<CR>", opts)

----------------------------------------
-- Textbearbeitung
----------------------------------------

-- Suchhervorhebung ausschalten
map("n", "<ESC>", ":nohlsearch<CR>", opts)

-- Besseres Einrücken
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Text verschieben
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

----------------------------------------
-- Buffer und Dateien
----------------------------------------

-- Buffer-Navigation
map("n", "<leader>j", "<cmd>bnext<CR>", { desc = "Nächster Buffer" })
map("n", "<leader>k", "<cmd>bprevious<CR>", { desc = "Vorheriger Buffer" })
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "Neuer leerer Buffer" })
map("n", "<leader>bi", "<cmd>enew<CR><cmd>startinsert<CR>", { desc = "Neuer Buffer (Insert-Mode)" })

-- Fenster-Operationen
map("n", "<leader>s\\", ":vsplit<CR>", opts)
map("n", "<leader>s-", ":split<CR>", opts)
map("n", "<leader>q", ":q<CR>", opts)

-- Datei-Operationen
map("n", "<leader>w", ":w<CR>", { desc = "Datei speichern" })
map("n", "<leader>wa", ":wa<CR>", { desc = "Alle Dateien speichern" })

-- Buffer schließen
map("n", "<leader>x", ":%bd|e#|bd#<CR>", { desc = "Alle Buffer außer aktuellen schließen" })

-- Sicheres Buffer-Schließen mit Bestätigungsabfrage
map("n", "<leader>cc", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_name = vim.fn.expand("%:t")

  -- Prüfe ob Buffer modifiziert ist
  if vim.bo[current_buf].modified then
    -- Frage Benutzer, was zu tun ist
    local choice = vim.fn.confirm(
      "Buffer '" .. current_name .. "' wurde geändert. Was möchten Sie tun?",
      "&Speichern\n&Verwerfen\n&Abbrechen",
      1 -- Standard: Speichern
    )

    if choice == 1 then
      -- Speichern und schließen
      local ok, err = pcall(function()
        vim.api.nvim_command("w")
      end)
      if not ok then
        vim.notify("Fehler beim Speichern: " .. err, vim.log.levels.ERROR)
        return
      end
    elseif choice == 2 then
      -- Erzwinge Schließen ohne Speichern
      vim.bo[current_buf].modified = false
    else
      -- Abbrechen
      return
    end
  end

  -- Zähle normale Buffer (nicht speziell, gültig und gelistet)
  local buf_count = #vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == ""
  end, vim.api.nvim_list_bufs())

  if buf_count <= 1 then
    -- Es ist der letzte normale Buffer
    -- Speichere den aktuellen Buffer für die Löschung
    local buffer_to_delete = current_buf

    -- Erstelle zuerst einen neuen Buffer
    vim.api.nvim_command("enew")

    -- Lösche den alten Buffer direkt mit seiner ID
    local ok, err = pcall(vim.api.nvim_buf_delete, buffer_to_delete, { force = true })
    if not ok then
      -- Falls Löschen fehlschlägt, informiere den Nutzer
      vim.notify("Konnte Buffer nicht löschen: " .. tostring(err), vim.log.levels.WARN)
    end
    -- Silent success - keine Meldung bei erfolgreichem Schließen
  else
    -- Mehrere Buffer vorhanden
    -- Speichere Buffer-ID vor dem Wechsel
    local buffer_to_delete = current_buf

    -- Wechsle zuerst zu einem anderen Buffer
    vim.api.nvim_command("bprevious")

    -- Lösche den spezifischen Buffer
    local ok, err = pcall(vim.api.nvim_buf_delete, buffer_to_delete, { force = true })
    if not ok then
      vim.notify("Fehler beim Schließen: " .. tostring(err), vim.log.levels.ERROR)
    end
    -- Silent success - keine Meldung bei erfolgreichem Schließen
  end
end, { noremap = true, silent = true, desc = "Buffer: Sicher schließen" })

----------------------------------------
-- Neo-tree (Dateibrowser)
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

-- LaTeX Status und Info
map("n", "\\s", "<cmd>LaTeXStatus<CR>", { desc = "LaTeX: Performance Status" })
map("n", "\\i", "<cmd>LaTeXLivePreview<CR>", { desc = "LaTeX: Live Preview aktivieren" })

-- LaTeX Building
map("n", "\\b", "<cmd>LaTeXBuildTectonic<CR>", { desc = "LaTeX: Build mit Tectonic (Ultra-Fast)" })
map("n", "\\B", "<cmd>LaTeXBuildTypst<CR>", { desc = "LaTeX: Build mit Typst (Modern)" })

-- LaTeX Compilation (traditionell)
map("n", "\\c", function()
  local file = vim.fn.expand("%:p")
  local bufname = vim.fn.bufname()

  -- Prüfe ob es ein gültiger Dateibuffer ist
  if not file or file == "" or bufname:match("^neo%-tree") then
    vim.notify("Kein LaTeX-Dokument geöffnet", vim.log.levels.WARN)
    return
  end

  local file_dir = vim.fn.fnamemodify(file, ":h")
  local filename = vim.fn.fnamemodify(file, ":t")
  local basename = vim.fn.fnamemodify(file, ":t:r")

  if file:match("%.tex$") then
    -- Prüfe ob pdflatex verfügbar ist
    if vim.fn.executable("pdflatex") ~= 1 then
      vim.notify("pdflatex nicht gefunden - installiere texlive-core", vim.log.levels.ERROR)
      return
    end

    -- Wechsle ins Verzeichnis der .tex-Datei für pdflatex
    local original_dir = vim.fn.getcwd()
    vim.fn.chdir(file_dir)
    vim.api.nvim_command("!pdflatex " .. filename)
    vim.fn.chdir(original_dir)

    -- Nach erfolgreichem Kompilieren PDF öffnen
    vim.defer_fn(function()
      local pdf_file = file_dir .. "/" .. basename .. ".pdf"
      if vim.fn.filereadable(pdf_file) == 1 then
        if vim.fn.executable("zathura") == 1 then
          vim.fn.system("zathura " .. pdf_file .. " &")
        else
          vim.notify("Zathura nicht verfügbar", vim.log.levels.WARN)
        end
      else
        vim.notify("PDF nicht gefunden: " .. pdf_file, vim.log.levels.ERROR)
      end
    end, 1000) -- 1s Verzögerung für pdflatex completion
  elseif file:match("%.typ$") then
    vim.api.nvim_command("LaTeXBuildTypst")

    -- Nach Typst-Kompilierung PDF öffnen
    vim.defer_fn(function()
      local pdf_file = file_dir .. "/" .. basename .. ".pdf"
      if vim.fn.filereadable(pdf_file) == 1 then
        if vim.fn.executable("zathura") == 1 then
          vim.fn.system("zathura " .. pdf_file .. " &")
        else
          vim.notify("Zathura nicht verfügbar", vim.log.levels.WARN)
        end
      else
        vim.notify("PDF nicht gefunden: " .. pdf_file, vim.log.levels.ERROR)
      end
    end, 500) -- 500ms Verzögerung für Typst completion
  else
    vim.notify("Keine LaTeX/Typst-Datei", vim.log.levels.WARN)
  end
end, { desc = "LaTeX: Compile aktueller Datei + Anzeige" })

-- LaTeX Viewer
map("n", "\\v", function()
  local current_file = vim.fn.expand("%:p")
  local bufname = vim.fn.bufname()

  -- Prüfe ob es ein gültiger Dateibuffer ist
  if not current_file or current_file == "" or bufname:match("^neo%-tree") then
    vim.notify("Kein LaTeX-Dokument geöffnet", vim.log.levels.WARN)
    return
  end

  local file_dir = vim.fn.fnamemodify(current_file, ":h")
  local basename = vim.fn.fnamemodify(current_file, ":t:r")
  local file = file_dir .. "/" .. basename .. ".pdf"

  if vim.fn.filereadable(file) == 1 then
    if vim.fn.executable("zathura") == 1 then
      vim.fn.system("zathura " .. file .. " &")
      -- Silent success - PDF öffnen ist erwartetes Verhalten
    else
      vim.notify("Zathura nicht verfügbar", vim.log.levels.WARN)
    end
  else
    vim.notify("PDF nicht gefunden: " .. file, vim.log.levels.ERROR)
  end
end, { desc = "LaTeX: PDF Viewer öffnen" })

-- LaTeX Cleanup
map("n", "\\x", function()
  local extensions =
    { "aux", "log", "out", "toc", "bbl", "blg", "fdb_latexmk", "fls", "synctex.gz" }
  local cleaned = {}
  local current_file = vim.fn.expand("%:p")
  local file_dir = vim.fn.fnamemodify(current_file, ":h")
  local basename = vim.fn.fnamemodify(current_file, ":t:r")

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
    vim.notify("Keine Auxiliary files gefunden", vim.log.levels.INFO)
  end
end, { desc = "LaTeX: Auxiliary files bereinigen" })

-- LaTeX Schnell-Kompilierung + Anzeige
map("n", "\\<CR>", function()
  local latex_perf = require("utils.latex-performance")
  local current_file = vim.fn.expand("%:p")
  latex_perf.build_with_tectonic(current_file)
  -- PDF-Öffnen ist bereits in build_with_tectonic() integriert
end, { desc = "LaTeX: Quick Build + Anzeige" })
