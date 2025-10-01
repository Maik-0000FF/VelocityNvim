# Plugin Dependencies Documentation

## Übersicht der Plugin-Abhängigkeiten

Diese Datei dokumentiert alle Plugin-Interdependenzen in VelocityNvim zur besseren Wartbarkeit und Fehlerbehandlung.

## Core Dependencies (Kritisch)

### plenary.nvim
**Abhängigkeiten:** Keine  
**Wird benötigt von:**
- `neo-tree.nvim` (Async-Funktionen)
- `fzf-lua` (Job-Control)
- `gitsigns.nvim` (Git-Utils)

**Impact:** Zentrale Utility-Library - ohne diese funktioniert die Hälfte der Plugins nicht.

### nvim-web-devicons
**Abhängigkeiten:** Keine  
**Wird benötigt von:**
- `neo-tree.nvim` (Datei-Icons)
- `bufferline.nvim` (Buffer-Icons)
- `lualine.nvim` (Status-Icons)
- `alpha-nvim` (Dashboard-Icons)
- `fzf-lua` (Preview-Icons)

**Impact:** Icon-Provider - ohne diese sind UI-Elemente text-only.

## UI Plugin Dependencies

### alpha-nvim (Dashboard)
**Abhängigkeiten:**
- `nvim-web-devicons` (Icons im Dashboard)

**Interaktionen:**
- Nutzt `core.version` für dynamische Version-Info
- Nutzt `plugins.manage` für Plugin-Anzahl
- Nutzt `core.icons` für konsistente Icon-Darstellung

### neo-tree.nvim (File Explorer)
**Abhängigkeiten:**
- `plenary.nvim` (KRITISCH - Async-Operationen)
- `nvim-web-devicons` (Datei-Icons)
- `nui.nvim` (UI-Framework)

**Optionale Enhancements:**
- `gitsigns.nvim` (Git-Status Integration)
- `nvim-lsp-file-operations` (Automatische Import-Updates bei Datei-Operationen)

### bufferline.nvim (Tab-Bar)
**Abhängigkeiten:**
- `nvim-web-devicons` (Buffer-Icons)

**Interaktionen:**
- Nutzt `core.icons` für Separator-Icons

### lualine.nvim (Status Line)  
**Abhängigkeiten:**
- `nvim-web-devicons` (Mode-Icons)

**Optionale Integrationen:**
- `gitsigns.nvim` (Git-Branch in Status)
- Native LSP (LSP-Status Anzeige)

### noice.nvim (UI Enhancements)
**Abhängigkeiten:**
- `nui.nvim` (KRITISCH - Popup-Framework)
- `nvim-notify` (Notification-System)

**Interaktionen:**
- Überschreibt vim.ui.* Funktionen global

## Editor Enhancement Dependencies

### nvim-treesitter
**Abhängigkeiten:** Keine (Native Integration)  
**Wird benötigt von:**
- `hlchunk.nvim` (Chunk-Highlighting basiert auf Treesitter-Nodes)
- `blink.cmp` (Syntax-aware Completion)

**Impact:** Syntax-Engine - kritisch für moderne Code-Bearbeitung.

### blink.cmp (Completion)
**Abhängigkeiten:**
- `friendly-snippets` (Snippet-Database)

**Optionale Enhancements:**
- `nvim-treesitter` (Bessere Syntax-Completion)
- Native LSP (Code-Completion)

### which-key.nvim
**Abhängigkeiten:** Keine  
**Interaktionen:**
- Alle Keymaps werden automatisch erkannt
- `core.commands` registriert Keybinding-Gruppen
- `utils.terminal` registriert Terminal-Gruppe

## Development Tool Dependencies

### fzf-lua (Fuzzy Finder)
**Abhängigkeiten:**
- `plenary.nvim` (Job-Control)

**Optionale Enhancements:**
- `nvim-web-devicons` (Datei-Icons in Picker)
- `gitsigns.nvim` (Git-Status in Datei-Picker)

### conform.nvim (Formatting)
**Abhängigkeiten:** Keine  
**Interaktionen:**
- Native LSP (Fallback-Formatting)

### gitsigns.nvim (Git Integration)
**Abhängigkeiten:**
- `plenary.nvim` (Git-Operationen)

**Integrationen:**
- `lualine.nvim` (Git-Branch Anzeige)
- `neo-tree.nvim` (Git-Status Icons)
- `fzf-lua` (Git-File Status)

### suda.vim (Sudo File Editing)
**Abhängigkeiten:** Keine (Reines Vim-Plugin)
**Interaktionen:**
- Funktioniert transparent mit allen Editoren
- Keine Plugin-Dependencies
- Nutzt native Vim-Commands (:w, :e)

### vim-startuptime (Performance Profiling)
**Abhängigkeiten:** Keine
**Interaktionen:**
- Integriert mit Dashboard (`:StartupTime` / `b` key)
- Nutzt natives `--startuptime` Flag
- Unabhängiges Profiling-Tool
- Commands: `:StartupTime`, `:BenchmarkStartup`

### hop.nvim (Cursor Navigation)
**Abhängigkeiten:** Keine (Pure Lua Implementation)
**Optionale Integrationen:**
- `which-key.nvim` (Keymap-Registrierung für `<leader>h*` Keybindings)

**Interaktionen:**
- Visual Mode Support (alle Keymaps funktionieren in Visual Mode)
- Multi-Window Support (optional konfigurierbar)

### nvim-window-picker (Window Selection)
**Abhängigkeiten:** Keine (Pure Lua Implementation)
**Integrationen:**
- `neo-tree.nvim` (Window-Auswahl beim Datei-Öffnen)
- `tokyonight.nvim` (Highlight-Colors angepasst)

### nvim-lsp-file-operations (LSP File Operations)
**Abhängigkeiten:**
- `plenary.nvim` (Async File-Operationen)
- Native LSP (willRenameFiles/willCreateFiles/willDeleteFiles)

**Integrationen:**
- `neo-tree.nvim` (Automatische Import-Updates bei Rename/Move/Delete)

**Impact:** Automatisches Update von Imports wenn Dateien verschoben/umbenannt werden

## Dependency Chain Analysis

### Kritische Kette (Startup-Blocker)
```
plenary.nvim → neo-tree.nvim → Dashboard-Funktionalität
nui.nvim → noice.nvim → UI-Enhancement
```

### Icon-Kette
```
nvim-web-devicons → [bufferline, lualine, neo-tree, alpha, fzf-lua]
```

### LSP-Integration Kette
```
Native LSP → blink.cmp → Code-Completion
Native LSP → conform.nvim → Formatting-Fallback
```

## Failure Modes & Graceful Degradation

### Wenn plenary.nvim fehlt:
- ❌ Neo-tree funktionslos
- ❌ FZF-Lua ohne Job-Control
- ❌ Gitsigns ohne Git-Ops
- ✅ Rest der Konfiguration funktional

### Wenn nvim-web-devicons fehlt:
- ⚠️ UI-Plugins ohne Icons (text-only)
- ✅ Vollständige Funktionalität erhalten

### Wenn nui.nvim fehlt:
- ❌ Noice.nvim funktionslos
- ❌ Neo-tree ohne UI-Framework
- ✅ Rest der Konfiguration funktional

## Load Order Requirements

### Phase 1: Foundation
1. `plenary.nvim` (Async-Framework)
2. `nvim-web-devicons` (Icon-Provider)
3. `nui.nvim` (UI-Framework)

### Phase 2: Core UI  
1. `noice.nvim` (UI-Overrides)
2. `which-key.nvim` (Keymap-System)

### Phase 3: Editor
1. `nvim-treesitter` (Syntax-Engine)
2. `blink.cmp` (Completion)

### Phase 4: Tools
1. `neo-tree.nvim` (File-Explorer)
2. `nvim-lsp-file-operations` (LSP File Ops - NACH neo-tree)
3. `fzf-lua` (Fuzzy-Finder)
4. `conform.nvim` (Formatting)
5. `gitsigns.nvim` (Git-Integration)
6. `suda.vim` (Sudo-Editing)
7. `vim-startuptime` (Performance Profiling)

### Phase 5: UI Polish
1. `alpha-nvim` (Dashboard)
2. `bufferline.nvim` (Tabs)
3. `lualine.nvim` (Status)
4. `hlchunk.nvim` (Highlighting)
5. `nvim-window-picker` (Window-Selection)
6. `hop.nvim` (Cursor-Navigation)

## Plugin-specific Error Handling

Alle Plugins werden mit dem Safe-Loading Pattern geladen:
```lua
local function safe_require(module)
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify("Plugin nicht verfügbar: " .. module, vim.log.levels.WARN)
    return false
  end
  return true
end
```

## Maintenance Notes

- **Quarterly Review:** Plugin-Dependencies auf Breaking Changes prüfen
- **Version Pinning:** Bei kritischen Dependencies Version-Constraints erwägen
- **Fallback Testing:** Regelmäßig testen was passiert wenn Dependencies fehlen
- **Documentation Updates:** Bei neuen Plugins diese Liste aktualisieren

## Development Guidelines

### Neue Plugins hinzufügen:
1. Dependencies zu dieser Liste hinzufügen
2. Safe-Loading implementieren
3. Graceful Degradation testen
4. Load-Order berücksichtigen

### Plugin entfernen:
1. Reverse-Dependencies prüfen
2. Abhängige Plugins anpassen
3. Diese Dokumentation aktualisieren
4. Health-Checks anpassen

Diese Dokumentation wird automatisch bei Plugin-Änderungen aktualisiert.