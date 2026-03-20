#!/usr/bin/env bash
# build-mkdocs.sh — Generates mkdocs.yml configuration from generated documentation
# Usage: build-mkdocs.sh <repo-path> [project-name]

set -euo pipefail

REPO_PATH="${1:?Usage: build-mkdocs.sh <repo-path> [project-name]}"
PROJECT_NAME="${2:-$(basename "$REPO_PATH")}"
DOCS_DIR="$REPO_PATH/docs"
MKDOCS_FILE="$REPO_PATH/mkdocs.yml"

if [ ! -d "$DOCS_DIR" ]; then
  echo "[ERROR] Docs directory not found: $DOCS_DIR" >&2
  exit 1
fi

echo "[mkdocs] Generating mkdocs.yml for: $PROJECT_NAME"

# Collect all doc files and build nav
NAV_ENTRIES=""
for doc_file in "$DOCS_DIR"/*.md; do
  if [ -f "$doc_file" ]; then
    filename=$(basename "$doc_file")
    # Extract title from first H1 heading
    title=$(head -5 "$doc_file" | grep '^# ' | head -1 | sed 's/^# //')
    if [ -z "$title" ]; then
      # Fallback: generate title from filename
      title=$(echo "$filename" | sed 's/^[0-9]*-//' | sed 's/\.md$//' | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
    fi
    NAV_ENTRIES="${NAV_ENTRIES}    - \"${title}\": \"${filename}\"\n"
  fi
done

# Generate mkdocs.yml
cat > "$MKDOCS_FILE" << YAML
site_name: "${PROJECT_NAME} Documentation"
site_description: "Auto-generated documentation for ${PROJECT_NAME}"
docs_dir: docs

theme:
  name: material
  palette:
    - scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  features:
    - navigation.instant
    - navigation.tracking
    - navigation.sections
    - navigation.expand
    - toc.follow
    - search.suggest
    - search.highlight
    - content.code.copy

plugins:
  - search

markdown_extensions:
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.tabbed:
      alternate_style: true
  - admonition
  - pymdownx.details
  - tables
  - toc:
      permalink: true

nav:
$(echo -e "$NAV_ENTRIES")
YAML

echo "[mkdocs] Configuration written to: $MKDOCS_FILE"
echo ""
echo "To serve the documentation locally:"
echo "  cd $REPO_PATH"
echo "  pip install mkdocs-material"
echo "  mkdocs serve"
echo ""
echo "To build static HTML:"
echo "  mkdocs build"
