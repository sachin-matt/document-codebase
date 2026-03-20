#!/usr/bin/env bash
# run-analysis.sh — Orchestrates Claude Code workers to analyze and document a codebase
# Uses claude-session-driver for multi-session orchestration
# Usage: run-analysis.sh <repo-path> <prompts-dir> <scripts-dir> [--parallel N] [--model MODEL] [--timeout SECS]

set -euo pipefail

REPO_PATH="${1:?Usage: run-analysis.sh <repo-path> <prompts-dir> <scripts-dir> [--parallel N] [--model MODEL] [--timeout SECS]}"
PROMPTS_DIR="${2:?Missing prompts directory}"
DRIVER_SCRIPTS="${3:?Missing claude-session-driver scripts directory}"

# Defaults
MAX_PARALLEL=2
MODEL="sonnet"
TIMEOUT=600

# Parse optional args
shift 3
while [[ $# -gt 0 ]]; do
  case "$1" in
    --parallel) MAX_PARALLEL="$2"; shift 2 ;;
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
echo "========================================"
echo " Repository: $REPO_PATH"
echo " Model:      $MODEL"
echo " Parallel:   $MAX_PARALLEL workers"
echo " Timeout:    ${TIMEOUT}s per task"
echo "========================================"

# Verify prerequisites
for cmd in tmux jq claude; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "[ERROR] Required command not found: $cmd" >&2
    exit 1
  fi
done

if [ ! -f "$CONTEXT_DIR/file-tree.txt" ] || [ ! -f "$CONTEXT_DIR/metadata.json" ]; then
  echo "[ERROR] Context files not found. Run crawl-structure.sh and extract-metadata.sh first." >&2
  exit 1
fi

# --- Define documentation tasks ---
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

# --- Sequential worker execution ---
# Process each prompt one at a time using converse.sh for reliability
run_prompt() {
  local prompt_name="$1"
  local worker_name="doc-${prompt_name}"
  local prompt_file="$PROMPTS_DIR/${prompt_name}.md"

  if [ ! -f "$prompt_file" ]; then
    echo "[WARN] Prompt file not found: $prompt_file — skipping" >&2
    return 1
  fi

  echo ""
  echo "[===] Processing: $prompt_name"
  echo "[launch] Starting worker: $worker_name"

  local result
  result=$("$DRIVER_SCRIPTS/launch-worker.sh" "$worker_name" "$REPO_PATH" --model "$MODEL" 2>&1) || {
    echo "[ERROR] Failed to launch worker $worker_name" >&2
    return 1
  }

  local session_id
  session_id=$(echo "$result" | jq -r '.session_id')

  echo "[send] Sending analysis task..."
  local prompt_content
  prompt_content=$(cat "$prompt_file")

  # Use converse.sh for send-and-wait in one step
  local response
  response=$("$DRIVER_SCRIPTS/converse.sh" "$worker_name" "$session_id" "$prompt_content" "$TIMEOUT" 2>&1) || {
    echo "[WARN] Worker $worker_name may have timed out or errored" >&2
  }

  echo "[done] $prompt_name completed"

  # Stop the worker
  "$DRIVER_SCRIPTS/stop-worker.sh" "$worker_name" "$session_id" 2>/dev/null || true

  return 0
}

# --- Execute all prompts ---
TOTAL=${#ALL_PROMPTS[@]}
CURRENT=0

for prompt_name in "${ALL_PROMPTS[@]}"; do
  CURRENT=$((CURRENT + 1))
  echo ""
  echo "━━━ Task $CURRENT/$TOTAL: $prompt_name ━━━"
  run_prompt "$prompt_name" || echo "[SKIP] Failed: $prompt_name"
done

echo ""
echo "=== Documentation Generation Complete ==="
echo "Output: $DOCS_DIR/"
echo ""
ls -la "$DOCS_DIR/"
