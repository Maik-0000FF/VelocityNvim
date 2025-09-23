local wk = require("which-key")

wk.setup({
  -- win = { border = "single" },
})

-- Gruppierungen definieren für bessere Übersicht
wk.add({
  { "<leader>f", group = "Find/File" },
  { "<leader>l", group = "LSP" },
  { "<leader>g", group = "Git" },
  { "<leader>b", group = "Buffer" },
  { "<leader>m", group = "Format" },
  { "<leader>h", group = "Git Hunks" },
  { "<leader>t", group = "Toggle" },
  { "<leader>s", group = "Split" },
  { "<leader>u", group = "UI/Utils" },

  -- LaTeX Mappings (Backslash Leader)
  { "\\", group = "LaTeX" },
  { "\\s", desc = "LaTeX: Performance Status" },
  { "\\i", desc = "LaTeX: Live Preview aktivieren" },
  { "\\b", desc = "LaTeX: Build mit Tectonic (Ultra-Fast)" },
  { "\\B", desc = "LaTeX: Build mit Typst (Modern)" },
  { "\\c", desc = "LaTeX: Compile aktueller Datei + Anzeige" },
  { "\\v", desc = "LaTeX: PDF Viewer öffnen" },
  { "\\x", desc = "LaTeX: Auxiliary files bereinigen" },
  { "\\<CR>", desc = "LaTeX: Quick Build + Anzeige" },
})