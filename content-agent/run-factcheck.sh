#!/usr/bin/env bash
set -euo pipefail

export HOME=/home/jinx
export PATH="/home/jinx/.local/bin:/usr/local/bin:/usr/bin:/bin"

REPO=/home/jinx/firecongress-us
PROMPT="$REPO/content-agent/factcheck-prompt.md"
LOG_DIR=/home/jinx/firecongress-content/logs
LOG_FILE="$LOG_DIR/factcheck-$(date +%Y-%m-%d_%H-%M).log"

mkdir -p "$LOG_DIR"
echo "[$(date)] Starting fact-check agent..." | tee "$LOG_FILE"

cd "$REPO"
git pull --rebase origin master >> "$LOG_FILE" 2>&1

claude \
  --print \
  --allowedTools "Bash(gh *),Bash(git *),Read,WebSearch,WebFetch" \
  < "$PROMPT" \
  >> "$LOG_FILE" 2>&1

echo "[$(date)] Done." | tee -a "$LOG_FILE"
