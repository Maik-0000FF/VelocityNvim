-- ~/.config/VelocityNvim/lua/plugins/native-lsp.lua
-- Modern LSP Setup with vim.lsp.config API and VelocityNvim features
-- Uses global configuration pattern for better performance and cleaner code

local icons = require("core.icons")

-- PERFORMANCE: Pre-cached severity icon tables (avoid recreation on every diagnostic)
local SEVERITY_ICONS = {
  [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
  [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
  [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
  [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
}

local SEVERITY_ICONS_FLOAT = {
  [vim.diagnostic.severity.ERROR] = icons.diagnostics.error .. " ERROR",
  [vim.diagnostic.severity.WARN] = icons.diagnostics.warn .. " WARN",
  [vim.diagnostic.severity.INFO] = icons.diagnostics.info .. " INFO",
  [vim.diagnostic.severity.HINT] = icons.diagnostics.hint .. " HINT",
}

-- Diagnostic configuration with modern API (signs.text replaces sign_define)
vim.diagnostic.config({
  virtual_text = {
    -- PERMANENTLY VISIBLE: Icons stay visible during cursor movement
    prefix = function(diagnostic)
      return SEVERITY_ICONS[diagnostic.severity] or "●"
    end,
    spacing = 2,
    source = "if_many",
    -- CRITICAL: suffix prevents text from disappearing during cursor movement
    suffix = "",
    format = function(diagnostic)
      return diagnostic.message
    end,
  },
  signs = {
    text = SEVERITY_ICONS,
  },
  update_in_insert = false, -- Performance: no updates during Typing
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "if_many",
    prefix = function(diagnostic)
      return SEVERITY_ICONS_FLOAT[diagnostic.severity] or "●", ""
    end,
    format = function(diagnostic)
      return diagnostic.message
    end,
  },
})

-- MODERN LSP API: Global configuration for all servers
-- Performance-optimized capabilities with completion support
local function setup_global_lsp_config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Enhanced completion capabilities
  capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
      },
    },
  }

  -- Global LSP configuration for ALL servers
  vim.lsp.config("*", {
    capabilities = capabilities,
    on_init = function(client, _)
      -- PERFORMANCE: Disable semantic tokens for better responsiveness
      -- Cross-version compatibility - simplified
      local supports_method_fn = client.supports_method or function(_, method)
        return client:supports_method(method)
      end

      if supports_method_fn(client, "textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
      end
    end,
  })
end

-- Call global setup
setup_global_lsp_config()

-- Intelligent Lua library detection (MyNvim-Style - NO SYSTEM CALLS)
local function get_targeted_lua_libraries()
  local libraries = {}
  local project_root = vim.fn.getcwd()

  -- 1. ALWAYS: Neovim Core APIs (essential for vim.* completion)
  local nvim_runtime_paths = vim.api.nvim_get_runtime_file("lua/vim", false)
  if #nvim_runtime_paths > 0 then
    local nvim_lua_dir = vim.fn.fnamemodify(nvim_runtime_paths[1], ":p:h:h")
    table.insert(libraries, nvim_lua_dir)
  end

  -- 2. CONDITIONAL: Plugin-specific libraries only when loaded (MyNvim-Style)
  local function is_plugin_loaded(plugin_name)
    return package.loaded[plugin_name] ~= nil
  end

  local function find_plugin_library(plugin_name)
    local possible_paths = {
      vim.fn.stdpath("data") .. "/site/pack/user/start/" .. plugin_name .. "/lua",
      vim.fn.expand("~/.local/share/VelocityNvim/site/pack/user/start/" .. plugin_name .. "/lua"),
    }

    for _, path in ipairs(possible_paths) do
      if vim.fn.isdirectory(path) == 1 then
        return vim.fn.resolve(path)
      end
    end
    return nil
  end

  -- Check for frequently used plugins (only if loaded - MyNvim-Style)
  local common_plugins = {
    { module = "telescope", dir = "telescope.nvim" },
    { module = "fzf-lua", dir = "fzf-lua" },
    { module = "blink.cmp", dir = "blink.cmp" },
    { module = "neo-tree", dir = "neo-tree.nvim" },
    { module = "which-key", dir = "which-key.nvim" },
    { module = "lualine", dir = "lualine.nvim" },
    { module = "alpha", dir = "alpha-nvim" },
    { module = "gitsigns", dir = "gitsigns.nvim" },
  }

  for _, plugin in ipairs(common_plugins) do
    if is_plugin_loaded(plugin.module) then
      local plugin_lib = find_plugin_library(plugin.dir)
      if plugin_lib then
        table.insert(libraries, plugin_lib)
      end
    end
  end

  -- 3. PROJECT-SPECIFIC: Local Lua modules in current project
  local local_lua_dirs = {
    project_root .. "/lua",
    project_root .. "/scripts/lua",
    project_root .. "/config/lua",
  }

  for _, dir in ipairs(local_lua_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      table.insert(libraries, vim.fn.resolve(dir))
    end
  end

  -- 4. VelocityNvim specific modules (always add for this config)
  local velocitynvim_lua_dir = vim.fn.expand("~/.config/VelocityNvim/lua")
  if vim.fn.isdirectory(velocitynvim_lua_dir) == 1 then
    table.insert(libraries, velocitynvim_lua_dir)
  end

  -- Libraries are optimized - no debug output needed

  return libraries
end

-- MODERN LSP CONFIG: Server-specific settings only (global config applied automatically)
-- Only settings, cmd, filetypes, root_markers - capabilities/on_init are global

vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" },
        workspaceDelay = 200, -- Performance: Longer delay for less frequent updates
      },
      workspace = {
        library = get_targeted_lua_libraries(), -- VelocityNvim: Intelligente Library-Erkennung
        checkThirdParty = false,
        maxPreload = 1500, -- Performance: Optimiert von 3000
        preloadFileSize = 3000, -- Performance: Optimiert von 5000
        useGitIgnore = false, -- Performance: No "filtering directories" messages
      },
      telemetry = { enable = false },
    },
  },
}

vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" }, -- VelocityNvim: Superior Python project detection
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
        autoImportCompletions = true,
      },
    },
  },
})

vim.lsp.config("texlab", {
  cmd = { "texlab" },
  filetypes = { "tex", "bib", "plaintex" },
  root_markers = { ".latexmkrc", ".git", "main.tex", "document.tex" }, -- VelocityNvim: LaTeX-specific project detection
  settings = {
    texlab = {
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = false,
        forwardSearchAfter = false,
      },
      forwardSearch = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
      },
      completion = { matcher = "fuzzy" },
      diagnostics = { ignoredPatterns = {} },
      formatterLineLength = 80,
      latexFormatter = "latexindent",
      latexindent = { modifyLineBreaks = false },
    },
  },
})

vim.lsp.config("htmlls", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "templ" },
  root_markers = { "package.json", ".git", "index.html" }, -- VelocityNvim: Web project detection
  init_options = {
    configurationSection = { "html", "css", "javascript" },
    embeddedLanguages = {
      css = true,
      javascript = true,
    },
    provideFormatter = true,
  },
  settings = {
    html = {
      validate = true,
      autoClosingTags = true,
      autoCreateQuotes = true,
      completion = {
        attributeDefaultValue = "doublequotes",
      },
    },
  },
})

vim.lsp.config("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", ".git", "style.css", "styles.css" }, -- VelocityNvim: CSS naming conventions
  settings = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = "ignore",
      },
    },
    less = {
      validate = true,
      lint = {
        unknownAtRules = "ignore",
      },
    },
    scss = {
      validate = true,
      lint = {
        unknownAtRules = "ignore",
      },
    },
  },
})

-- PERFORMANCE: Cached TypeScript path lookup (avoids expensive npm shell calls)
local cached_tsserver_path = nil
local ts_warning_shown = false
local function find_tsserver_path()
  if cached_tsserver_path then
    return cached_tsserver_path
  end

  -- 1. System paths first (fast file checks, no subprocess)
  local system_paths = {
    "/usr/lib/node_modules/typescript/lib/tsserver.js",
    "/usr/share/typescript/lib/tsserver.js",
  }
  for _, path in ipairs(system_paths) do
    if vim.fn.filereadable(path) == 1 then
      cached_tsserver_path = path
      return path
    end
  end

  -- 2. Local workspace (fast file check)
  local local_ts = vim.fn.getcwd() .. "/node_modules/typescript/lib/tsserver.js"
  if vim.fn.filereadable(local_ts) == 1 then
    cached_tsserver_path = local_ts
    return local_ts
  end

  -- 3. Global npm (expensive - only as last resort)
  local global_npm = vim.fn.system("npm root -g 2>/dev/null"):gsub("%s+", "")
  if vim.v.shell_error == 0 and global_npm ~= "" then
    local global_ts = global_npm .. "/typescript/lib/tsserver.js"
    if vim.fn.filereadable(global_ts) == 1 then
      cached_tsserver_path = global_ts
      return global_ts
    end
  end

  -- 4. Not found - show hint once
  if not ts_warning_shown then
    ts_warning_shown = true
    vim.defer_fn(function()
      vim.notify("TypeScript not found. Install with: npm install -g typescript", vim.log.levels.WARN)
    end, 1000)
  end
  return nil
end

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", ".git", "node_modules" },
  init_options = {
    hostInfo = "neovim",
    preferences = {
      disableSuggestions = false,
      includeCompletionsForImportStatements = true,
    },
    tsserver = {
      path = find_tsserver_path(),
    },
  },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
})

-- ADAPTIVE Rust-Analyzer Configuration (VelocityNvim Ultimate Performance 2025)
local function get_adaptive_rust_config()
  local rust_perf = require("utils.rust-performance")
  local analysis = rust_perf.analyze_rust_ecosystem()
  local total_memory_gb = analysis.toolchain.total_memory_gb

  -- Get physical CPU core count for optimal threading
  local cpu_cores = tonumber(vim.fn.system("nproc 2>/dev/null")) or 4

  -- 2025 Base Configuration mit modernen Optimierungen
  local base_config = {
    cargo = {
      loadOutDirsFromCheck = true,
      buildScripts = { enable = true },
      -- 2025 NEW: Separate target directory to prevent interference
      targetDir = "target/rust-analyzer",
    },
    checkOnSave = {
      command = "cargo",
      extraArgs = { "clippy" },
    },
    lens = {
      enable = true,
      references = { adt = { enable = true } },
      methodReferences = { enable = true },
      enumVariantReferences = { enable = true },
    },
    inlayHints = {
      bindingModeHints = { enable = false },
      chainingHints = { enable = true },
      closingBraceHints = { enable = true, minLines = 25 },
      closureReturnTypeHints = { enable = "never" },
      lifetimeElisionHints = { enable = "never", useParameterNames = false },
      maxLength = 25,
      parameterHints = { enable = true },
      reborrowHints = { enable = "never" },
      renderColons = true,
      typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
    },
    completion = {
      callable = { snippets = "fill_arguments" },
    },
    -- 2025 NEW: Auto-detect optimal thread count
    numThreads = nil, -- null = auto-detection (recommended 2025)
    -- 2025 NEW: LRU optimization based on available memory
    lru = {
      capacity = math.min(2048, math.max(128, total_memory_gb * 32)), -- Dynamic LRU scaling
    },
  }

  -- Memory-based adaptive optimizations (2025 Enhanced)
  if total_memory_gb >= 32 then
    -- Ultra-High-Performance Configuration (32+ GB RAM) - NEW TIER!
    base_config.cargo.allFeatures = true
    base_config.cargo.runBuildScripts = true
    base_config.checkOnSave.allFeatures = true
    base_config.procMacro = { enable = true, ignored = {} }
    base_config.workspace = { symbol = { search = { scope = "workspace_and_dependencies" } } }
    base_config.cachePriming = {
      enable = true,
      numThreads = cpu_cores, -- Use all physical cores
    }
    base_config.lru.capacity = 2048 -- Max LRU for ultra performance
    -- 2025 NEW: Memory limit for large projects
    base_config.memoryLimit = 8192 -- 8GB limit for rust-analyzer
  elseif total_memory_gb >= 16 then
    -- High-Performance Configuration (16-31 GB RAM) - UPDATED
    base_config.cargo.allFeatures = true
    base_config.cargo.runBuildScripts = true
    base_config.checkOnSave.allFeatures = true
    base_config.procMacro = { enable = true, ignored = {} }
    base_config.workspace = { symbol = { search = { scope = "workspace_and_dependencies" } } }
    base_config.cachePriming = {
      enable = true,
      numThreads = math.min(cpu_cores, 8), -- Cap at 8 threads
    }
    base_config.lru.capacity = 1024
    base_config.memoryLimit = 4096 -- 4GB limit
  elseif total_memory_gb >= 8 then
    -- Balanced Configuration (8-15 GB RAM) - UPDATED
    base_config.cargo.allFeatures = false
    base_config.cargo.runBuildScripts = true
    base_config.checkOnSave.allFeatures = false
    base_config.procMacro = {
      enable = true,
      ignored = { "async-trait", "napi-derive", "async-recursion" },
    }
    base_config.cachePriming = {
      enable = true,
      numThreads = math.min(cpu_cores, 4),
    }
    base_config.lru.capacity = 512
    base_config.memoryLimit = 2048 -- 2GB limit
  else
    -- Conservative Configuration (<8 GB RAM) - UPDATED
    base_config.cargo.allFeatures = false
    base_config.cargo.runBuildScripts = false
    base_config.checkOnSave.allFeatures = false
    base_config.checkOnSave.command = "check" -- Faster than clippy
    base_config.procMacro = { enable = false }
    base_config.cachePriming = {
      enable = false, -- Disable cache priming for low memory
    }
    base_config.lru.capacity = 128 -- Keep default
    base_config.memoryLimit = 1024 -- 1GB limit
    -- Reduce features for lower memory usage
    base_config.lens.enable = false
    base_config.inlayHints.chainingHints.enable = false
  end

  return base_config
end

vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
  settings = {
    ["rust-analyzer"] = get_adaptive_rust_config(), -- VelocityNvim: Adaptive memory-based configuration
  },
})

vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { "package.json", ".git" },
  init_options = {
    provideFormatter = true,
  },
  settings = {
    json = {
      validate = { enable = true },
    },
  },
})

vim.lsp.config("tinymist", {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { "typst.toml", ".git", "main.typ" }, -- VelocityNvim: Typst project detection
  settings = {
    formatterMode = "typstyle", -- Formatter: typstyle (recommended) or typstfmt
    exportPdf = "onSave", -- PDF-Export: onType, onSave, never
    semanticTokens = "disable", -- Performance: Semantic tokens disabled (global config)
  },
})

-- LSP Attach Handler (consolidated from autocmds.lua)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if not client then
      return
    end

    -- Buffer-local settings
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Enable inlay hints
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })

    -- Buffer-lokale Keymaps
    local opts = { buffer = bufnr }

    -- Standard LSP-Navigation
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

    -- PRODUCTIVE Diagnostic navigation with icons
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, vim.tbl_extend("force", opts, { desc = "Next diagnostic (with float info)" }))

    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic (with float info)" }))

    vim.keymap.set("n", "]e", function()
      vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
    end, vim.tbl_extend("force", opts, { desc = "Next error (with float info)" }))

    vim.keymap.set("n", "[e", function()
      vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
    end, vim.tbl_extend("force", opts, { desc = "Previous error (with float info)" }))

    -- Diagnostic floating window for current line (COLLISION FIXED: <leader>e -> <leader>dl)
    vim.keymap.set("n", "<leader>dl", function()
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor" })
    end, vim.tbl_extend("force", opts, { desc = "Show diagnostic under cursor" }))

    -- Show all diagnostics for buffer
    vim.keymap.set("n", "<leader>dq", function()
      vim.diagnostic.setqflist({ open = true })
    end, vim.tbl_extend("force", opts, { desc = "All diagnostics in quickfix" }))

    -- LaTeX-specific keymaps
    if client.name == "texlab" then
      vim.keymap.set("n", "<leader>lb", function()
        vim.lsp.buf_request(bufnr, "workspace/executeCommand", {
          command = "texlab.build",
          arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
        })
      end, vim.tbl_extend("force", opts, { desc = "Build LaTeX" }))

      vim.keymap.set("n", "<leader>lv", function()
        local win = vim.api.nvim_get_current_win()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local position = { line = cursor[1] - 1, character = cursor[2] }
        vim.lsp.buf_request(bufnr, "workspace/executeCommand", {
          command = "texlab.forwardSearch",
          arguments = { { uri = vim.uri_from_bufnr(bufnr), position = position } },
        })
      end, vim.tbl_extend("force", opts, { desc = "Forward Search" }))

      vim.keymap.set("n", "<leader>lc", function()
        vim.lsp.buf_request(bufnr, "workspace/executeCommand", {
          command = "texlab.cleanAuxiliary",
          arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
        })
      end, vim.tbl_extend("force", opts, { desc = "Clean LaTeX" }))
    end
  end,
})

-- MODERN LSP ACTIVATION: Dynamic activation based on optional features
-- Core LSP servers (always enabled)
vim.lsp.enable("lua_ls")        -- Lua with intelligent library detection
vim.lsp.enable("pyright")       -- Python with superior project detection
vim.lsp.enable("htmlls")        -- HTML with web project detection
vim.lsp.enable("cssls")         -- CSS with naming convention support
vim.lsp.enable("ts_ls")         -- TypeScript with comprehensive configuration
vim.lsp.enable("jsonls")        -- JSON for package.json and config files
vim.lsp.enable("rust_analyzer") -- Rust with adaptive memory configuration (if available)

-- Optional LSP servers (enabled based on optional-features.json)
local manage_ok, manage = pcall(require, "plugins.manage")
if manage_ok then
  -- LaTeX support (optional)
  if manage.is_feature_enabled("latex") then
    vim.lsp.enable("texlab")    -- LaTeX with specialized root markers
  end

  -- Typst support (optional)
  if manage.is_feature_enabled("typst") then
    vim.lsp.enable("tinymist")  -- Typst with PDF export on save
  end
end

-- LspStatus Command is now handled in core/commands.lua