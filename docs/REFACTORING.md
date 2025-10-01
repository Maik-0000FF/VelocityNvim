# Refactoring-Techniken Cheat Sheet

**Basierend auf: Martin Fowler - Refactoring: Improving the Design of Existing Code (2nd Edition)**

Dieses Dokument dient als schnelle Referenz für systematische Code-Verbesserungen in VelocityNvim.

---

## 📋 Inhaltsverzeichnis

1. [Grundlegende Refactorings](#grundlegende-refactorings)
2. [Kapselung (Encapsulation)](#kapselung-encapsulation)
3. [Features verschieben](#features-verschieben)
4. [Daten organisieren](#daten-organisieren)
5. [Bedingungen vereinfachen](#bedingungen-vereinfachen)
6. [APIs vereinfachen](#apis-vereinfachen)
7. [Vererbung umstrukturieren](#vererbung-umstrukturieren)

---

## Grundlegende Refactorings

| Technik | Beschreibung | Anwendungsfall | Lua-Beispiel |
|---------|--------------|----------------|--------------|
| **Extract Function** | Codeblock in eigene Funktion auslagern | Lange Funktionen, Code-Duplikation | `function validate_config()` aus `setup()` |
| **Inline Function** | Funktion durch ihren Inhalt ersetzen | Funktion ist trivial/überflüssig | Einzeiler direkt einsetzen |
| **Extract Variable** | Komplexen Ausdruck in Variable auslagern | Verständlichkeit erhöhen | `local is_valid = config and config.enabled` |
| **Inline Variable** | Variable durch Wert ersetzen | Variable verschleiert nur, einmal verwendet | Direkt `vim.fn.stdpath("data")` statt tmp-Variable |
| **Change Function Declaration** | Funktionssignatur ändern (Name, Parameter) | Klarere API, bessere Namen | `get_diagnostics()` → `get_workspace_diagnostics()` |
| **Rename Variable** | Variable umbenennen | Klarheit, Konsistenz | `val` → `diagnostic_count` |
| **Introduce Parameter Object** | Mehrere Parameter in Table bündeln | >3 Parameter | `opts = {width, height, row, col}` |
| **Split Phase** | Logik in getrennte Phasen aufteilen | Vermischte Verantwortlichkeiten | Parse-Phase + Render-Phase |
| **Slide Statements** | Code-Zeilen logisch zusammen verschieben | Bessere Gruppierung | Alle `local` zusammen, dann Logik |
| **Split Loop** | Eine Schleife in mehrere aufteilen | Mehrere Verantwortlichkeiten | Separate loops für validation + rendering |
| **Remove Dead Code** | Ungenutzten Code entfernen | Wartbarkeit, Klarheit | Auskommentierte Funktionen löschen |

---

## Kapselung (Encapsulation)

| Technik | Beschreibung | Anwendungsfall | Lua-Beispiel |
|---------|--------------|----------------|--------------|
| **Encapsulate Variable** | Direkten Zugriff durch Getter/Setter ersetzen | Änderungen überwachen/validieren | `M.get_config()` statt `M.config` |
| **Encapsulate Collection** | Collection-Zugriff kapseln | Unerwünschte Modifikationen verhindern | Kopie zurückgeben: `vim.deepcopy(M._plugins)` |
| **Encapsulate Record** | Lua-Table durch Module mit API kapseln | Bessere Kontrolle | `state.lua` statt globale Table |
| **Replace Primitive with Object** | Primitiven Wert durch Table/Module ersetzen | Zusätzliche Funktionalität nötig | `version = "1.0.0"` → `version = {major=1, minor=0}` |
| **Replace Temp with Query** | Lokale Variable durch Funktion ersetzen | Wiederverwendbarkeit | `get_plugin_count()` statt `local count = #plugins` |
| **Hide Delegate** | Delegation nach außen verbergen | Abhängigkeiten reduzieren | `utils.lsp.format()` statt `vim.lsp.buf.format()` direkt |
| **Remove Middle Man** | Überflüssige Delegation entfernen | Zu viele Wrapper | Direkter Aufruf wenn kein Mehrwert |

---

## Features verschieben

| Technik | Beschreibung | Anwendungsfall | Lua-Beispiel |
|---------|--------------|----------------|--------------|
| **Move Function** | Funktion in passenderes Module verschieben | Bessere Modulstruktur | `format_diagnostic()` → `utils/lsp.lua` |
| **Move Field** | Datenfeld verschieben | Logische Gruppierung | `terminal_state` → `utils/terminal.lua` |
| **Extract Class** | Neue Module aus bestehendem abspalten | Modul zu komplex | `icons.lua` aus `ui.lua` extrahieren |
| **Inline Class** | Modul auflösen und integrieren | Zu klein, unnötig | Winziges helper-Module einbetten |
| **Combine Functions into Class** | Verwandte Funktionen gruppieren | Struktur verbessern | Alle LSP-Utils in ein Module |

---

## Daten organisieren

| Technik | Beschreibung | Anwendungsfall | Lua-Beispiel |
|---------|--------------|----------------|--------------|
| **Split Variable** | Eine Variable für mehrere Zwecke aufteilen | Variable wird mehrfach überschrieben | `result` → `parse_result`, `validation_result` |
| **Rename Field** | Table-Key umbenennen | Verständlichkeit | `cfg` → `config` |
| **Replace Derived Variable with Query** | Berechnete Werte on-demand ermitteln | Inkonsistenzen vermeiden | `get_total_plugins()` statt `total_count` cachen |
| **Change Reference to Value** | Referenz durch Kopie ersetzen | Unveränderlichkeit | `vim.deepcopy(config)` zurückgeben |
| **Change Value to Reference** | Kopie durch Referenz ersetzen | Geteilter State nötig | Singleton-Pattern für shared state |
| **Replace Magic Number with Constant** | Literale durch benannte Konstante | Lesbarkeit, Wartbarkeit | `local MAX_PLUGINS = 50` |
| **Replace Array with Object** | Array durch benannte Table ersetzen | Bedeutungsvolle Struktur | `{width, height}` → `{width=80, height=24}` |

---

## Bedingungen vereinfachen

| Technik | Beschreibung | Anwendungsfall | Lua-Beispiel |
|---------|--------------|----------------|--------------|
| **Decompose Conditional** | Bedingung in beschreibende Funktionen aufteilen | Komplexe if-Ausdrücke | `if is_valid_config(cfg) then` |
| **Consolidate Conditional Expression** | Mehrere Bedingungen kombinieren | Redundante Checks | `if not a or not b or not c` → `if not all_valid(a,b,c)` |
| **Consolidate Duplicate Conditional Fragments** | Doppelten Code vor/nach if auslagern | Code-Duplikation | Code vor `if` ziehen wenn in allen branches |
| **Remove Control Flag** | Kontrollvariable durch `return`/`break` ersetzen | Klarheit | Statt `found = true` direkt `return result` |
| **Replace Nested Conditional with Guard Clauses** | Frühe Rückgaben nutzen | Verschachtelung abbauen | `if not config then return end` |
| **Replace Conditional with Polymorphism** | Polymorphie statt Switch/if-Kaskaden | Erweiterbarkeit | Strategy-Pattern für formatter |
| **Introduce Special Case** | Sonderfallobjekt anlegen | Null/Fehler-Checks vermeiden | Empty plugin list object |
| **Introduce Assertion** | Zusicherungen einfügen | Fehler früh erkennen | `assert(type(config) == "table")` |

---

## APIs vereinfachen

| Technik | Beschreibung | Anwendungsfall | Lua-Beispiel |
|---------|--------------|----------------|--------------|
| **Separate Query from Modifier** | Lesende von schreibenden Funktionen trennen | Command-Query-Separation | `get_status()` vs `update_status()` |
| **Parameterize Function** | Ähnliche Funktionen durch Parameter vereinen | Code-Duplikation | `show_notify(level, msg)` statt separate functions |
| **Remove Flag Argument** | Boolean-Parameter vermeiden | Klarheit | `show_info()` + `show_error()` statt `show(is_error)` |
| **Preserve Whole Object** | Ganzes Objekt übergeben statt Teile | Konsistenz, weniger Parameter | `format_diagnostic(diagnostic)` statt einzelne Felder |
| **Replace Parameter with Query** | Parameter durch Abfrage ersetzen | Parameter ist ableitbar | `get_current_buffer_diagnostics()` ohne buf-Parameter |
| **Replace Query with Parameter** | Abfrage durch Parameter ersetzen | Testbarkeit | Buffer-ID als Parameter statt `vim.api.nvim_get_current_buf()` |
| **Remove Setting Method** | Setter entfernen | Immutable Objects | Config nur bei Initialisierung setzen |
| **Replace Constructor with Factory Function** | Factory statt direkter Konstruktor | Flexiblere Objekterzeugung | `create_terminal(opts)` mit Validation |
| **Replace Function with Command** | Funktion als Command-Objekt | Undo/Redo, komplexe Logik | Command-Pattern für reversible Aktionen |
| **Replace Command with Function** | Command zurück zu einfacher Funktion | Vereinfachung | Wenn Command-Features ungenutzt |

---

## Vererbung umstrukturieren

| Technik | Beschreibung | Anwendungsfall | Lua-Beispiel |
|---------|--------------|----------------|--------------|
| **Pull Up Method** | Methode in "Eltern"-Module verschieben | Duplikate in verwandten Modulen | Gemeinsame Utils nach oben |
| **Push Down Method** | Methode in "Kind"-Module verschieben | Nur von Subtyp genutzt | Spezifische LSP-Utils nach unten |
| **Extract Superclass** | Gemeinsame Basis extrahieren | Ähnliche Module | `base_formatter.lua` für alle Formatter |
| **Collapse Hierarchy** | Unnötige Klassenhierarchie entfernen | Zu wenig Unterschied | Module zusammenlegen wenn minimal different |
| **Replace Subclass with Fields** | Subklassen durch Fields ersetzen | Unnötige Vererbung | `type = "floating"` statt eigenes Module |
| **Replace Type Code with Subclasses** | Typen-Code durch echte Typen | Erweiterbarkeit | Separate Modules für Terminal-Types |
| **Replace Inheritance with Delegation** | Vererbung durch Komposition ersetzen | Mehr Flexibilität | Module nutzt anderes statt "erbt" |
| **Replace Delegation with Inheritance** | Delegation durch Vererbung ersetzen | Vereinfachung | Wenn alle Methoden nur durchgereicht werden |

---

## 🎯 VelocityNvim-Spezifische Refactoring-Prinzipien

### 1. **Native API First**
```lua
-- ❌ Custom Implementation
local function count_diagnostics()
  local count = 0
  for _ in pairs(vim.diagnostic.get()) do
    count = count + 1
  end
  return count
end

-- ✅ Native API
local function count_diagnostics()
  return vim.diagnostic.count()
end
```

### 2. **Safe Loading with pcall**
```lua
-- ❌ Direct require
local plugin = require("plugin")

-- ✅ Safe loading
local ok, plugin = pcall(require, "plugin")
if not ok then
  vim.notify("Plugin not found", vim.log.levels.ERROR)
  return
end
```

### 3. **Performance-First**
```lua
-- ❌ Inefficient loop
for i = 1, #items do
  process(items[i])
  update_ui()  -- Inside loop!
end

-- ✅ Batch updates
for i = 1, #items do
  process(items[i])
end
update_ui()  -- Once after loop
```

### 4. **Consistent Error Handling**
```lua
-- ✅ VelocityNvim Standard
local M = {}

function M.setup(opts)
  if not opts then
    vim.notify("Config required", vim.log.levels.ERROR)
    return false
  end

  -- Setup logic
  return true
end

return M
```

---

## 📚 Weitere Ressourcen

- **Martin Fowler - Refactoring (2nd Edition)**: https://refactoring.com/
- **VelocityNvim Development Guidelines**: [docs/DEVELOPMENT.md](./DEVELOPMENT.md)
- **VelocityNvim Architecture**: [docs/ARCHITECTURE-DETAILS.md](./ARCHITECTURE-DETAILS.md)
- **Lua Performance Guide**: https://www.lua.org/gems/sample.pdf

---

## 🔄 Refactoring Workflow

1. **Read DEVELOPMENT.md** - Code-Standards verstehen
2. **Write Tests** - Verhalten sichern
3. **Small Steps** - Inkrementell refactoren
4. **Run Tests** - Nach jedem Schritt validieren
5. **Commit Often** - Kleine, atomare Commits
6. **Benchmark** - Performance-Impact messen (siehe [BENCHMARKS.md](./BENCHMARKS.md))

---

**Hinweis:** Dieses Cheat Sheet fokussiert auf Lua/Neovim-Kontext. Für detaillierte Erklärungen siehe Martin Fowlers Buch.
