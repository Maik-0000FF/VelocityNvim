#!/bin/bash
# VelocityNvim Security Validation Script
# Purpose: Validates VelocityNvim X Automation Security Setup
# Security Level: MAXIMUM
# Usage: bash scripts/velocitynvim-security-check.sh

set -o pipefail  # Nur pipefail aktiv, kein -e wegen negierter Checks

# VelocityNvim Colors für Output
VELOCITYNVIM_GREEN="\033[0;32m"
VELOCITYNVIM_RED="\033[0;31m"
VELOCITYNVIM_YELLOW="\033[1;33m"
VELOCITYNVIM_BLUE="\033[0;34m"
VELOCITYNVIM_RESET="\033[0m"

echo -e "${VELOCITYNVIM_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${VELOCITYNVIM_RESET}"
echo -e "${VELOCITYNVIM_BLUE}🔒 VelocityNvim Security Validation Script${VELOCITYNVIM_RESET}"
echo -e "${VELOCITYNVIM_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${VELOCITYNVIM_RESET}"
echo ""

VELOCITYNVIM_ERRORS=0
VELOCITYNVIM_WARNINGS=0
VELOCITYNVIM_PASSED=0

# Function: VelocityNvim Security Check
# Usage: velocitynvim_check "name" "command" [invert] [severity]
velocitynvim_check() {
    local check_name="$1"
    local check_command="$2"
    local invert="${3:-false}"  # false or true (für negierte Checks)
    local severity="${4:-error}"  # error or warning

    echo -ne "${VELOCITYNVIM_BLUE}🔍 Checking: ${check_name}...${VELOCITYNVIM_RESET} "

    local result
    eval "$check_command" > /dev/null 2>&1
    result=$?

    # Logik invertieren wenn invert=true
    if [ "$invert" = "true" ]; then
        if [ $result -ne 0 ]; then
            result=0
        else
            result=1
        fi
    fi

    if [ $result -eq 0 ]; then
        echo -e "${VELOCITYNVIM_GREEN}✅ PASS${VELOCITYNVIM_RESET}"
        ((VELOCITYNVIM_PASSED++))
        return 0
    else
        if [ "$severity" = "error" ]; then
            echo -e "${VELOCITYNVIM_RED}❌ FAIL${VELOCITYNVIM_RESET}"
            ((VELOCITYNVIM_ERRORS++))
            return 1
        else
            echo -e "${VELOCITYNVIM_YELLOW}⚠️  WARN${VELOCITYNVIM_RESET}"
            ((VELOCITYNVIM_WARNINGS++))
            return 0
        fi
    fi
}

echo -e "${VELOCITYNVIM_YELLOW}[1/10] VelocityNvim Repository Security Checks${VELOCITYNVIM_RESET}"
echo ""

# Check 1: VelocityNvim Repository hat keine hardcoded Secrets in Workflow Files
# (Ignoriert Comments und grep-Commands, nur echte Assignments)
velocitynvim_check \
    "VelocityNvim Workflow Files enthalten keine hardcoded API Keys" \
    "grep -rE '^[^#]*[A-Z_]+.*=.*['\''\"](sk-|ghp_|gho_|xox[a-z]-)[a-zA-Z0-9_-]{20,}' .github/workflows/" \
    "true" "error"

# Check 2: VelocityNvim Repository hat keine .env Files committed
velocitynvim_check \
    "VelocityNvim Repository hat keine .env Files committed" \
    "git ls-files | grep -E '\.env$|\.env\..*$|secrets\.'" \
    "true" "error"

# Check 3: VelocityNvim .gitignore enthält Secret-Patterns
velocitynvim_check \
    "VelocityNvim .gitignore schützt vor Secret-Commits" \
    "grep -qE '(\.env|secrets|credentials)' .gitignore" \
    "false" "error"

echo ""
echo -e "${VELOCITYNVIM_YELLOW}[2/10] VelocityNvim Privacy Compliance Checks${VELOCITYNVIM_RESET}"
echo ""

# Check 10: VelocityNvim Repository enthält keine privaten Telefonnummern
velocitynvim_check \
    "VelocityNvim Repository enthält keine privaten Telefonnummern" \
    "git grep -iE '(\+49|0[0-9]{9,})' -- ':!scripts/setup/velocitynvim-security-check.sh'" \
    "true" "error"

# Check 11: VelocityNvim Repository enthält keine privaten Adressen
velocitynvim_check \
    "VelocityNvim Repository enthält keine privaten Adressen" \
    "git grep -iE '(strasse|straße|hausnummer)'" \
    "true" "warning"

# Check 12: VelocityNvim verwendet nur Projekt-Email
velocitynvim_check \
    "VelocityNvim verwendet keine Emails (Kontakt via GitHub Issues)" \
    "git grep -iE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' -- ':!docs/' ':!.git/' ':!.github/' | grep -v 'noreply@github.com' | grep -v '@users.noreply.github.com' | grep -v 'github-actions'" \
    "true" "warning"

echo ""
echo -e "${VELOCITYNVIM_YELLOW}[3/10] VelocityNvim Git Commit Security Checks${VELOCITYNVIM_RESET}"
echo ""

# Check 13: VelocityNvim Commits enthalten keine AI Attribution
velocitynvim_check \
    "VelocityNvim Commits ohne AI Attribution" \
    "git log --all --grep='Co-Authored-By:.*bot' --grep='Generated with.*AI'" \
    "true" "warning"

# Check 14: VelocityNvim Commits enthalten keine Emojis (außer in Docs)
velocitynvim_check \
    "VelocityNvim Commits ohne Emojis in Messages" \
    "git log --format=%s -10 | grep -P '[\\x{1F300}-\\x{1F9FF}]'" \
    "true" "warning"

echo ""
echo -e "${VELOCITYNVIM_YELLOW}[4/10] VelocityNvim Documentation Security Checks${VELOCITYNVIM_RESET}"
echo ""

# Check 15: VelocityNvim Security Documentation existiert (private)
velocitynvim_check \
    "VelocityNvim X Automation Security Docs vorhanden" \
    "test -f private/docs/VELOCITYNVIM-X-AUTOMATION-SECURITY.md"

# Check 16: VelocityNvim Projekt-Dokumentation vorhanden
velocitynvim_check \
    "VelocityNvim Projekt-Dokumentation vorhanden" \
    "test -f README.md"

echo ""
echo -e "${VELOCITYNVIM_YELLOW}[5/10] VelocityNvim External Service Security Checks${VELOCITYNVIM_RESET}"
echo ""

# Check 20: VelocityNvim Security Script selbst ist ausführbar
velocitynvim_check \
    "VelocityNvim Security Script hat korrekte Permissions" \
    "test -x scripts/setup/velocitynvim-security-check.sh || chmod +x scripts/setup/velocitynvim-security-check.sh"

echo ""
echo -e "${VELOCITYNVIM_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${VELOCITYNVIM_RESET}"
echo -e "${VELOCITYNVIM_BLUE}📊 VelocityNvim Security Validation Results${VELOCITYNVIM_RESET}"
echo -e "${VELOCITYNVIM_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${VELOCITYNVIM_RESET}"
echo ""
echo -e "${VELOCITYNVIM_GREEN}✅ Passed:  ${VELOCITYNVIM_PASSED}${VELOCITYNVIM_RESET}"
echo -e "${VELOCITYNVIM_YELLOW}⚠️  Warnings: ${VELOCITYNVIM_WARNINGS}${VELOCITYNVIM_RESET}"
echo -e "${VELOCITYNVIM_RED}❌ Errors:  ${VELOCITYNVIM_ERRORS}${VELOCITYNVIM_RESET}"
echo ""

if [ "$VELOCITYNVIM_ERRORS" -eq 0 ]; then
    echo -e "${VELOCITYNVIM_GREEN}🎉 VelocityNvim Security Validation: ALL CHECKS PASSED${VELOCITYNVIM_RESET}"
    echo -e "${VELOCITYNVIM_GREEN}✅ VelocityNvim X Automation ist production-ready!${VELOCITYNVIM_RESET}"
    echo ""
    exit 0
else
    echo -e "${VELOCITYNVIM_RED}⚠️  VelocityNvim Security Validation: FAILED${VELOCITYNVIM_RESET}"
    echo -e "${VELOCITYNVIM_RED}❌ Bitte behebe die Fehler bevor du VelocityNvim X Automation aktivierst${VELOCITYNVIM_RESET}"
    echo ""
    exit 1
fi
