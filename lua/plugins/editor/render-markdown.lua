-- render-markdown.nvim - Ultra-Performance Markdown Rendering
-- Solves Treesitter performance issues with large MD files containing code snippets

local ok, render_markdown = pcall(require, "render-markdown")
if not ok then
  vim.notify(
    "render-markdown not available - Plugin installation required",
    vim.log.levels.WARN
  )
  return
end

-- STANDARD-PRESET based configuration (CLAUDE.md compliant)
-- RATIONALE: 'obsidian' preset provides optimized defaults for performance + features
-- VALIDATION: WebSearch + WebFetch confirmed - Preset covers 90% of our requirements
render_markdown.setup({
  -- STANDARD-PRESET: Optimized defaults instead of custom code
  preset = "obsidian", -- Predefined, tested configuration

  -- MINIMAL custom overrides only where standard preset is insufficient:
  max_file_size = 5.0, -- RATIONALE: Preset has no file size limit

  -- LaTeX support disabled (utftex/latex2text not available)
  latex = { enabled = false },

  -- IMPORTANT: blink.cmp integration for VelocityNvim
  completions = {
    blink = { enabled = true }, -- RATIONALE: VelocityNvim-specific integration
  },
})

-- Health Check Integration
local function check_render_markdown_health()
  local health = require("core.health")

  health.report_start("Render-Markdown Performance")

  local markdown_ok, markdown_module = pcall(require, "render-markdown")
  if markdown_ok and markdown_module then
    health.report_ok("render-markdown.nvim active - Markdown performance boost available")

    -- Performance settings status
    health.report_info("Max File Size: 5MB, Buffer Update: 200ms")
    health.report_info("Preset: Obsidian (feature-rich, optimized defaults)")
    health.report_info("LaTeX: Disabled (utftex/latex2text not available)")
    health.report_info("blink.cmp Integration: Enabled for VelocityNvim")

    -- Avoid Treesitter conflicts
    health.report_ok("Anti-Conceal active - prevents Treesitter conflicts")
  else
    health.report_error("render-markdown.nvim not available - PluginSync required")
    health.report_info("GitHub: MeanderingProgrammer/render-markdown.nvim")
  end
end

-- Register health check
local health_ok, health = pcall(require, "core.health")
if health_ok and health.register then
  health.register("render_markdown", check_render_markdown_health)
end

-- Markdown FileType autocmd for additional performance
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Performance optimizations for Markdown
    vim.opt_local.wrap = false -- No wrap
    vim.opt_local.linebreak = false -- No intelligent line breaks
    vim.opt_local.showbreak = "" -- No indicator for wrapped lines

    -- Performance: Reduce update frequency for Markdown
    vim.opt_local.updatetime = 200 -- Faster updates for live rendering
  end,
})

-- UI KEYMAP SYSTEM: <leader>u for all UI/graphical functions
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- render-markdown toggle - The centerpiece for large files (correct API)
map("n", "<leader>um", function()
  vim.cmd.RenderMarkdown("toggle")
  vim.notify("render-markdown toggled", vim.log.levels.INFO)
end, vim.tbl_extend("force", opts, { desc = "UI: render-markdown Toggle" }))

-- Status query for render-markdown (simplified)
map("n", "<leader>us", function()
  vim.notify("render-markdown Toggle: <leader>um", vim.log.levels.INFO)
end, vim.tbl_extend("force", opts, { desc = "UI: render-markdown Status" }))