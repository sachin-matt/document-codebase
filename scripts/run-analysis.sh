#!/usr/bin/env bash
# run-analysis.sh — Orchestrates Claude Code workers to analyze and document a codebase
# Uses claude-session-driver for multi-session orchestration with parallel workers.
#
# IMPORTANT: Prompts are written to temp files and the worker is told to read them,
# because tmux send-keys -l cannot reliably paste multi-line text (60+ lines).
#
# Usage: run-analysis.sh <repo-path> <prompts-dir> <driver-scripts-dir> [--parallel N] [--model MODEL] [--timeout SECS]

set -euo pipefail

REPO_PATH="${1:?Usage: run-analysis.sh <repo-path> <prompts-dir> <driver-scripts-dir> [--parallel N] [--model MODEL] [--timeout SECS]}"
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
TEMP_PROMPTS_DIR="/tmp/dc-prompts-$$"

mkdir -p "$DOCS_DIR" "$TEMP_PROMPTS_DIR"

# Cleanup temp directory on exit
trap 'rm -rf "$TEMP_PROMPTS_DIR"' EXIT

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
# Phase 1: Independent analyses (can run in parallel)
PHASE1_PROMPTS=(
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
)

# Phase 2: Depends on phase 1 (runs after all phase 1 workers finish)
PHASE2_PROMPTS=(
  "getting-started"
)

# --- Worker management ---
# Arrays to track active workers (bash 3 compatible — no associative arrays needed)
ACTIVE_NAMES=()
ACTIVE_SIDS=()
ACTIVE_TASKS=()

launch_worker() {
  local prompt_name="$1"
  local worker_name="doc-${prompt_name}"
  local prompt_file="$PROMPTS_DIR/${prompt_name}.md"

  if [ ! -f "$prompt_file" ]; then
    echo "[WARN] Prompt file not found: $prompt_file — skipping" >&2
    return 1
  fi

  # Write prompt to a temp file that the worker can read
  local temp_prompt="$TEMP_PROMPTS_DIR/${prompt_name}.md"
  cp "$prompt_file" "$temp_prompt"

  echo "[launch] Starting worker: $worker_name"
  local result
  result=$("$DRIVER_SCRIPTS/launch-worker.sh" "$worker_name" "$REPO_PATH" --model "$MODEL" 2>&1) || {
    echo "[ERROR] Failed to launch worker $worker_name: $result" >&2
    return 1
  }

  local session_id
  session_id=$(echo "$result" | jq -r '.session_id')

  # Send a SHORT instruction that tells the worker to read the prompt file.
  # This avoids the tmux send-keys buffer overflow with large prompts.
  local instruction="Read the file ${temp_prompt} — it contains your full instructions. Follow every instruction in that file exactly."
  "$DRIVER_SCRIPTS/send-prompt.sh" "$worker_name" "$instruction"

  echo "[send] Sent task to $worker_name: $prompt_name (reading from temp file)"

  # Track the active worker
  ACTIVE_NAMES+=("$worker_name")
  ACTIVE_SIDS+=("$session_id")
  ACTIVE_TASKS+=("$prompt_name")

  return 0
}

wait_for_any_worker() {
  # Wait for the first active worker to finish, then remove it from tracking
  if [ ${#ACTIVE_NAMES[@]} -eq 0 ]; then
    return 1
  fi

  # Poll all active workers, first to finish wins
  while true; do
    for i in "${!ACTIVE_NAMES[@]}"; do
      local wname="${ACTIVE_NAMES[$i]}"
      local sid="${ACTIVE_SIDS[$i]}"
      local task="${ACTIVE_TASKS[$i]}"

      # Check if this worker's stop event exists (non-blocking check)
      if "$DRIVER_SCRIPTS/wait-for-event.sh" "$sid" stop 5 --after-line 0 >/dev/null 2>&1; then
        echo "[done] $wname completed: $task"

        # Stop and cleanup the worker
        "$DRIVER_SCRIPTS/stop-worker.sh" "$wname" "$sid" 2>/dev/null || true

        # Remove from active arrays
        unset 'ACTIVE_NAMES[i]'
        unset 'ACTIVE_SIDS[i]'
        unset 'ACTIVE_TASKS[i]'
        # Reindex arrays
        ACTIVE_NAMES=("${ACTIVE_NAMES[@]}")
        ACTIVE_SIDS=("${ACTIVE_SIDS[@]}")
        ACTIVE_TASKS=("${ACTIVE_TASKS[@]}")
        return 0
      fi
    done
    # Brief sleep before polling again
    sleep 2
  done
}

wait_for_all_workers() {
  while [ ${#ACTIVE_NAMES[@]} -gt 0 ]; do
    wait_for_any_worker
  done
}

cleanup_all_workers() {
  for i in "${!ACTIVE_NAMES[@]}"; do
    local wname="${ACTIVE_NAMES[$i]}"
    local sid="${ACTIVE_SIDS[$i]}"
    echo "[cleanup] Stopping $wname..."
    "$DRIVER_SCRIPTS/stop-worker.sh" "$wname" "$sid" 2>/dev/null || true
  done
  ACTIVE_NAMES=()
  ACTIVE_SIDS=()
  ACTIVE_TASKS=()
}

# Trap to ensure workers are cleaned up on script exit
trap 'cleanup_all_workers; rm -rf "$TEMP_PROMPTS_DIR"' EXIT

# --- Phase 1: Run independent analyses with controlled parallelism ---
echo ""
echo "=== Phase 1: Independent Analyses (up to $MAX_PARALLEL parallel) ==="
echo ""

QUEUE=("${PHASE1_PROMPTS[@]}")
TOTAL_PHASE1=${#PHASE1_PROMPTS[@]}
LAUNCHED=0

while [ ${#QUEUE[@]} -gt 0 ] || [ ${#ACTIVE_NAMES[@]} -gt 0 ]; do
  # Launch workers up to MAX_PARALLEL
  while [ ${#ACTIVE_NAMES[@]} -lt "$MAX_PARALLEL" ] && [ ${#QUEUE[@]} -gt 0 ]; do
    next_task="${QUEUE[0]}"
    QUEUE=("${QUEUE[@]:1}")  # Remove first element

    LAUNCHED=$((LAUNCHED + 1))
    echo ""
    echo "━━━ [$LAUNCHED/$TOTAL_PHASE1] Launching: $next_task ━━━"
    launch_worker "$next_task" || echo "[SKIP] Failed to launch: $next_task"
  done

  # Wait for one worker to finish before launching more
  if [ ${#ACTIVE_NAMES[@]} -ge "$MAX_PARALLEL" ] || ([ ${#QUEUE[@]} -eq 0 ] && [ ${#ACTIVE_NAMES[@]} -gt 0 ]); then
    wait_for_any_worker
  fi
done

# --- Phase 2: Dependent analyses (sequential, after all phase 1 done) ---
echo ""
echo "=== Phase 2: Dependent Analyses ==="
echo ""

for prompt_name in "${PHASE2_PROMPTS[@]}"; do
  echo "━━━ Phase 2: $prompt_name ━━━"
  if launch_worker "$prompt_name"; then
    wait_for_all_workers
  fi
done

echo ""
echo "=== Documentation Generation Complete ==="
echo "Output: $DOCS_DIR/"
echo ""
ls -la "$DOCS_DIR/"
