#!/usr/bin/env bash
# crawl-structure.sh — Generates a file tree and identifies key files in a codebase
# Usage: crawl-structure.sh <repo-path>

set -euo pipefail

REPO_PATH="${1:?Usage: crawl-structure.sh <repo-path>}"
CONTEXT_DIR="$REPO_PATH/__dc_context"

mkdir -p "$CONTEXT_DIR"

echo "[crawl] Generating file tree for: $REPO_PATH"

# Generate file tree (excluding common noise directories)
find "$REPO_PATH" \
  -not -path '*/.git/*' \
  -not -path '*/.git' \
  -not -path '*/__dc_context/*' \
  -not -path '*/__dc_context' \
  -not -path '*/node_modules/*' \
  -not -path '*/.venv/*' \
  -not -path '*/venv/*' \
  -not -path '*/.env' \
  -not -path '*/__pycache__/*' \
  -not -path '*/.mypy_cache/*' \
  -not -path '*/.pytest_cache/*' \
  -not -path '*/.tox/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/.next/*' \
  -not -path '*/.nuxt/*' \
  -not -path '*/coverage/*' \
  -not -path '*/.cache/*' \
  -not -path '*/.DS_Store' \
  -not -path '*/*.pyc' \
  -not -path '*/*.pyo' \
  -not -name '*.lock' \
  -not -name 'package-lock.json' \
  -not -name 'yarn.lock' \
  -not -name 'pnpm-lock.yaml' \
  -type f \
  | sed "s|^$REPO_PATH/||" \
  | sort \
  > "$CONTEXT_DIR/file-tree.txt"

FILE_COUNT=$(wc -l < "$CONTEXT_DIR/file-tree.txt")
echo "[crawl] Found $FILE_COUNT files"

# Generate directory structure (tree-like)
find "$REPO_PATH" \
  -not -path '*/.git/*' \
  -not -path '*/.git' \
  -not -path '*/__dc_context/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/.venv/*' \
  -not -path '*/venv/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/.mypy_cache/*' \
  -not -path '*/.pytest_cache/*' \
  -type d \
  | sed "s|^$REPO_PATH||" \
  | sort \
  > "$CONTEXT_DIR/directory-structure.txt"

echo "[crawl] File tree saved to $CONTEXT_DIR/file-tree.txt"
echo "[crawl] Directory structure saved to $CONTEXT_DIR/directory-structure.txt"
