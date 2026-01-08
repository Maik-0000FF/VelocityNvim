local wk = require("which-key")

wk.setup({
  -- win = { border = "single" },
})

-- Define groupings for better overview
wk.add({
  { "<leader>f", group = "Find/File" },
  { "<leader>l", group = "LSP" },
  { "<leader>g", group = "Git" },
  { "<leader>b", group = "Buffer" },
  { "<leader>m", group = "Format" },
  { "<leader>h", group = "Hop" },
  { "<leader>T", group = "Toggle" },
  { "<leader>Tc", desc = "Toggle Colorizer" },
  { "<leader>Tf", desc = "Toggle Auto-Format" },
  { "<leader>Tm", desc = "Toggle render-markdown" },
  { "<leader>s", group = "Split" },
  { "<leader>u", group = "UI/Utils" },
  { "<leader>W", group = "Web Server" },

  -- LaTeX/Typst Mappings (Backslash Leader)
  { "\\", group = "LaTeX/Typst" },
  { "\\s", desc = "LaTeX: Performance Status" },
  { "\\i", desc = "LaTeX/Typst: Toggle live preview" },
  { "\\c", desc = "LaTeX/Typst: Compile + display PDF" },
  { "\\v", desc = "LaTeX/Typst: Open PDF viewer" },
  { "\\x", desc = "LaTeX: Clean auxiliary files" },
  { "\\<CR>", desc = "LaTeX: Quick build + display" },
})