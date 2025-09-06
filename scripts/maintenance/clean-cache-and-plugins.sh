#!/bin/bash

# VelocityNvim Clean Installation Script
# Entfernt ALLE VelocityNvim Daten außer der Konfiguration selbst
# Für eine vollständig saubere Neuinstallation

set -euo pipefail  # Fehlerbehandlung: exit bei Fehlern

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}        VelocityNvim Clean Installation        ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Sicherheitscheck - Verhindere versehentliches Löschen
echo -e "${YELLOW}WARNUNG: Dieses Script löscht ALLE VelocityNvim Daten!${NC}"
echo -e "${YELLOW}Die Konfiguration in ~/.config/VelocityNvim bleibt erhalten.${NC}"
echo ""
echo "Folgende Verzeichnisse werden GELÖSCHT:"
echo "  - ~/.local/share/VelocityNvim (Plugins, Site-Packages)"
echo "  - ~/.local/state/VelocityNvim (Undo-History, Shada)"
echo "  - ~/.cache/VelocityNvim (Cache, Temp-Dateien)"
echo ""

# Bestätigung erforderlich
read -p "Sind Sie sicher? Tippen Sie 'JA' um fortzufahren: " confirm
if [ "$confirm" != "JA" ]; then
    echo -e "${RED}Abbruch: Bestätigung nicht erhalten${NC}"
    exit 1
fi

echo -e "${GREEN}Start Cleanup...${NC}"
echo ""

# =============================================================================
# CLEANUP FUNKTIONEN
# =============================================================================

cleanup_directory() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}Lösche: $description${NC}"
        echo "  Pfad: $dir"
        
        # Zeige Größe vor dem Löschen
        local size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "?")
        echo "  Größe: $size"
        
        # Lösche Verzeichnis
        rm -rf "$dir"
        
        if [ ! -d "$dir" ]; then
            echo -e "${GREEN}  ✓ Erfolgreich gelöscht${NC}"
        else
            echo -e "${RED}  ✗ Fehler beim Löschen${NC}"
            return 1
        fi
    else
        echo -e "${BLUE}Übersprungen: $description (nicht vorhanden)${NC}"
        echo "  Pfad: $dir"
    fi
    echo ""
}

# =============================================================================
# HAUPT-CLEANUP
# =============================================================================

total_freed=0
cleanup_count=0

echo -e "${BLUE}=== Plugin & Data Cleanup ===${NC}"

# 1. Plugin-Verzeichnis (größte Speicherersparnis)
if cleanup_directory ~/.local/share/VelocityNvim "Plugin-Verzeichnis & Site-Packages"; then
    ((cleanup_count++))
fi

# 2. State-Verzeichnis (Undo, Shada, Logs)
if cleanup_directory ~/.local/state/VelocityNvim "State-Dateien (Undo-History, Shada)"; then
    ((cleanup_count++))
fi

# 3. Cache-Verzeichnis (Treesitter, LSP Cache)
if cleanup_directory ~/.cache/VelocityNvim "Cache-Dateien"; then
    ((cleanup_count++))
fi

# =============================================================================
# ZUSÄTZLICHE VERSION-DATEI (falls vorhanden)
# =============================================================================

echo -e "${BLUE}=== Zusätzliche Dateien ===${NC}"

version_file=~/.local/share/VelocityNvim/velocitynvim_version
if [ -f "$version_file" ]; then
    echo -e "${YELLOW}Lösche: Version-Tracking-Datei${NC}"
    echo "  Pfad: $version_file"
    rm -f "$version_file"
    echo -e "${GREEN}  ✓ Version-Datei gelöscht${NC}"
    ((cleanup_count++))
else
    echo -e "${BLUE}Übersprungen: Version-Datei (nicht vorhanden)${NC}"
fi

echo ""

# =============================================================================
# KONFIGURATION BEIBEHALTEN (SCHUTZ)
# =============================================================================

echo -e "${BLUE}=== Konfiguration (GESCHÜTZT) ===${NC}"
config_dir=~/.config/VelocityNvim
if [ -d "$config_dir" ]; then
    local config_size=$(du -sh "$config_dir" 2>/dev/null | cut -f1 || echo "?")
    echo -e "${GREEN}Erhalten: VelocityNvim Konfiguration${NC}"
    echo "  Pfad: $config_dir"
    echo "  Größe: $config_size"
    echo -e "${GREEN}  ✓ Konfiguration bleibt unverändert${NC}"
else
    echo -e "${RED}WARNUNG: Konfiguration nicht gefunden!${NC}"
    echo "  Pfad: $config_dir"
fi

echo ""

# =============================================================================
# ZUSAMMENFASSUNG
# =============================================================================

echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}              CLEANUP ABGESCHLOSSEN             ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo "Verarbeitete Bereiche: $cleanup_count"
echo ""
echo -e "${GREEN}Für eine vollständige Neuinstallation:${NC}"
echo "1. Starten Sie Neovim: ${YELLOW}NVIM_APPNAME=VelocityNvim nvim${NC}"
echo "2. Führen Sie aus: ${YELLOW}:PluginSync${NC}"
echo "3. Schließen Sie Neovim"
echo "4. WICHTIG für blink.cmp: ${YELLOW}./build_blink_rust.sh${NC}"
echo "5. Starten Sie Neovim neu"
echo "6. Testen Sie: ${YELLOW}:VelocityHealth${NC}"
echo ""
echo -e "${BLUE}Alle VelocityNvim Daten wurden bereinigt!${NC}"
echo -e "${BLUE}Die Konfiguration ist bereit für Fresh Install.${NC}"

exit 0