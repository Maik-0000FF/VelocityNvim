#!/usr/bin/env bash
# VelocityNvim Benchmark Data Collection Script
# Sammelt alle Daten für benchmark_results.csv

set -euo pipefail

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  VelocityNvim Benchmark Data Collection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# 1. Date & Time
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
echo -e "${GREEN}✓${NC} Date: $DATE"
echo -e "${GREEN}✓${NC} Time: $TIME"

# 2. Version (from version.lua)
VERSION=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local v = require('core.version'); print(v.config_version)" -c "qall" 2>&1 | tail -1)
echo -e "${GREEN}✓${NC} Version: $VERSION"

# 3. System (kernel info)
SYSTEM=$(uname -r)
echo -e "${GREEN}✓${NC} System: Linux $SYSTEM"

# 4. Neovim Version
NVIM_VERSION=$(nvim --version | head -1 | awk '{print $2}' | sed 's/v//')
echo -e "${GREEN}✓${NC} Neovim: $NVIM_VERSION"

# 5. API Level
API_LEVEL=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua print(vim.version().api_level)" -c "qall" 2>&1 | tail -1)
echo -e "${GREEN}✓${NC} API Level: $API_LEVEL"

echo
echo "Running startup benchmarks (5 runs)..."

# 6-9. Startup Times (Cold: 1-3, Warm: 4-5)
STARTUP_TIMES=()
for i in {1..5}; do
  STARTUP_MS=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local elapsed = (vim.loop.hrtime() - vim.g.velocitynvim_start_time) / 1000000; print(string.format('%.2f', elapsed))" -c "qall" 2>&1 | tail -1)
  STARTUP_TIMES+=($STARTUP_MS)
  echo -e "  Run $i: ${STARTUP_MS}ms"
done

# Berechne Cold (1-3) und Warm (4-5) Durchschnitte
COLD_SUM=$(echo "${STARTUP_TIMES[0]} + ${STARTUP_TIMES[1]} + ${STARTUP_TIMES[2]}" | bc)
COLD_AVG=$(echo "scale=3; $COLD_SUM / 3 / 1000" | bc) # Convert to seconds
echo -e "${GREEN}✓${NC} Cold Avg (Runs 1-3): ${COLD_AVG}s"

WARM_SUM=$(echo "${STARTUP_TIMES[3]} + ${STARTUP_TIMES[4]}" | bc)
WARM_AVG=$(echo "scale=3; $WARM_SUM / 2 / 1000" | bc) # Convert to seconds
echo -e "${GREEN}✓${NC} Warm Avg (Runs 4-5): ${WARM_AVG}s"

OVERALL_SUM=$(echo "$COLD_SUM + $WARM_SUM" | bc)
OVERALL_AVG=$(echo "scale=3; $OVERALL_SUM / 5 / 1000" | bc) # Convert to seconds
echo -e "${GREEN}✓${NC} Overall Avg: ${OVERALL_AVG}s"

echo
echo "Running LSP performance benchmark (1000 operations)..."

# 10-11. LSP Performance
LSP_OUTPUT=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local lsp = require('utils.lsp'); local start = vim.loop.hrtime(); for i=1,1000 do lsp.get_workspace_diagnostics(); end; local elapsed = (vim.loop.hrtime() - start) / 1e6; print(string.format('%.3f', elapsed))" -c "qall" 2>&1 | tail -1)
LSP_1000OPS_MS=$LSP_OUTPUT
LSP_PER_OP_US=$(echo "scale=3; $LSP_1000OPS_MS" | bc) # Already in µs per op
echo -e "${GREEN}✓${NC} LSP 1000 ops: ${LSP_1000OPS_MS}ms"
echo -e "${GREEN}✓${NC} LSP per op: ${LSP_PER_OP_US}µs"

echo
echo "Running plugin load benchmark..."

# 12. Plugin Load Time
PLUGIN_LOAD_US=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local start = vim.loop.hrtime(); require('core'); require('plugins'); local elapsed = (vim.loop.hrtime() - start) / 1000; print(string.format('%.3f', elapsed))" -c "qall" 2>&1 | tail -1)
echo -e "${GREEN}✓${NC} Plugin load: ${PLUGIN_LOAD_US}µs"

echo
echo "Collecting system info..."

# 13. Memory Usage (RSS in MB)
MEMORY_MB=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local mem_bytes = vim.loop.resident_set_memory(); local mem_mb = mem_bytes / 1024 / 1024; print(string.format('%.1f', mem_mb))" -c "qall" 2>&1 | tail -1)
echo -e "${GREEN}✓${NC} Memory: ${MEMORY_MB}MB"

# 14. Health Check Time
echo "Running health check..."
HEALTH_START=$(date +%s%N)
NVIM_APPNAME=VelocityNvim nvim --headless -c "lua require('tests.isolated_test_runner').health_check()" -c "qall" >/dev/null 2>&1
HEALTH_END=$(date +%s%N)
HEALTH_CHECK_S=$(echo "scale=3; ($HEALTH_END - $HEALTH_START) / 1000000000" | bc)
echo -e "${GREEN}✓${NC} Health check: ${HEALTH_CHECK_S}s"

# 15. Plugin Count
PLUGIN_COUNT=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local m = require('plugins.manage'); print(vim.tbl_count(m.plugins))" -c "qall" 2>&1 | tail -1)
echo -e "${GREEN}✓${NC} Plugin count: $PLUGIN_COUNT"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Benchmark Data Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Prompt for Test Type and Notes
echo -e "${YELLOW}Enter test type (e.g., 'startup_tracking_implementation'):${NC}"
read -r TEST_TYPE

echo -e "${YELLOW}Enter notes (brief description of changes):${NC}"
read -r NOTES

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CSV Entry (copy to benchmark_results.csv)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Generate CSV line
CSV_LINE="$DATE,$TIME,$VERSION,Linux $SYSTEM,$NVIM_VERSION,$API_LEVEL,$COLD_AVG,$WARM_AVG,$OVERALL_AVG,$LSP_1000OPS_MS,$LSP_PER_OP_US,$PLUGIN_LOAD_US,$MEMORY_MB,$HEALTH_CHECK_S,$PLUGIN_COUNT,$TEST_TYPE,$NOTES"

echo "$CSV_LINE"
echo

# Option to append directly to CSV
echo -e "${YELLOW}Append to docs/benchmark_results.csv? (y/n):${NC}"
read -r APPEND_CONFIRM

if [[ "$APPEND_CONFIRM" == "y" || "$APPEND_CONFIRM" == "Y" ]]; then
  CSV_FILE="$(dirname "$0")/../docs/benchmark_results.csv"
  echo "$CSV_LINE" >> "$CSV_FILE"
  echo -e "${GREEN}✓${NC} Appended to benchmark_results.csv"
else
  echo -e "${YELLOW}⚠${NC} Not appended. Copy manually if needed."
fi

echo
echo -e "${GREEN}✓ Benchmark data collection complete!${NC}"
