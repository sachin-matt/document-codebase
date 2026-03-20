#!/usr/bin/env bash
# extract-metadata.sh — Extracts project metadata: language, framework, dependencies, etc.
# Usage: extract-metadata.sh <repo-path>

set -euo pipefail

REPO_PATH="${1:?Usage: extract-metadata.sh <repo-path>}"
CONTEXT_DIR="$REPO_PATH/__dc_context"
META_FILE="$CONTEXT_DIR/metadata.json"

mkdir -p "$CONTEXT_DIR"

echo "[meta] Extracting metadata from: $REPO_PATH"

# --- Detect language ---
detect_language() {
  local lang="unknown"
  local framework="unknown"

  if [ -f "$REPO_PATH/requirements.txt" ] || [ -f "$REPO_PATH/setup.py" ] || [ -f "$REPO_PATH/pyproject.toml" ] || [ -f "$REPO_PATH/Pipfile" ]; then
    lang="python"
    # Detect Python framework
    local req_files=$(cat "$REPO_PATH/requirements.txt" "$REPO_PATH/setup.py" "$REPO_PATH/pyproject.toml" 2>/dev/null || true)
    if echo "$req_files" | grep -qi "fastapi"; then framework="fastapi"
    elif echo "$req_files" | grep -qi "flask"; then framework="flask"
    elif echo "$req_files" | grep -qi "django"; then framework="django"
    elif echo "$req_files" | grep -qi "starlette"; then framework="starlette"
    fi
  elif [ -f "$REPO_PATH/package.json" ]; then
    lang="javascript/typescript"
    local pkg=$(cat "$REPO_PATH/package.json")
    if echo "$pkg" | grep -q '"next"'; then framework="nextjs"
    elif echo "$pkg" | grep -q '"express"'; then framework="express"
    elif echo "$pkg" | grep -q '"react"'; then framework="react"
    elif echo "$pkg" | grep -q '"vue"'; then framework="vue"
    elif echo "$pkg" | grep -q '"@nestjs"'; then framework="nestjs"
    fi
  elif [ -f "$REPO_PATH/go.mod" ]; then
    lang="go"
    if grep -q "gin-gonic" "$REPO_PATH/go.mod" 2>/dev/null; then framework="gin"
    elif grep -q "gorilla/mux" "$REPO_PATH/go.mod" 2>/dev/null; then framework="gorilla"
    elif grep -q "fiber" "$REPO_PATH/go.mod" 2>/dev/null; then framework="fiber"
    fi
  elif [ -f "$REPO_PATH/Cargo.toml" ]; then
    lang="rust"
    if grep -q "actix" "$REPO_PATH/Cargo.toml" 2>/dev/null; then framework="actix"
    elif grep -q "rocket" "$REPO_PATH/Cargo.toml" 2>/dev/null; then framework="rocket"
    fi
  elif [ -f "$REPO_PATH/pom.xml" ] || [ -f "$REPO_PATH/build.gradle" ]; then
    lang="java"
    if grep -q "spring" "$REPO_PATH/pom.xml" "$REPO_PATH/build.gradle" 2>/dev/null; then framework="spring"
    fi
  fi

  echo "$lang|$framework"
}

# --- Extract dependencies ---
extract_deps() {
  if [ -f "$REPO_PATH/requirements.txt" ]; then
    cat "$REPO_PATH/requirements.txt" | grep -v '^#' | grep -v '^$' | head -50
  elif [ -f "$REPO_PATH/package.json" ]; then
    python3 -c "
import json, sys
try:
    pkg = json.load(open('$REPO_PATH/package.json'))
    deps = list(pkg.get('dependencies', {}).keys())
    dev = list(pkg.get('devDependencies', {}).keys())
    print('\n'.join(deps[:30]))
    if dev:
        print('--- dev ---')
        print('\n'.join(dev[:20]))
except: pass
" 2>/dev/null || echo "parse_error"
  elif [ -f "$REPO_PATH/go.mod" ]; then
    grep "^\t" "$REPO_PATH/go.mod" 2>/dev/null | awk '{print $1}' | head -30
  elif [ -f "$REPO_PATH/Cargo.toml" ]; then
    grep -A100 '\[dependencies\]' "$REPO_PATH/Cargo.toml" 2>/dev/null | grep -v '^\[' | grep '=' | head -30
  else
    echo "none_found"
  fi
}

# --- Detect CI/CD ---
detect_cicd() {
  local cicd=""
  [ -d "$REPO_PATH/.github/workflows" ] && cicd="${cicd}github_actions,"
  [ -f "$REPO_PATH/.gitlab-ci.yml" ] && cicd="${cicd}gitlab_ci,"
  [ -f "$REPO_PATH/Jenkinsfile" ] && cicd="${cicd}jenkins,"
  [ -f "$REPO_PATH/.circleci/config.yml" ] && cicd="${cicd}circleci,"
  [ -f "$REPO_PATH/Dockerfile" ] && cicd="${cicd}docker,"
  [ -f "$REPO_PATH/docker-compose.yml" ] || [ -f "$REPO_PATH/docker-compose.yaml" ] && cicd="${cicd}docker_compose,"
  [ -f "$REPO_PATH/Makefile" ] && cicd="${cicd}makefile,"
  [ -f "$REPO_PATH/cloudbuild.yaml" ] && cicd="${cicd}cloud_build,"
  echo "${cicd%,}"
}

# --- Detect testing ---
detect_testing() {
  local testing=""
  [ -d "$REPO_PATH/tests" ] || [ -d "$REPO_PATH/test" ] || [ -d "$REPO_PATH/__tests__" ] && testing="${testing}test_directory,"
  grep -rq "pytest" "$REPO_PATH/requirements.txt" "$REPO_PATH/requirements-dev.txt" "$REPO_PATH/pyproject.toml" 2>/dev/null && testing="${testing}pytest,"
  grep -rq "jest" "$REPO_PATH/package.json" 2>/dev/null && testing="${testing}jest,"
  grep -rq "mocha" "$REPO_PATH/package.json" 2>/dev/null && testing="${testing}mocha,"
  echo "${testing%,}"
}

# --- Detect entry points ---
detect_entry_points() {
  local entries=""
  for f in main.py app.py run.py manage.py server.py index.ts index.js app.ts app.js main.go main.rs; do
    if [ -f "$REPO_PATH/$f" ]; then
      entries="${entries}${f},"
    fi
  done
  # Also check src/ directory
  for f in src/main.py src/app.py src/index.ts src/index.js src/main.go; do
    if [ -f "$REPO_PATH/$f" ]; then
      entries="${entries}${f},"
    fi
  done
  echo "${entries%,}"
}

# --- Check for env example ---
detect_env_files() {
  local envs=""
  for f in .env.example .env.sample .env.template .env.test; do
    if [ -f "$REPO_PATH/$f" ]; then
      envs="${envs}${f},"
    fi
  done
  echo "${envs%,}"
}

# --- Run detections ---
LANG_FRAMEWORK=$(detect_language)
LANGUAGE=$(echo "$LANG_FRAMEWORK" | cut -d'|' -f1)
FRAMEWORK=$(echo "$LANG_FRAMEWORK" | cut -d'|' -f2)
DEPS=$(extract_deps)
CICD=$(detect_cicd)
TESTING=$(detect_testing)
ENTRIES=$(detect_entry_points)
ENV_FILES=$(detect_env_files)
HAS_README="False"
[ -f "$REPO_PATH/README.md" ] && HAS_README="True"

FILE_COUNT=$(wc -l < "$CONTEXT_DIR/file-tree.txt" 2>/dev/null || echo "0")

# --- Write metadata JSON ---
python3 -c "
import json
data = {
    'project_path': '$REPO_PATH',
    'language': '$LANGUAGE',
    'framework': '$FRAMEWORK',
    'file_count': int('$FILE_COUNT'.strip()),
    'dependencies': [d.strip() for d in '''$DEPS'''.strip().split('\n') if d.strip()],
    'cicd': [c for c in '$CICD'.split(',') if c],
    'testing': [t for t in '$TESTING'.split(',') if t],
    'entry_points': [e for e in '$ENTRIES'.split(',') if e],
    'env_files': [e for e in '$ENV_FILES'.split(',') if e],
    'has_readme': $HAS_README
}
with open('$META_FILE', 'w') as f:
    json.dump(data, f, indent=2)
print(json.dumps(data, indent=2))
"

echo "[meta] Metadata saved to $META_FILE"
