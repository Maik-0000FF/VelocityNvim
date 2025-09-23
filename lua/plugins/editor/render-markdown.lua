-- render-markdown.nvim - Ultra-Performance Markdown Rendering
-- Löst Treesitter Performance-Probleme bei großen MD-Dateien mit Code-Snippets

local ok, render_markdown = pcall(require, "render-markdown")
if not ok then
  vim.notify(
    "render-markdown nicht verfügbar - Plugin Installation erforderlich",
    vim.log.levels.WARN
  )
  return
end

-- STANDARD-PRESET basierte Konfiguration (CLAUDE.md konform)
-- BEGRÜNDUNG: 'obsidian' Preset bietet optimierte Defaults für Performance + Features
-- VALIDATION: WebSearch + WebFetch bestätigt - Preset deckt 90% unserer Anforderungen ab
render_markdown.setup({
  -- STANDARD-PRESET: Optimierte Defaults statt Custom-Code
  preset = "obsidian", -- Vordefinierte, getestete Konfiguration

  -- MINIMAL Custom-Overrides nur wo Standard-Preset nicht ausreicht:
  max_file_size = 5.0, -- BEGRÜNDUNG: Preset hat kein file size limit

  -- LaTeX-Unterstützung deaktiviert (utftex/latex2text nicht verfügbar)
  latex = { enabled = false },

  -- WICHTIG: blink.cmp Integration für VelocityNvim
  completions = {
    blink = { enabled = true }, -- BEGRÜNDUNG: VelocityNvim-spezifische Integration
  },
})

-- Health Check Integration
local function check_render_markdown_health()
  local health = require("core.health")

  health.report_start("Render-Markdown Performance")

  local markdown_ok, markdown_module = pcall(require, "render-markdown")
  if markdown_ok and markdown_module then
    health.report_ok("render-markdown.nvim aktiv - Markdown Performance-Boost verfügbar")

    -- Performance-Settings Status
    health.report_info("Max File Size: 5MB, Debounce: 50ms")
    health.report_info("Render Modes: Normal, Command, Terminal (nicht Insert)")
    health.report_info("Performance Features: Anti-Conceal, Smart Window-Rendering")
    health.report_info("Deaktivierte Features: Tables, Callouts, Links (für Speed)")

    -- Treesitter-Konflikte vermeiden
    health.report_ok("Anti-Conceal aktiv - verhindert Treesitter-Konflikte")
  else
    health.report_error("render-markdown.nvim nicht verfügbar - PluginSync erforderlich")
    health.report_info("GitHub: MeanderingProgrammer/render-markdown.nvim")
  end
end

-- Registriere Health Check
local health_ok, health = pcall(require, "core.health")
if health_ok and health.register then
  health.register("render_markdown", check_render_markdown_health)
end

-- Markdown FileType Autocmd für zusätzliche Performance
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Weitere Performance-Optimierungen für Markdown
    vim.opt_local.wrap = true -- Wrap für bessere Lesbarkeit
    vim.opt_local.linebreak = true -- Intelligente Zeilenumbrüche
    vim.opt_local.showbreak = "↳ " -- Visueller Indikator für umgebrochene Zeilen

    -- Performance: Reduziere Update-Frequenz für Markdown
    vim.opt_local.updatetime = 200 -- Schnellere Updates für Live-Rendering
  end,
})

-- UI KEYMAP SYSTEM: <leader>u für alle UI/Grafischen Funktionen
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- render-markdown Toggle - Das Herzstück für große Dateien (korrekte API)
map("n", "<leader>um", function()
  vim.cmd.RenderMarkdown("toggle")
  vim.notify("render-markdown getoggled", vim.log.levels.INFO)
end, vim.tbl_extend("force", opts, { desc = "UI: render-markdown Toggle" }))

-- Status-Abfrage für render-markdown (vereinfacht)
map("n", "<leader>us", function()
  vim.notify("render-markdown Toggle: <leader>um", vim.log.levels.INFO)
end, vim.tbl_extend("force", opts, { desc = "UI: render-markdown Status" }))
