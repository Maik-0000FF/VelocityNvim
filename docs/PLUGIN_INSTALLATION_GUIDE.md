# Plugin Installation Guide - Complete Checklist

Eine vollständige Anleitung für das Hinzufügen neuer Plugins zu VelocityNvim.

Basierend auf der vim-startuptime Implementation (2025-10-01).

---

## 📋 Plugin Installation Checklist

### Phase 1: Plugin-Integration (Code)

#### 1.1 Plugin zum Registry hinzufügen
**Datei:** `lua/plugins/manage.lua`

```lua
M.plugins["plugin-name"] = "https://github.com/author/plugin-repo"
```

---

#### 1.2 Plugin-Konfiguration erstellen
**Datei:** `lua/plugins/[category]/plugin-name.lua`

```lua
-- lua/plugins/[category]/plugin-name.lua
local M = {}

function M.setup()
  local icons = require("core.icons")

  -- Plugin mit pcall sicher laden
  local ok, plugin = pcall(require, "plugin-name")
  if not ok then
    vim.notify("Plugin nicht geladen: plugin-name", vim.log.levels.WARN)
    return
  end

  -- Plugin-Konfiguration
  plugin.setup({
    -- Optionen hier
  })

  -- Optional: Commands erstellen
  vim.api.nvim_create_user_command("PluginCommand", function()
    -- Command-Logik
  end, {
    desc = "Command Beschreibung",
  })

  -- Optional: Keymaps erstellen
  vim.keymap.set("n", "<leader>xy", "<cmd>PluginCommand<CR>", {
    desc = icons.status.icon .. " Keymap Beschreibung",
    silent = true,
  })
end

return M
```

**Wichtig:**
- Immer `pcall()` für `require()` verwenden
- Icons aus `core.icons` nutzen (keine Emojis)
- `<cmd>Command<CR>` statt `:Command<CR>` (vermeidet Flash)

---

#### 1.3 Plugin-Loader aktualisieren
**Datei:** `lua/plugins/init.lua`

**Sofortiges Laden:**
```lua
safe_require("plugins.category.plugin-name")
```

**Verzögertes Laden:**
```lua
vim.defer_fn(function()
  safe_require("plugins.category.plugin-name")
end, 100) -- 100ms delay
```

---

### Phase 2: UI-Integration (optional)

#### 2.1 Dashboard-Integration
**Datei:** `lua/plugins/ui/alpha.lua`

```lua
dashboard.button("x", icons.category.icon .. " Button Text", "<cmd>PluginCommand<CR>"),
```

#### 2.2 Icon-Anforderungen
**Datei:** `lua/core/icons.lua` (falls neue Icons benötigt)

Icons von: https://www.nerdfonts.com/cheat-sheet

---

### Phase 3: Dokumentation

#### 3.1 README.md
1. Performance Table: Plugin count aktualisieren
2. Acknowledgments: Plugin hinzufügen

#### 3.2 docs/PLUGINS.md
Neue Plugin-Sektion mit:
- Problem/Lösung
- Installation & Konfiguration
- Keybindings
- Usage Examples

Commands Reference aktualisieren.

#### 3.3 lua/plugins/DEPENDENCIES.md
- Neue Dependency-Sektion
- Load Order aktualisieren

#### 3.4 docs/ARCHITECTURE.md
- Plugin Registry Beispiel (count aktualisieren)
- Quality Metrics (count + Plugin-Name)

#### 3.5 docs/BENCHMARKS.md (bei Performance-Plugins)
- Key Metrics: Plugin count
- Neue Benchmark-Version
- benchmark_results.csv aktualisieren

#### 3.6 CHANGELOG.md
```markdown
### Added
- **plugin-name** - Description
```

#### 3.7 INSTALLATION.md
Plugin count an 2 Stellen aktualisieren.

---

### Phase 4: Testing

#### 4.1 Installation Test
```bash
NVIM_APPNAME=VelocityNvim nvim -c "PluginSync" -c "qall"
```

Im Neovim prüfen:
```vim
:PluginStatus
:checkhealth
:PluginCommand
```

#### 4.2 Keymap-Verification
```vim
<leader>       " Which-key popup prüfen
<leader>xy     " Keymap testen
```

#### 4.3 Performance-Impact messen
```bash
./scripts/collect_benchmark_data.sh
```

Akzeptable Werte:
- Startup-Increase: <50ms
- Warning: 50-100ms
- Regression: >100ms

---

### Phase 5: Commit

#### 5.1 Pre-Commit Checklist

- [ ] Plugin in `manage.lua` registriert
- [ ] Konfigurationsdatei in `lua/plugins/[category]/`
- [ ] Plugin-Loader in `init.lua`
- [ ] Icons aus `core.icons` (keine Emojis)
- [ ] `<cmd>Command<CR>` statt `:Command<CR>`
- [ ] README.md (Performance Table + Acknowledgments)
- [ ] docs/PLUGINS.md (Plugin-Sektion + Commands)
- [ ] lua/plugins/DEPENDENCIES.md
- [ ] docs/ARCHITECTURE.md (2 Stellen)
- [ ] CHANGELOG.md
- [ ] INSTALLATION.md (2 Stellen)
- [ ] docs/BENCHMARKS.md (falls relevant)
- [ ] `:PluginSync` erfolgreich
- [ ] `:checkhealth` keine Fehler
- [ ] Commands funktionieren
- [ ] Keymaps funktionieren
- [ ] Performance-Impact gemessen
- [ ] Alle Plugin-Count-Referenzen aktualisiert

#### 5.2 Commit Message Template
```
Add [plugin-name] for [purpose]

Implementation:
- lua/plugins/manage.lua: Added to registry
- lua/plugins/[category]/plugin-name.lua: Configuration
  * Commands: :PluginCommand
  * Keymaps: <leader>xy

Documentation:
- docs/PLUGINS.md: Plugin documentation
- lua/plugins/DEPENDENCIES.md: Dependencies
- README.md: Updated acknowledgments + count (24 -> 25)
- docs/ARCHITECTURE.md: Updated list (24 -> 25)
- CHANGELOG.md: Added to unreleased

Performance Impact:
- Startup: +Xms
- Plugin count: 24 -> 25
```

---

## Common Pitfalls

### Keymap Flash
```lua
-- ❌ Wrong
vim.keymap.set("n", "<leader>e", ":Command<CR>")

-- ✅ Correct
vim.keymap.set("n", "<leader>e", "<cmd>Command<CR>")
```

### Emoji statt Icons
```lua
-- ❌ Wrong
desc = "🚀 Startup"

-- ✅ Correct
local icons = require("core.icons")
desc = icons.status.rocket .. " Startup"
```

### Fehlendes pcall()
```lua
-- ❌ Wrong
local plugin = require("plugin-name")

-- ✅ Correct
local ok, plugin = pcall(require, "plugin-name")
if not ok then return end
```

---

## Automation Helpers

```bash
# Find plugin count references
grep -rn "24 plugin\|24-plugin" . --include="*.md"

# Check for emoji usage
grep -rP "[\x{1F300}-\x{1F9FF}]" lua/ --include="*.lua"

# Verify keymaps use <cmd>
grep -r '":.*<CR>' lua/plugins/ --include="*.lua"

# Count installed plugins
NVIM_APPNAME=VelocityNvim nvim --headless -c "lua print(vim.tbl_count(require('plugins.manage').plugins))" -c "qall"
```

---

**Beispiel:** Siehe vim-startuptime Commit für vollständige Referenz.

Letzte Aktualisierung: 2025-10-01
