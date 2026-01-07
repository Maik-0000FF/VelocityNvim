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

  -- LaTeX Mappings (Backslash Leader)
  { "\\", group = "LaTeX" },
  { "\\s", desc = "LaTeX: Performance Status" },
  { "\\i", desc = "LaTeX: Enable live preview" },
  { "\\b", desc = "LaTeX: Build with Tectonic (Ultra-Fast)" },
  { "\\B", desc = "LaTeX: Build with Typst (Modern)" },
  { "\\c", desc = "LaTeX: Compile current file + display" },
  { "\\v", desc = "LaTeX: Open PDF viewer" },
  { "\\x", desc = "LaTeX: Clean auxiliary files" },
  { "\\<CR>", desc = "LaTeX: Quick build + display" },
})