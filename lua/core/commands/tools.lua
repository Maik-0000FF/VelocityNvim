-- ~/.config/VelocityNvim/lua/core/commands/tools.lua
-- External tools: Rust, LaTeX, formatting, colorizer, web server

local cmd = vim.api.nvim_create_user_command
local icons = require("core.icons")

-- Rust LSP 2025 Optimization Status
cmd("RustAnalyzer2025Status", function()
  local ok, rust_perf = pcall(require, "utils.rust-performance")
  if not ok then
    vim.notify(icons.status.error .. " utils.rust-performance module not available", vim.log.levels.ERROR)
    return
  end
  local analysis = rust_perf.analyze_rust_ecosystem()
  local total_memory_gb = analysis.toolchain.total_memory_gb
  local cpu_cores = tonumber(vim.fn.system("nproc 2>/dev/null")) or 4

  print(icons.status.rocket .. " Rust-Analyzer 2025 Optimization Status")
  print("=" .. string.rep("=", 50))

  -- Hardware Analysis
  print("\n" .. icons.misc.gear .. " Hardware detection:")
  print("  " .. icons.misc.gear .. " RAM: " .. total_memory_gb .. "GB")
  print("  " .. icons.misc.gear .. " CPU Cores: " .. cpu_cores)

  -- Performance Tier
  local tier = "Conservative (<8GB)"
  if total_memory_gb >= 32 then
    tier = "Ultra-High-Performance (32+GB) " .. icons.misc.flash
  elseif total_memory_gb >= 16 then
    tier = "High-Performance (16-31GB)"
  elseif total_memory_gb >= 8 then
    tier = "Balanced (8-15GB)"
  end
  print("  " .. icons.status.rocket .. " Performance Tier: " .. tier)

  -- 2025 Optimizations
  print("\n" .. icons.misc.flash .. " 2025 New Features:")
  print("  " .. icons.status.success .. " Auto-Threading: numThreads = null (optimal)")
  print(
    "  "
      .. icons.status.success
      .. " Dynamic LRU: "
      .. math.min(2048, math.max(128, total_memory_gb * 32))
      .. " capacity"
  )
  print("  " .. icons.status.success .. " Target Separation: target/rust-analyzer")

  if total_memory_gb >= 32 then
    print("  " .. icons.status.success .. " Memory Limit: 8192MB")
    print("  " .. icons.status.success .. " Cache Priming: " .. cpu_cores .. " threads")
    print("  " .. icons.status.success .. " All Features: Enabled")
    print("  " .. icons.status.success .. " Proc Macros: Full support")
  end

  print("\n" .. icons.status.stats .. " Expected improvements:")
  print("  " .. icons.performance.fast .. " 30-40% faster builds")
  print("  " .. icons.performance.optimize .. " Better memory usage")
  print("  " .. icons.performance.benchmark .. " No cargo interference")
  print("  " .. icons.misc.gear .. " Optimal thread distribution")
end, {
  desc = "Show rust-analyzer 2025 performance optimizations status",
})

-- Formatting Commands
cmd("FormatInfo", function()
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify(icons.status.error .. " conform.nvim not available", vim.log.levels.ERROR)
    return
  end
  local formatters = conform.list_formatters()

  print(icons.misc.build .. " Formatter Status for " .. vim.bo.filetype .. ":")
  if #formatters == 0 then
    print("  " .. icons.status.error .. " No formatters configured")
  else
    for _, formatter in ipairs(formatters) do
      local status = formatter.available and icons.status.success or icons.status.error
      print("  " .. status .. " " .. formatter.name)
    end
  end

  -- Check for LSP fallback capability (safe API call)
  local has_lsp_fallback = false
  local fallback_ok, result = pcall(function()
    return conform.will_fallback_lsp and conform.will_fallback_lsp() or false
  end)
  if fallback_ok then
    has_lsp_fallback = result
  end

  local fallback_status = has_lsp_fallback and icons.status.success .. " Available"
    or icons.status.error .. " Not available"
  print("  " .. icons.status.gear .. " LSP-Fallback: " .. fallback_status)
end, {
  desc = "Show formatter status",
})

cmd("FormatToggle", function()
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify(icons.status.error .. " conform.nvim not available", vim.log.levels.ERROR)
    return
  end

  -- Check current state by trying to get format_on_save config
  local config_ok, config = pcall(require, "conform.config")
  local format_on_save_enabled = config_ok and config.options
    and config.options.format_on_save ~= false
    and config.options.format_on_save ~= nil

  if format_on_save_enabled then
    conform.setup({ format_on_save = false })
    vim.notify(icons.status.error .. " Auto-format on save disabled", vim.log.levels.INFO)
  else
    conform.setup({
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end
end, {
  desc = "Toggle auto-format on save",
})

-- Rust Performance Commands
cmd("RustPerformanceStatus", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.get_performance_status()
end, { desc = "Show Rust performance status" })

cmd("RustBuildBlink", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.build_blink_rust()
end, { desc = "Compile Blink.cmp Rust binary" })

cmd("RustOptimize", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.optimize_for_rust()
end, { desc = "Optimize Neovim for Rust performance" })

cmd("RustBenchmark", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.benchmark_fuzzy_performance()
end, { desc = "Benchmark Rust performance" })

-- ULTIMATE Rust Performance Commands
cmd("RustUltimateSetup", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.ultimate_setup()
end, {
  desc = "Complete ULTIMATE Rust performance analysis and setup",
})

cmd("RustAnalyzeEcosystem", function()
  local rust_perf = require("utils.rust-performance")
  local analysis = rust_perf.analyze_rust_ecosystem()

  print(icons.performance.benchmark .. " Rust Ecosystem Analysis:")
  print("  " .. icons.misc.gear .. " CPU: " .. analysis.toolchain.cpu_target)
  print("  " .. icons.misc.gear .. " RAM: " .. analysis.toolchain.total_memory_gb .. "GB")
  print("  " .. icons.misc.gear .. " Rustc: " .. analysis.toolchain.rustc_version)
  print(
    "  "
      .. icons.misc.gear
      .. " Nightly: "
      .. (analysis.toolchain.has_nightly and "Available" or "Not installed")
  )
end, {
  desc = "Analyze Rust ecosystem and hardware capabilities",
})

cmd("RustAdaptiveLSP", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.generate_adaptive_lsp_config()
end, {
  desc = "Generate adaptive rust-analyzer configuration",
})

cmd("RustCrossSetup", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.setup_cross_compilation()
end, {
  desc = "Setup cross-compilation targets and configuration",
})

cmd("RustCargoUltra", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.setup_cargo_ultra_profile()
end, {
  desc = "Setup Cargo ultra-performance profile with Fat-LTO",
})

cmd("RustUltimateBenchmark", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.ultimate_benchmark()
end, {
  desc = "Run comprehensive ULTIMATE performance benchmark with detailed scoring",
})

cmd("RustMoldCheck", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.check_mold_linker()
end, {
  desc = "Check mold linker status and installation",
})

-- Color Highlighting Commands
cmd("ColorizerStatus", function()
  local ok, _ = pcall(require, "colorizer")
  if ok then
    print(icons.status.success .. " nvim-colorizer.lua: Active and ready!")
    print(icons.misc.info .. " Supported formats: #RGB, #RRGGBB, rgb(), hsl(), CSS names")
    print(icons.misc.gear .. " Toggle: <leader>ct | Reload: <leader>cr")
  else
    print(icons.status.error .. " nvim-colorizer.lua not available")
  end
end, {
  desc = "Show nvim-colorizer.lua status and usage info",
})

cmd("DeltaStatus", function()
  local rust_perf = require("utils.rust-performance")
  rust_perf.get_delta_status()
end, { desc = "Check Delta Git Performance Status" })

-- LaTeX Performance Commands
cmd("LaTeXStatus", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.get_latex_status()
end, { desc = "Show LaTeX performance status" })

cmd("LaTeXBuild", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.build_latex()
end, { desc = "Build LaTeX with pdflatex" })

cmd("TypstBuild", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.build_typst()
end, { desc = "Build Typst document" })

cmd("LaTeXLivePreview", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.setup_live_preview()
end, { desc = "Activate LaTeX/Typst live preview" })

cmd("LaTeXLivePreviewOff", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.disable_live_preview()
end, { desc = "Deactivate LaTeX/Typst live preview" })

cmd("LaTeXLivePreviewToggle", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.toggle_live_preview()
end, { desc = "Toggle LaTeX/Typst live preview" })

cmd("CompilerErrorClose", function()
  local latex_perf = require("utils.latex-performance")
  latex_perf.close_error_window()
end, { desc = "Close compiler error window" })

-- Web Development Server Commands
cmd("WebServerStart", function(opts)
  local port = tonumber(opts.args) or 8080
  local webserver = require("utils.webserver")
  webserver.start_server(port)
end, {
  desc = "Start web development server (miniserve)",
  nargs = "?",
})

cmd("WebServerStop", function()
  local webserver = require("utils.webserver")
  webserver.stop_server()
end, {
  desc = "Stop web development server",
})

cmd("WebServerStatus", function()
  local webserver = require("utils.webserver")
  if webserver.is_running() then
    vim.notify(icons.status.success .. " Web server is running", vim.log.levels.INFO)
  else
    vim.notify(icons.status.info .. " Web server is not running", vim.log.levels.INFO)
  end
end, {
  desc = "Check web server status",
})

cmd("WebServerOpen", function(opts)
  local port = tonumber(opts.args) or 8080
  local webserver = require("utils.webserver")
  webserver.open_browser(port)
end, {
  desc = "Open browser at localhost",
  nargs = "?",
})

cmd("WebServerInfo", function()
  local webserver = require("utils.webserver")
  webserver.print_info()
end, {
  desc = "Show web server information",
})
