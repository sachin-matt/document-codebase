# document-codebase

An AI-powered codebase documentation generator that uses [Claude Code](https://docs.anthropic.com/en/docs/claude-code) to crawl any repository and produce comprehensive, structured documentation — the kind of tribal knowledge that usually lives only in senior engineers' heads.

## The Problem

In traditional engineering teams, deep codebase knowledge tends to concentrate in a few people. When they're unavailable, onboarding slows, collaboration suffers, and using AI tools effectively requires the same deep understanding the AI was supposed to help with.

**document-codebase** solves this by generating a complete knowledge base from your code — covering architecture, API routes, authentication flows, service behaviors, database schemas, edge cases, test coverage, CI/CD pipelines, and more.

## What It Generates

Running the tool against a repository produces a `docs/` folder with **12 structured documentation files** and a ready-to-serve MkDocs configuration:

| File | Covers |
|------|--------|
| `00-getting-started.md` | Prerequisites, quick start, project structure, dev workflow |
| `01-architecture-overview.md` | System design, tech stack, component diagrams, data flow |
| `02-api-routes.md` | Every endpoint with parameters, types, auth, and examples |
| `03-authentication.md` | Auth mechanisms, token flows, middleware, permission models |
| `04-service-behaviors.md` | Business logic, method-level docs, state management |
| `05-database-connections.md` | Data models, schemas, storage patterns, migrations |
| `06-edge-cases.md` | Error handling, boundary conditions, failure modes |
| `07-tooling-integrations.md` | External services, SDKs, third-party dependencies |
| `08-test-coverage.md` | Test structure, coverage analysis, gaps identified |
| `09-cicd-pipelines.md` | Build, deploy, release workflows and configurations |
| `10-dependency-map.md` | Internal module relationships, external dependency tree |
| `11-configuration.md` | Environment variables, config files, feature flags |

Plus a `mkdocs.yml` for instant browsable documentation.

## Prerequisites

- **Claude Code CLI** — [Install guide](https://docs.anthropic.com/en/docs/claude-code/getting-started)
- **Bash 4+**
- **Python 3** (for metadata extraction)

For the session-driver mode (parallel workers):
- **tmux**
- **jq**
- [claude-session-driver](https://github.com/anthropics/claude-session-driver) cloned as a sibling directory

## Quick Start

```bash
# Clone this repository
git clone https://github.com/<your-username>/document-codebase.git
cd document-codebase

# Make scripts executable (if not already)
chmod +x generate-docs.sh scripts/*.sh

# Generate documentation for any repo
./generate-docs.sh /path/to/your-repo
```

That's it. The tool will:
1. Crawl the file structure
2. Extract language, framework, dependencies, and project metadata
3. Run Claude Code against 12 specialized prompts to analyze the codebase
4. Generate a `mkdocs.yml` configuration
5. Output everything to `your-repo/docs/`

## Usage

### Basic (print mode)

```bash
# Default — analyzes everything, uses Claude Sonnet
./generate-docs.sh /path/to/repo

# Use a different model
./generate-docs.sh /path/to/repo --model opus

# Increase timeout for large codebases (default: 600s per topic)
./generate-docs.sh /path/to/repo --timeout 900

# Generate only one specific topic
./generate-docs.sh /path/to/repo --only api-routes

# Clean existing docs and regenerate from scratch
./generate-docs.sh /path/to/repo --clean
```

### Session mode (parallel workers via tmux)

If you have [claude-session-driver](https://github.com/anthropics/claude-session-driver) cloned alongside this repo, you can run multiple analysis tasks in parallel:

```bash
# Auto-detects session-driver in sibling directory
./generate-docs.sh /path/to/repo --mode session --parallel 4

# Or specify the driver path explicitly
./generate-docs.sh /path/to/repo --mode session --driver-path /path/to/claude-session-driver/scripts
```

### All options

```
./generate-docs.sh <repo-path> [options]

Options:
  --mode MODE        "print" (default) or "session"
  --parallel N       Max parallel workers — session mode only (default: 2)
  --model MODEL      Claude model: sonnet, opus, haiku (default: sonnet)
  --timeout SECS     Timeout per analysis task (default: 600)
  --driver-path PATH Path to claude-session-driver scripts/
  --clean            Remove existing docs/ before starting
  --skip-analysis    Only crawl + metadata, skip AI analysis
  --only PROMPT      Run only one prompt (e.g., --only api-routes)
  --help             Show help
```

## Serving the Documentation

The generator creates a `mkdocs.yml` in your repository root configured for the [Material for MkDocs](https://squidfundly.github.io/mkdocs-material/) theme.

### Local development server

```bash
cd /path/to/your-repo

# Install MkDocs with the Material theme
pip install mkdocs-material

# Start the development server (live-reloading)
mkdocs serve
```

Open [http://127.0.0.1:8000](http://127.0.0.1:8000) in your browser. The server watches for file changes and reloads automatically.

### Build static HTML

```bash
cd /path/to/your-repo
mkdocs build
```

This creates a `site/` directory with static HTML you can host anywhere — GitHub Pages, Netlify, S3, etc.

### Deploy to GitHub Pages

```bash
cd /path/to/your-repo
mkdocs gh-deploy
```

This builds and pushes to the `gh-pages` branch automatically.

## How It Works

The pipeline has four stages:

### 1. Crawl structure (`scripts/crawl-structure.sh`)
Generates a complete file tree (respecting `.gitignore`) and a directory-level structure map. These go into a temporary `__dc_context/` folder.

### 2. Extract metadata (`scripts/extract-metadata.sh`)
Auto-detects language, framework, dependencies, CI/CD tools, testing frameworks, entry points, and environment config. Produces a `metadata.json` that Claude uses for context.

### 3. AI analysis (`scripts/run-analysis-print.sh` or `run-analysis.sh`)
For each of the 12 documentation topics, sends a specialized prompt to Claude Code. Each prompt instructs Claude to:
- Read the file tree and metadata
- Explore relevant source files
- Analyze patterns, behaviors, and architecture
- Write structured markdown documentation to `docs/`

### 4. Build MkDocs config (`scripts/build-mkdocs.sh`)
Scans the generated `docs/` folder, extracts titles from each file, and produces a `mkdocs.yml` with proper navigation, Material theme, and useful extensions (code highlighting, Mermaid diagrams, tabbed content, admonitions).

## Customization

### Add new documentation topics

1. Create a new prompt file in `prompts/` (e.g., `prompts/security-audit.md`)
2. Follow the pattern of existing prompts — include instructions to read `__dc_context/`, analyze relevant files, and write output to `docs/`
3. Add the prompt name to the `ALL_PROMPTS` array in `scripts/run-analysis-print.sh` and `scripts/run-analysis.sh`

### Modify existing prompts

Each prompt in `prompts/` is a standalone markdown file. Edit them to adjust the depth, format, or focus areas of the generated documentation.

### Language support

The tool works with **any programming language**. The metadata extractor has specific detectors for Python, JavaScript/TypeScript, Go, Rust, and Java, but Claude Code will analyze whatever language it finds. The prompts are language-agnostic.

## Project Structure

```
document-codebase/
├── README.md                        # This file
├── generate-docs.sh                 # Main entry point
├── prompts/                         # 12 analysis prompt files
│   ├── architecture-overview.md     # System design & tech stack
│   ├── api-routes.md                # HTTP endpoints & contracts
│   ├── authentication.md            # Auth flows & security
│   ├── service-behaviors.md         # Business logic & services
│   ├── database-connections.md      # Data models & storage
│   ├── edge-cases.md                # Error handling & boundaries
│   ├── tooling-integrations.md      # External services & SDKs
│   ├── test-coverage.md             # Test analysis & gaps
│   ├── cicd-pipelines.md            # Build & deploy workflows
│   ├── dependency-map.md            # Module & package relationships
│   ├── configuration.md             # Env vars & config files
│   └── getting-started.md           # Onboarding guide (runs last)
└── scripts/
    ├── crawl-structure.sh           # File tree generator
    ├── extract-metadata.sh          # Language/framework detector
    ├── run-analysis-print.sh        # Claude print-mode orchestrator
    ├── run-analysis.sh              # Claude session-driver orchestrator
    └── build-mkdocs.sh              # MkDocs config generator
```

## Example Output

Tested against a Python/FastAPI market data simulation service, the tool generated **2,557 lines** across 12 files, including:

- ASCII architecture diagrams with component relationships
- Full API route tables with parameters, types, and constraints
- Method-level service documentation with business rules
- Storage patterns and data model schemas
- Test coverage analysis with per-file breakdowns
- Real bug identification (non-functional endpoints, blocking async handlers)

## License

MIT
