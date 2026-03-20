#!/usr/bin/env bash
# run-analysis-print.sh — Runs Claude Code in print mode (-p) for each documentation prompt
# This is the portable alternative to run-analysis.sh (no tmux/session-driver needed)
# Usage: run-analysis-print.sh <repo-path> <prompts-dir> [--model MODEL] [--timeout SECS]

set -euo pipefail

REPO_PATH="${1:?Usage: run-analysis-print.sh <repo-path> <prompts-dir> [--model MODEL] [--timeout SECS]}"
PROMPTS_DIR="${2:?Missing prompts directory}"

# Defaults
MODEL="sonnet"
TIMEOUT=600

# Parse optional args
shift 2
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODEL="$2"; shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

DOCS_DIR="$REPO_PATH/docs"
CONTEXT_DIR="$REPO_PATH/__dc_context"

mkdir -p "$DOCS_DIR"

echo "========================================"
echo " Codebase Documentation Generator"
echo " (print mode — no session-driver needed)"
echo "========================================"
echo " Repository: $REPO_PATH"
echo " Model:      $MODEL"
echo " Timeout:    ${TIMEOUT}s per task"
echo "========================================"

# Verify claude is available
if ! command -v claude &>/dev/null; then
  echo "[ERROR] 'claude' CLI not found. Install Claude Code first." >&2
  exit 1
fi

if [ ! -f "$CONTEXT_DIR/file-tree.txt" ] || [ ! -f "$CONTEXT_DIR/metadata.json" ]; then
  echo "[ERROR] Context files not found. Run crawl-structure.sh and extract-metadata.sh first." >&2
  exit 1
fi

# --- Define documentation tasks in order ---
ALL_PROMPTS=(
  "architecture-overview"
  "api-routes"
  "authentication"
  "service-behaviors"
  "database-connections"
  "edge-cases"
  "tooling-integrations"
  "test-coverage"
  "cicd-pipelines"
  "dependency-map"
  "configuration"
  "getting-started"
)

TOTAL=${#ALL_PROMPTS[@]}
CURRENT=0
SUCCEEDED=0
FAILED=0

for prompt_name in "${ALL_PROMPTS[@]}"; do
  CURRENT=$((CURRENT + 1))
  PROMPT_FILE="$PROMPTS_DIR/${prompt_name}.md"

  if [ ! -f "$PROMPT_FILE" ]; then
    echo "[WARN] Prompt not found: $PROMPT_FILE — skipping"
    FAILED=$((FAILED + 1))
    continue
  fi

  echo ""
  echo "━━━ [$CURRENT/$TOTAL] $prompt_name ━━━"

  PROMPT_CONTENT=$(cat "$PROMPT_FILE")

  # Run claude in print mode with the codebase as working directory
  # --dangerously-skip-permissions allows file reads without prompts
  echo "[run] Analyzing with Claude ($MODEL)..."
  if (cd "$REPO_PATH" && timeout "$TIMEOUT" claude -p "$PROMPT_CONTENT" \
    --model "$MODEL" \
    --dangerously-skip-permissions \
    >/dev/null); then
    echo "[done] $prompt_name completed"
    SUCCEEDED=$((SUCCEEDED + 1))
  else
    echo "[FAIL] $prompt_name failed or timed out"
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "========================================"
echo " Analysis Complete"
echo " Succeeded: $SUCCEEDED/$TOTAL"
echo " Failed:    $FAILED/$TOTAL"
echo "========================================"
echo ""
echo "Generated documentation:"
ls -la "$DOCS_DIR/" 2>/dev/null || echo "  (no docs generated)"
