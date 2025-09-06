#!/bin/bash

# blink.cmp Rust Auto-Build Script
# Kompiliert automatisch die Rust-Binaries für blink.cmp nach Plugin-Installation
# Löst das "Failed to setup fuzzy matcher" Problem

set -euo pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}       blink.cmp Rust Auto-Build Script        ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Pfade
BLINK_DIR=~/.local/share/VelocityNvim/site/pack/user/start/blink.cmp
CARGO_TOML="$BLINK_DIR/Cargo.toml"
TARGET_DIR="$BLINK_DIR/target"

# =============================================================================
# VALIDIERUNG
# =============================================================================

echo -e "${BLUE}=== Validierung ===${NC}"

# 1. Rust Installation prüfen
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}✗ Cargo nicht gefunden!${NC}"
    echo "  Installation: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
else
    rust_version=$(rustc --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Rust verfügbar: $rust_version${NC}"
fi

# 2. blink.cmp Plugin prüfen
if [ ! -f "$CARGO_TOML" ]; then
    echo -e "${RED}✗ blink.cmp Plugin nicht gefunden!${NC}"
    echo "  Pfad: $CARGO_TOML"
    echo "  Lösung: Führe ':PluginSync' in Neovim aus"
    exit 1
else
    echo -e "${GREEN}✓ blink.cmp Plugin gefunden${NC}"
    echo "  Pfad: $BLINK_DIR"
fi

# 3. Bestehende Binaries prüfen
if [ -d "$TARGET_DIR" ]; then
    size=$(du -sh "$TARGET_DIR" 2>/dev/null | cut -f1 || echo "?")
    echo -e "${YELLOW}! Bestehende Rust-Binaries gefunden (${size})${NC}"
    echo "  Diese werden überschrieben"
else
    echo -e "${BLUE}◦ Keine bestehenden Binaries (fresh build)${NC}"
fi

echo ""

# =============================================================================
# RUST BUILD PROCESS
# =============================================================================

echo -e "${BLUE}=== Rust Compilation ===${NC}"

# Arbeitsverzeichnis wechseln
cd "$BLINK_DIR"
echo "Arbeitsverzeichnis: $(pwd)"

# Build-Profil bestimmen
BUILD_PROFILE="release"
echo -e "${YELLOW}Build-Profil: $BUILD_PROFILE${NC}"

echo ""
echo -e "${YELLOW}Starte Rust-Compilation...${NC}"
echo "Dies kann einige Minuten dauern..."
echo ""

# Rust Build mit detailliertem Output
if cargo build --profile "$BUILD_PROFILE" --verbose; then
    echo ""
    echo -e "${GREEN}✓ Rust-Compilation erfolgreich!${NC}"
    
    # Binary-Informationen
    if [ -d "$TARGET_DIR" ]; then
        target_size=$(du -sh "$TARGET_DIR" 2>/dev/null | cut -f1 || echo "?")
        echo "  Target-Verzeichnis: $target_size"
        
        # Suche spezifische Binaries
        binaries=$(find "$TARGET_DIR" -name "*.so" -o -name "*.dll" -o -name "*.dylib" 2>/dev/null | head -3)
        if [ -n "$binaries" ]; then
            echo "  Erstellte Binaries:"
            echo "$binaries" | while read -r binary; do
                if [ -f "$binary" ]; then
                    binary_size=$(du -sh "$binary" 2>/dev/null | cut -f1 || echo "?")
                    echo "    - $(basename "$binary") ($binary_size)"
                fi
            done
        fi
    fi
else
    echo ""
    echo -e "${RED}✗ Rust-Compilation fehlgeschlagen!${NC}"
    echo ""
    echo -e "${YELLOW}Häufige Lösungen:${NC}"
    echo "1. Rust-Toolchain aktualisieren: rustup update"
    echo "2. Cache leeren: cargo clean"
    echo "3. Dependencies prüfen: cargo check"
    exit 1
fi

echo ""

# =============================================================================
# VALIDIERUNG DER ERGEBNISSE
# =============================================================================

echo -e "${BLUE}=== Build-Validierung ===${NC}"

# Teste ob Neovim die Binaries erkennt
echo -e "${YELLOW}Teste blink.cmp Integration...${NC}"

if NVIM_APPNAME=VelocityNvim nvim --headless \
    -c "lua local ok, blink = pcall(require, 'blink.cmp'); if ok then print('blink.cmp loaded successfully') else print('ERROR: blink.cmp load failed') end" \
    -c "qall" 2>/dev/null | grep -q "loaded successfully"; then
    echo -e "${GREEN}✓ blink.cmp Integration erfolgreich${NC}"
else
    echo -e "${YELLOW}⚠ blink.cmp Integration konnte nicht validiert werden${NC}"
    echo "  Starte Neovim manuell um zu testen"
fi

# =============================================================================
# ZUSAMMENFASSUNG
# =============================================================================

echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}          RUST BUILD ABGESCHLOSSEN             ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo -e "${GREEN}Nächste Schritte:${NC}"
echo "1. Starte Neovim: ${YELLOW}NVIM_APPNAME=VelocityNvim nvim${NC}"
echo "2. Teste Completion: Tippe in Insert-Mode"
echo "3. Prüfe Status: ${YELLOW}:messages${NC}"
echo ""
echo -e "${BLUE}blink.cmp Rust-Performance ist jetzt aktiv!${NC}"

exit 0