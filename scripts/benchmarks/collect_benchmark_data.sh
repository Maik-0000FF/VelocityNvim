#!/usr/bin/env bash
# VelocityNvim Benchmark Data Collection Script
# Sammelt alle Daten für benchmark_results.csv
#
# RFC 4180 Compliant CSV Output:
# - Fields with special characters (parentheses, commas) are quoted
# - Ensures proper parsing by GitHub, Excel, and other CSV tools
# - CPU_MODEL and NOTES fields are always quoted to prevent column mismatch

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

# 2. Version (from Git - version.lua removed for performance)
if git rev-parse --git-dir > /dev/null 2>&1; then
  VERSION=$(git describe --tags --always 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "unknown")
else
  VERSION="unknown"
fi
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

# 6. CPU Info (model name)
CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
echo -e "${GREEN}✓${NC} CPU: $CPU_MODEL"

# 7. RAM Total (in GB)
RAM_TOTAL_KB=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
RAM_TOTAL_GB=$(echo "scale=1; $RAM_TOTAL_KB / 1024 / 1024" | bc)
echo -e "${GREEN}✓${NC} RAM: ${RAM_TOTAL_GB}GB"

echo
echo "Preparing system for benchmark..."
sync && sleep 2

echo "Running startup benchmarks (10 runs)..."

# 6-9. Startup Times (Cold: 1-5, Warm: 6-10)
STARTUP_TIMES=()
for i in {1..10}; do
  STARTUP_MS=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local elapsed = (vim.uv.hrtime() - vim.g.velocitynvim_start_time) / 1000000; print(string.format('%.2f', elapsed))" -c "qall" 2>&1 | tail -1)
  STARTUP_TIMES+=($STARTUP_MS)
  echo -e "  Run $i: ${STARTUP_MS}ms"
done

# Berechne Cold (1-5) und Warm (6-10) Durchschnitte
COLD_SUM=$(echo "${STARTUP_TIMES[0]} + ${STARTUP_TIMES[1]} + ${STARTUP_TIMES[2]} + ${STARTUP_TIMES[3]} + ${STARTUP_TIMES[4]}" | bc)
COLD_AVG=$(echo "scale=4; $COLD_SUM / 5 / 1000" | bc -l | python3 -c "import sys; print(f'{float(sys.stdin.read().strip()):.4f}')")
echo -e "${GREEN}✓${NC} Cold Avg (Runs 1-5): ${COLD_AVG}s"

WARM_SUM=$(echo "${STARTUP_TIMES[5]} + ${STARTUP_TIMES[6]} + ${STARTUP_TIMES[7]} + ${STARTUP_TIMES[8]} + ${STARTUP_TIMES[9]}" | bc)
WARM_AVG=$(echo "scale=4; $WARM_SUM / 5 / 1000" | bc -l | python3 -c "import sys; print(f'{float(sys.stdin.read().strip()):.4f}')")
echo -e "${GREEN}✓${NC} Warm Avg (Runs 6-10): ${WARM_AVG}s"

OVERALL_SUM=$(echo "$COLD_SUM + $WARM_SUM" | bc)
OVERALL_AVG=$(echo "scale=4; $OVERALL_SUM / 10 / 1000" | bc -l | python3 -c "import sys; print(f'{float(sys.stdin.read().strip()):.4f}')")
echo -e "${GREEN}✓${NC} Overall Avg: ${OVERALL_AVG}s"

# Berechne Median (resistant to outliers)
SORTED_TIMES=($(printf '%s\n' "${STARTUP_TIMES[@]}" | sort -n))
MEDIAN_MS=$(echo "scale=4; (${SORTED_TIMES[4]} + ${SORTED_TIMES[5]}) / 2" | bc)
MEDIAN_S=$(echo "scale=4; $MEDIAN_MS / 1000" | bc -l | python3 -c "import sys; print(f'{float(sys.stdin.read().strip()):.4f}')")
echo -e "${GREEN}✓${NC} Overall Median: ${MEDIAN_S}s (resistant to outliers)"

echo
echo "Running LSP performance benchmark (1000 operations)..."

# 10-11. LSP Performance
LSP_OUTPUT=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local start = vim.uv.hrtime(); for i=1,1000 do vim.diagnostic.get(0) end; local elapsed = (vim.uv.hrtime() - start) / 1000000; print(string.format('%.2f', elapsed))" -c "qall" 2>&1 | tail -1)
LSP_1000OPS_MS=$LSP_OUTPUT
LSP_PER_OP_US=$(echo "scale=3; $LSP_1000OPS_MS" | bc) # Already in µs per op
echo -e "${GREEN}✓${NC} LSP 1000 ops: ${LSP_1000OPS_MS}ms"
echo -e "${GREEN}✓${NC} LSP per op: ${LSP_PER_OP_US}µs"

echo
echo "Running plugin load benchmark..."

# 12. Plugin Load Time
PLUGIN_LOAD_US=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local start = vim.uv.hrtime(); require('plugins'); local elapsed = (vim.uv.hrtime() - start) / 1000; print(string.format('%.3f', elapsed))" -c "qall" 2>&1 | tail -1)
echo -e "${GREEN}✓${NC} Plugin load: ${PLUGIN_LOAD_US}µs"

echo
echo "Collecting system info..."

# 13. Memory Usage (RSS in MB)
MEMORY_MB=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local mem = vim.fn.system('ps -o rss= -p ' .. vim.fn.getpid()):gsub('%s+', ''); print(string.format('%.1f', tonumber(mem) / 1024))" -c "qall" 2>&1 | tail -1)
echo -e "${GREEN}✓${NC} Memory: ${MEMORY_MB}MB"

# 14. Health Check Time
echo "Running health check..."
HEALTH_START=$(date +%s%N)
NVIM_APPNAME=VelocityNvim nvim --headless -c "lua require('tests.isolated_test_runner').health_check()" -c "qall" >/dev/null 2>&1
HEALTH_END=$(date +%s%N)
HEALTH_CHECK_S=$(echo "scale=3; ($HEALTH_END - $HEALTH_START) / 1000000000" | bc | python3 -c "import sys; print(f'{float(sys.stdin.read().strip()):.3f}')")
echo -e "${GREEN}✓${NC} Health check: ${HEALTH_CHECK_S}s"

# 15. Plugin Count (automatisch aus manage.lua gezählt)
PLUGIN_COUNT=$(NVIM_APPNAME=VelocityNvim nvim --headless -c "lua local m = require('plugins.manage'); print(vim.tbl_count(m.plugins))" -c "qall" 2>&1 | tail -1)

# Info: Vergleiche mit letztem Benchmark (nur zur Information)
CSV_FILE="$(dirname "$0")/../../docs/benchmark_results.csv"
if [ -f "$CSV_FILE" ]; then
  LAST_PLUGIN_COUNT=$(tail -1 "$CSV_FILE" | cut -d',' -f15)
  if [ -n "$LAST_PLUGIN_COUNT" ] && [ "$LAST_PLUGIN_COUNT" != "Plugin_Count" ]; then
    if [ "$PLUGIN_COUNT" != "$LAST_PLUGIN_COUNT" ]; then
      echo -e "${YELLOW}ℹ${NC}  Plugin count changed since last benchmark: ${LAST_PLUGIN_COUNT} → ${PLUGIN_COUNT}"
    fi
  fi
fi

echo -e "${GREEN}✓${NC} Plugin count: $PLUGIN_COUNT (automatically counted from manage.lua)"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Benchmark Data Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Standard test type for automated benchmarks
TEST_TYPE="standard_benchmark"

# Prompt for notes only
echo -e "${YELLOW}Enter notes (brief description of changes):${NC}"
read -r NOTES

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CSV Entry"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Generate CSV line (with median, CPU, RAM)
# Escape CPU_MODEL and NOTES with quotes to handle special characters and commas
CSV_LINE="$DATE,$TIME,$VERSION,Linux $SYSTEM,$NVIM_VERSION,$API_LEVEL,\"$CPU_MODEL\",$RAM_TOTAL_GB,$COLD_AVG,$WARM_AVG,$OVERALL_AVG,$MEDIAN_S,$LSP_1000OPS_MS,$LSP_PER_OP_US,$PLUGIN_LOAD_US,$MEMORY_MB,$HEALTH_CHECK_S,$PLUGIN_COUNT,$TEST_TYPE,\"$NOTES\""

echo "$CSV_LINE"
echo

# Option to append directly to CSV
echo -e "${YELLOW}Append to docs/benchmark_results.csv? (y/n):${NC}"
read -r APPEND_CONFIRM

if [[ "$APPEND_CONFIRM" == "y" || "$APPEND_CONFIRM" == "Y" ]]; then
  CSV_FILE="$(dirname "$0")/../../docs/benchmark_results.csv"
  echo "$CSV_LINE" >> "$CSV_FILE"
  echo -e "${GREEN}✓${NC} Appended to benchmark_results.csv"
else
  echo -e "${YELLOW}⚠${NC} Not appended. Copy manually if needed."
fi

echo
echo -e "${GREEN}✓ Benchmark data collection complete!${NC}"
