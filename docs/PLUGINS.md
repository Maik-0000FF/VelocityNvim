# VelocityNvim Plugin Management & Solutions

Eine umfassende Anleitung für Plugin-Management, erweiterte Lösungen und Commands in VelocityNvim.

---

## 🔌 **PLUGIN MANAGEMENT - ADVANCED WORKFLOW**

### Adding New Plugins (UPDATED - 2025-08-31)
1. **Add to Registry** (`lua/plugins/manage.lua`):
   ```lua
   M.plugins["plugin-name"] = "https://github.com/user/plugin.git"
   ```

2. **Create Configuration** (`lua/plugins/category/plugin-name.lua`):
   ```lua
   -- Use safe loading pattern
   local ok, plugin = pcall(require, "plugin-name")
   if not ok then
     return
   end

   plugin.setup({
     -- Configuration hier
   })
   ```

3. **Add to Plugin Loader** (`lua/plugins/init.lua`):
   ```lua
   safe_require("plugins.category.plugin-name")
   ```

4. **Install & Test**:
   ```bash
   :PluginSync         # Install plugin
   :VelocityHealth     # Verify functionality
   ```

5. **POST-INSTALLATION CHECKS** (CRITICAL):
   - ✅ Check für Keymap Flash-Probleme: `grep -r '":.*<CR>' lua/plugins/`
   - ✅ Für Rust-Plugins: Verify build process
   - ✅ Update DEPENDENCIES.md wenn nötig

### Plugin Installation Path
`~/.local/share/VelocityNvim/site/pack/user/start/[plugin-name]/`

### CRITICAL: Post-Update Procedures

**Nach jedem `:PluginSync` IMMER ausführen:**

1. **Rust-Plugin Check**:
   ```bash
   cd ~/.local/share/VelocityNvim/site/pack/user/start/blink.cmp
   if [ -f "Cargo.toml" ]; then
     cargo build --release
   fi
   ```

2. **Keymap Flash Detection**:
   ```bash
   grep -r '":.*<CR>' ~/.config/VelocityNvim/lua/plugins/
   # Falls gefunden: Umstellen auf <cmd>...<CR>
   ```

3. **Health Verification**:
   ```bash
   NVIM_APPNAME=VelocityNvim nvim --headless -c "VelocityHealth" -c "qall"
   ```

### Plugin Categories & Performance Optimization

**UI Plugins** (`lua/plugins/ui/`):
- alpha, tokyonight, bufferline, lualine, noice
- **Performance**: Lazy loading, minimal configuration

**Editor Plugins** (`lua/plugins/editor/`):
- neo-tree, which-key, hlchunk, nvim-treesitter, **nvim-window-picker**
- **Performance**: Event-based loading, caching

**LSP Plugins** (`lua/plugins/lsp/`):
- blink-cmp, native-lsp, lsp-debug
- **Performance**: Rust-optimized when available

**Tools** (`lua/plugins/tools/`):
- fzf-lua, conform, gitsigns
- **Performance**: External tools integration

---

## 🆕 **ADVANCED PLUGIN SOLUTIONS (2025-08-31)**

### Window Picker Implementation - Ultra-Performance Solution

**Problem**: Multi-Window Navigation ineffizient, keine visuelle Window-Auswahl verfügbar.

**Lösung**: `nvim-window-picker` - Der performanteste verfügbare Window Picker:

#### Warum dieser Window Picker gewählt wurde:
- ✅ **Pure Lua** - <300 LoC, minimaler Footprint
- ✅ **Floating Big Letters** - Riesige Buchstaben mitten im Window (A,B,C,D...)
- ✅ **Lazy Loading** - 0ms Overhead bis zur Aktivierung
- ✅ **Native APIs** - Keine Legacy-Vim Kompatibilität
- ✅ **Tokyo Night optimiert** - Perfekte Farbintegration

#### Installation & Konfiguration:
```lua
-- plugins/manage.lua
["nvim-window-picker"] = "https://github.com/s1n7ax/nvim-window-picker",

-- plugins/editor/nvim-window-picker.lua - Performance-optimierte Konfiguration
window_picker.setup({
  hint = "floating-big-letter", -- Große schwebende Buchstaben im Window
  selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
  picker_config = {
    floating_big_letter = {
      font = "ansi-shadow", -- Großer ASCII-Art Stil
    },
  },
  highlights = {
    floating_big_letter = {
      fg = "#f7dc6f", -- Helles Gelb (sehr kontrastreich)
      bg = "#1a1b26", -- Tokyo Night bg
      bold = true,
    },
  },
})
```

#### Keybindings:
- `<leader>wp` → Pick Window (interaktive Auswahl)
- `<leader>ws` → Swap Window Contents
- `w` (in Neo-tree) → Open file in picked window

#### Visual Experience:
```
┌─────────────────┐  ┌─────────────────┐
│                 │  │                 │
│        A        │  │        B        │  <- RIESIGE Buchstaben
│                 │  │                 │
└─────────────────┘  └─────────────────┘
```

---

### SudaWrite Implementation - Sudo File Editing

**Problem**: Bearbeitung von Systemdateien ohne Root-Rechte nicht möglich.

**Lösung**: `suda.vim` - Minimaler, effizienter Sudo-Editor:

#### Warum SudaWrite gewählt wurde:
- ✅ **Minimaler Footprint** - Reines Vim-Plugin, <200 LoC
- ✅ **Smart Detection** - Erkennt automatisch wenn Sudo-Rechte benötigt werden
- ✅ **Transparent Integration** - Funktioniert mit bestehenden Workflows
- ✅ **Security First** - Keine permanenten Berechtigungen, nur bei Bedarf

#### Installation & Konfiguration:
```lua
-- plugins/manage.lua
["suda.vim"] = "https://github.com/lambdalisue/suda.vim",

-- plugins/tools/suda.lua - Performance-optimierte Konfiguration
vim.g.suda_smart_edit = 1  -- Automatisch sudo verwenden wenn benötigt
```

#### Keybindings:
- `<leader>W` → Schreibe Datei mit Sudo-Rechten
- `:sw` → Kurzer Alias für `:SudaWrite`
- `:SudaWrite` → Vollständiger Command
- `:SudaRead` → Datei mit Sudo-Rechten lesen

#### Usage Examples:
```bash
# Systemdateien direkt bearbeiten:
NVIM_APPNAME=VelocityNvim nvim sudo:///etc/hosts
NVIM_APPNAME=VelocityNvim nvim /etc/nginx/nginx.conf

# In Neovim:
:sw                    # Quick save with sudo
:SudaWrite             # Full command
<leader>W              # Keymap
```

---

### Hop Implementation - Ultra-Fast Cursor Navigation

**Problem**: Ineffiziente Cursor-Navigation in großen Dateien.

**Lösung**: `hop.nvim` - Der performanteste Cursor-Jumper:

#### Warum Hop gewählt wurde:
- ✅ **Pure Lua** - Native Neovim Performance, keine externe Dependencies
- ✅ **Home-Row Optimiert** - Verwendet nur die schnellsten Tasten
- ✅ **Visual Feedback** - Klare, kontrastreichere Hints
- ✅ **Multiple Modes** - Zeichen, Wort, Zeile, Pattern, überall

#### Installation & Konfiguration:
```lua
-- plugins/manage.lua
["hop.nvim"] = "https://github.com/phaazon/hop.nvim",

-- plugins/editor/hop.lua - Performance-optimierte Konfiguration
hop.setup({
  keys = 'etovxqpdygfblzhckisuran',  -- Home-Row optimiert
  jump_on_sole_occurrence = true,    -- Direkt springen bei einem Treffer
  case_insensitive = true,           -- Groß-/Kleinschreibung ignorieren
})
```

#### Keybindings (Optimiert für Wortanfang):
**Basis-Navigation:**
- `f` → Hop zu Zeichen (1 Char)
- `F` → Hop zu Zeichen (2 Chars)

**Wort-Navigation:**
- `<leader>hw` → Hop zu **Wortanfang** (optimiert!)
- `<leader>hW` → Hop zu Wortende
- `<leader>hb` → Hop zu Wort (beide Richtungen)

**Erweiterte Navigation:**
- `<leader>hl` → Hop zu Zeile
- `<leader>hL` → Hop zu Zeilenanfang
- `<leader>hp` → Hop zu Pattern
- `<leader>hv` → Hop vertikal
- `<leader>ha` → Hop überall hin

#### Visual Experience:
```
function myFunction() {
   a    b      c    d
  let variable = getValue();
      e        f      g
  return processData(variable);
         h         i
}
```
Nach `<leader>hw`: Jeder Wortanfang bekommt einen Hint-Buchstaben.

#### Performance-Features:
- **Single-Key Jumps**: Bei eindeutigen Zielen sofort springen
- **Visual Mode Support**: Alle Keymaps funktionieren auch in Visual Mode
- **Multi-Window**: Optional für window-übergreifende Navigation

---

### blink.cmp Rust Performance - Critical Build Solutions

**CRITICAL**: blink.cmp Rust-Implementation kann bei Plugin-Updates brechen.

#### Problem-Patterns:
- `Failed to setup fuzzy matcher and rust implementation forced`
- `attempt to call field 'nvim__api_info' (a nil value)`
- Performance-Verlust nach `:PluginSync`

#### Root Cause Analysis:
1. **Plugin-Updates** löschen kompilierte Rust-Binaries
2. **Version-Mismatches** zwischen blink.cmp und Rust-Binaries
3. **Force-Hooks** werden vor Build-Completion aufgerufen

#### DEFINITIVE LÖSUNG (Getested & Funktional):

**1. Nach Plugin-Updates IMMER Rust-Binaries neu kompilieren:**
```bash
cd ~/.local/share/VelocityNvim/site/pack/user/start/blink.cmp
cargo build --release
```

**2. Robuste Force-Implementation Konfiguration:**
```lua
-- plugins/lsp/blink-cmp-force-rust.lua - FUNKTIONIERENDE VERSION
local function force_rust_implementation()
    vim.defer_fn(function()
        local ok, fuzzy = pcall(require, 'blink.cmp.fuzzy')
        if ok then
            local rust_ok, _ = pcall(require, 'blink_cmp_fuzzy')
            if rust_ok then
                fuzzy.set_implementation('rust')
                -- Silent success - Rust performance aktiv
            else
                vim.notify("⚠️ Blink.cmp: Rust-Module nicht verfügbar - Fallback zu Lua", vim.log.levels.WARN)
            end
        end
    end, 500) -- Kurze Verzögerung für Plugin-Stabilisierung
end

-- Hook in die blink.cmp setup
local original_setup = require('blink.cmp').setup
require('blink.cmp').setup = function(opts)
    original_setup(opts)
    force_rust_implementation()
end
```

**3. PREVENTION für zukünftige Plugin-Updates:**
```bash
# Nach jedem :PluginSync automatisch ausführen:
cd ~/.local/share/VelocityNvim/site/pack/user/start/blink.cmp
if [ -f "Cargo.toml" ]; then
  cargo build --release
  echo "blink.cmp Rust binaries rebuilt"
fi
```

#### Performance-Status Verification:
```bash
# Test ob Rust aktiv ist:
NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local ok, fuzzy = pcall(require, 'blink.cmp.fuzzy'); if ok then print('Implementation:', fuzzy.get_implementation()) end" -c "qall"
```

---

### Delta Git Integration - Ultra-Performance Git Diffs

**Problem**: Standard Git-Diffs sind schwer lesbar und schlecht formatiert.

**Lösung**: `git-delta` - Der beste verfügbare Git-Diff-Renderer:

#### Warum Delta gewählt wurde:
- ✅ **Rust-Performance** - Deutlich schneller als standard Git-Diffs
- ✅ **Syntax-Highlighting** - Vollständige Code-Hervorhebung in Diffs
- ✅ **Line-by-Line Navigation** - Bessere visuelle Unterscheidung
- ✅ **Side-by-Side Mode** - Optional für komplexe Vergleiche
- ✅ **Integration Ready** - Native Unterstützung in gitsigns + fzf-lua

#### Installation:
```bash
# Arch Linux
sudo pacman -S git-delta

# Cargo (falls Paket nicht verfügbar)
cargo install git-delta
```

#### Integration Status:
- ✅ **Gitsigns Integration**: Enhanced diff previews mit delta
- ✅ **FZF-lua Integration**: Git commits, status, buffer commits mit delta
- ✅ **Status Checking**: `:DeltaStatus` Command verfügbar
- ✅ **Fallback System**: Automatischer Fallback zu standard Git wenn delta fehlt

#### Performance-Features:
- **Interactive Features**: Optimiert für fzf-lua Previews
- **Color-Only Mode**: Minimaler Overhead für Inline-Diffs
- **Histogram Algorithm**: Bessere Diff-Qualität als standard
- **Width Awareness**: Automatische Anpassung an Terminalbreite

#### Konfiguration (Automatisch):
```lua
-- gitsigns.lua - Enhanced diffs
local use_delta = vim.fn.executable("delta") == 1
diff_opts = use_delta and {
  algorithm = "histogram",
  internal = false,
  external = "delta --color-only --features=interactive",
} or nil,

-- fzf-lua.lua - Git previews
git = {
  status = {
    preview_pager = "delta --features=interactive --width=$FZF_PREVIEW_COLUMNS",
  },
  commits = {
    preview = "git show --color=always {1} | delta --features=interactive",
  },
}
```

#### Testing Delta:
```bash
# Status check
:DeltaStatus

# Test gitsigns diff
<leader>hp    # Preview hunk inline (mit delta wenn verfügbar)

# Test fzf-lua Git integration
<leader>gs    # Git status (mit delta previews)
<leader>gc    # Git commits (mit delta previews)
```

#### Visual Experience:
- **Standard Git**: Schwer lesbare +/- Zeilen in Terminal-Farben
- **Mit Delta**: Farbkodierte Syntax-Highlighting mit klaren Blöcken
- **Side-by-Side**: Optional für komplexe Merges/Konflikte

---

### Keymap Flash Solutions - UI-Optimierung

**Problem**: Plugin-Commands zeigen störende Commandline (`:command<CR>`)

**Lösung**: Systematische Umstellung auf `<cmd>command<CR>`

#### Das Flash-Problem:
- `:Neotree focus<CR>` → Zeigt Commandline kurz auf (visuell störend)
- `<cmd>Neotree focus<CR>` → Unsichtbare Ausführung (smooth UX)

#### Regex für Problem-Detection:
```bash
grep -r '":.*<CR>' lua/plugins/ lua/core/
```

#### Kategorisierung & Lösung:

**🔧 ZU BEHEBEN** (Plugin/Custom Commands):
```lua
-- ❌ WRONG - causes flash
vim.keymap.set("n", "<leader>e", ":Neotree focus<CR>")

-- ✅ CORRECT - smooth execution
vim.keymap.set("n", "<leader>e", "<cmd>Neotree focus<CR>")
```

**✅ BEHALTEN** (Native Vim Commands):
```lua
-- Diese sind OK - Commandline-Anzeige erwünscht
map("n", "<C-Up>", ":resize +1<CR>", opts)
map("n", "<leader>w", ":w<CR>", opts)
map("n", "<leader>q", ":q<CR>", opts)
```

#### Systematische Fix-Patterns:

**Alpha Dashboard:**
```lua
dashboard.button("f", "  Find file", "<cmd>Neotree reveal<CR>"), -- statt ":Neotree reveal<CR>"
```

**BufferLine:**
```lua
vim.keymap.set("n", "<leader>j", "<cmd>BufferLineCycleNext<CR>") -- statt ":BufferLineCycleNext<CR>"
```

**LaTeX Commands:**
```lua
map("n", "\\b", "<cmd>LaTeXBuildTectonic<CR>") -- statt ":LaTeXBuildTectonic<CR>"
```

#### Automated Detection:
```lua
-- Plugin-Update Checker für Flash-Probleme
local function check_keymap_flash()
    local problematic = vim.fn.system("grep -r '\":.*<CR>' " .. vim.fn.stdpath("config"))
    if #problematic > 0 then
        vim.notify("⚠️ Keymap Flash detected - check PLUGINS.md for fixes", vim.log.levels.WARN)
    end
end
```

---

## 🎛️ **FORMATTER SYSTEM (UPDATED - 2025-08-30)**
**Ruff-basierte Python-Formatierung (Rust-basiert, deutlich schneller):**

#### Installation
```bash
sudo pacman -S ruff  # Arch Linux
# oder
pip install ruff
```

#### Konfiguration (lua/plugins/tools/conform.lua)
```lua
formatters_by_ft = {
  python = { "ruff_organize_imports", "ruff_format" },
},

formatters = {
  ruff_format = {
    command = "ruff",
    args = { "format", "--line-length=88", "--stdin-filename", "$FILENAME", "-" },
    stdin = true,
  },
  ruff_organize_imports = {
    command = "ruff",
    args = { "check", "--select=I", "--fix", "--stdin-filename", "$FILENAME", "-" },
    stdin = true,
  },
}
```

#### Fehlerbehebung
- **Timeout-Fehler**: Timeout von 500ms auf 2000ms erhöht
- **Performance**: Rust-basiertes `ruff` ersetzt langsamere Python-Tools
- **Kompatibilität**: Black-kompatible Einstellungen beibehalten
- **Logs**: Check `/home/neo/.local/state/VelocityNvim/conform.log`

---

## 📋 **COMMANDS REFERENCE**

### Health & Diagnostics
- `:VelocityHealth` - Full VelocityNvim health check
- `:checkhealth velocitynvim` - Native Neovim health check
- `:VelocityInfo` - System information with version details

### Plugin Management
- `:PluginSync` - Sync all plugins
- `:PluginStatus` - Show installation status

### Version Management
- `:VelocityNvimVersion` - Show version info
- `:VelocityNvimChangelog` - Show version history
- `:VelocityNvimResetVersion` - Reset version tracking

### LSP & Development
- `:LspStatus` - Enhanced LSP information
- `:LspRestart` - Restart LSP clients
- `:LspRefresh` - Trigger workspace rescan without restart
- `:LuaLibraryStatus` - Show Lua library optimization metrics (75% faster startup!)
- `:DiagnosticTest` - Show diagnostic icons configuration and navigation shortcuts
- `:FormatInfo` - Show formatter status

### Window Management (NEW - 2025-08-31)
- `<leader>wp` - **Pick Window** (interaktive Auswahl mit großen Buchstaben)
- `<leader>ws` - **Swap Window Contents**
- `w` (in Neo-tree) - **Open file in picked window**

### LaTeX Suite
- `\s` - LaTeX Performance Status
- `\i` - Live Preview aktivieren
- `\b` - Build mit Tectonic (Ultra-Fast)
- `\B` - Build mit Typst (Modern)

### Git Performance (NEW - 2025-08-31)
- `:DeltaStatus` - Check delta git integration status
- `<leader>hp` - Preview hunk inline (enhanced with delta)
- `<leader>gs` - Git status with delta previews
- `<leader>gc` - Git commits with delta previews

### Performance & Debug
- `:RustPerformanceStatus` - Check Rust tool availability
- `:RustBuildBlink` - Force rebuild blink.cmp Rust binaries
- `:RustOptimize` - Optimize Neovim for Rust performance
- `:RustBenchmark` - Benchmark fuzzy matching performance

### Rust Performance Suite (NEW - 2025-09-01)
- `:RustUltimateSetup` - Performance analysis and setup
- `:RustUltimateBenchmark` - Comprehensive performance scoring
- `:RustAnalyzeEcosystem` - Hardware & toolchain analysis
- `:RustAdaptiveLSP` - RAM-basierte rust-analyzer Konfiguration
- `:RustCrossSetup` - Cross-compilation targets management
- `:RustCargoUltra` - Fat-LTO cargo profile setup

### Color Highlighting Suite (NEW - 2025-09-01)
- `:ColorizerStatus` - Show nvim-colorizer.lua status and usage
- `:ColorizerToggle` - Toggle color highlighting on/off
- `:ColorizerReloadAllBuffers` - Reload colorizer for all buffers
- `<leader>ct` - Quick toggle colorizer
- `<leader>cr` - Quick reload colorizer

---

Diese Datei enthält alle Plugin-spezifischen Informationen, Lösungen und Commands für VelocityNvim. Für allgemeine Development-Guidelines siehe [DEVELOPMENT.md](./DEVELOPMENT.md).