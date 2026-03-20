#!/usr/bin/env bash
# generate-docs.sh — Main entry point for the Codebase Documentation Generator
#
# This script orchestrates the full documentation pipeline:
#   1. Crawl the codebase structure
#   2. Extract project metadata
#   3. Launch Claude Code to analyze and document each aspect
#   4. Generate MkDocs configuration
#
# Two execution modes:
#   - Print mode (default): Uses `claude -p` for each prompt. Simple, portable.
#   - Session mode: Uses claude-session-driver for tmux-based workers. More
#     robust for long analyses, supports parallel workers.
#
# Prerequisites:
#   - claude CLI (Claude Code)
#   - For session mode: tmux, jq, claude-session-driver
#
# Usage:
#   ./generate-docs.sh <repo-path> [options]
#
# Options:
#   --mode MODE        Execution mode: "print" (default) or "session"
#   --parallel N       Max parallel Claude workers — session mode only (default: 2)
#   --model MODEL      Claude model to use (default: sonnet)
#   --timeout SECS     Timeout per analysis task in seconds (default: 600)
#   --driver-path PATH Path to claude-session-driver scripts/ (session mode)
#   --clean            Remove existing docs/ and __dc_context/ before starting
#   --skip-analysis    Skip the AI analysis phase (only crawl + metadata)
#   --only PROMPT      Run only a specific prompt (e.g., --only api-routes)
#   --help             Show this help message
#
# Examples:
#   ./generate-docs.sh /path/to/my-repo
#   ./generate-docs.sh /path/to/my-repo --model opus --timeout 900
#   ./generate-docs.sh /path/to/my-repo --only api-routes
#   ./generate-docs.sh /path/to/my-repo --mode session --parallel 4
#   ./generate-docs.sh /path/to/my-repo --clean

set -euo pipefail

# --- Resolve script paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

# --- Defaults ---
REPO_PATH=""
MODE="print"
MAX_PARALLEL=2
MODEL="sonnet"
TIMEOUT=600
DRIVER_PATH=""
CLEAN=false
SKIP_ANALYSIS=false
ONLY_PROMPT=""

# --- Parse arguments ---
show_help() {
  sed -n '2,/^$/s/^# \?//p' "$0"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) show_help ;;
    --mode) MODE="$2"; shift 2 ;;
    --parallel) MAX_PARALLEL="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    --driver-path) DRIVER_PATH="$2"; shift 2 ;;
    --clean) CLEAN=true; shift ;;
    --skip-analysis) SKIP_ANALYSIS=true; shift ;;
    --only) ONLY_PROMPT="$2"; shift 2 ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) REPO_PATH="$1"; shift ;;
  esac
done

if [ -z "$REPO_PATH" ]; then
  echo "Error: No repository path provided." >&2
  echo "Usage: $0 <repo-path> [options]" >&2
  echo "Run '$0 --help' for full usage." >&2
  exit 1
fi

# Resolve to absolute path
REPO_PATH="$(cd "$REPO_PATH" && pwd)"

# --- Validate mode ---
if [ "$MODE" = "session" ]; then
  # Auto-detect claude-session-driver
  if [ -z "$DRIVER_PATH" ]; then
    PARENT_DIR="$(dirname "$SCRIPT_DIR")"
    for candidate in \
      "$PARENT_DIR/claude-session-driver/scripts" \
      "$PARENT_DIR/claude-session-driver/plugin/scripts" \
      "$HOME/.claude/plugins/claude-session-driver/scripts" \
      ; do
      if [ -d "$candidate" ] && [ -f "$candidate/launch-worker.sh" ]; then
        DRIVER_PATH="$candidate"
        break
      fi
    done

    if [ -z "$DRIVER_PATH" ]; then
      echo "[WARN] Could not find claude-session-driver. Falling back to print mode." >&2
      MODE="print"
    fi
  fi
fi

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║     Codebase Documentation Generator             ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "  Repository:     $REPO_PATH"
echo "  Mode:           $MODE"
echo "  Model:          $MODEL"
echo "  Timeout:        ${TIMEOUT}s per task"
if [ "$MODE" = "session" ]; then
  echo "  Parallel:       $MAX_PARALLEL workers"
  echo "  Driver:         $DRIVER_PATH"
fi
echo "  Prompts:        $PROMPTS_DIR"
echo ""

# --- Clean if requested ---
if $CLEAN; then
  echo "[clean] Removing existing docs/ and __dc_context/..."
  rm -rf "$REPO_PATH/docs" "$REPO_PATH/__dc_context"
fi

# --- Step 1: Crawl structure ---
echo "━━━ Step 1/4: Crawling codebase structure ━━━"
bash "$SCRIPTS_DIR/crawl-structure.sh" "$REPO_PATH"

# --- Step 2: Extract metadata ---
echo ""
echo "━━━ Step 2/4: Extracting project metadata ━━━"
bash "$SCRIPTS_DIR/extract-metadata.sh" "$REPO_PATH"

# --- Step 3: AI Analysis ---
if $SKIP_ANALYSIS; then
  echo ""
  echo "━━━ Step 3/4: Skipped (--skip-analysis) ━━━"
else
  echo ""
  echo "━━━ Step 3/4: AI-powered documentation generation ━━━"

  if [ -n "$ONLY_PROMPT" ]; then
    # --- Single prompt mode ---
    echo "[single] Running only: $ONLY_PROMPT"
    PROMPT_FILE="$PROMPTS_DIR/${ONLY_PROMPT}.md"
    if [ ! -f "$PROMPT_FILE" ]; then
      echo "[ERROR] Prompt not found: $PROMPT_FILE" >&2
      echo "Available prompts:" >&2
      ls "$PROMPTS_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | sed 's/^/  /' >&2
      exit 1
    fi

    mkdir -p "$REPO_PATH/docs"
    PROMPT_CONTENT=$(cat "$PROMPT_FILE")

    if [ "$MODE" = "session" ]; then
      WORKER_NAME="doc-${ONLY_PROMPT}"
      RESULT=$("$DRIVER_PATH/launch-worker.sh" "$WORKER_NAME" "$REPO_PATH" --model "$MODEL")
      SESSION_ID=$(echo "$RESULT" | jq -r '.session_id')
      "$DRIVER_PATH/converse.sh" "$WORKER_NAME" "$SESSION_ID" "$PROMPT_CONTENT" "$TIMEOUT" 2>/dev/null || true
      "$DRIVER_PATH/stop-worker.sh" "$WORKER_NAME" "$SESSION_ID" 2>/dev/null || true
    else
      echo "[run] Analyzing with Claude ($MODEL)..."
      (cd "$REPO_PATH" && timeout "$TIMEOUT" claude -p "$PROMPT_CONTENT" \
        --model "$MODEL" \
        --dangerously-skip-permissions \
        >/dev/null) || echo "[WARN] Analysis may have timed out"
    fi
    echo "[done] $ONLY_PROMPT completed"

  elif [ "$MODE" = "session" ]; then
    # --- Full session mode ---
    bash "$SCRIPTS_DIR/run-analysis.sh" "$REPO_PATH" "$PROMPTS_DIR" "$DRIVER_PATH" \
      --parallel "$MAX_PARALLEL" --model "$MODEL" --timeout "$TIMEOUT"
  else
    # --- Full print mode ---
    bash "$SCRIPTS_DIR/run-analysis-print.sh" "$REPO_PATH" "$PROMPTS_DIR" \
      --model "$MODEL" --timeout "$TIMEOUT"
  fi
fi

# --- Step 4: Generate MkDocs config ---
echo ""
echo "━━━ Step 4/4: Generating MkDocs configuration ━━━"
bash "$SCRIPTS_DIR/build-mkdocs.sh" "$REPO_PATH" "$(basename "$REPO_PATH")"

# --- Cleanup context ---
echo ""
echo "[cleanup] Removing temporary context files..."
rm -rf "$REPO_PATH/__dc_context"

# --- Summary ---
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║     Documentation Complete!                      ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "  Output directory: $REPO_PATH/docs/"
echo "  MkDocs config:    $REPO_PATH/mkdocs.yml"
echo ""
echo "  Generated files:"
if [ -d "$REPO_PATH/docs" ]; then
  for f in "$REPO_PATH/docs"/*.md; do
    [ -f "$f" ] && echo "    - $(basename "$f")"
  done
fi
echo ""
echo "  To serve locally:"
echo "    cd $REPO_PATH"
echo "    pip install mkdocs-material"
echo "    mkdocs serve"
echo ""
