# Prompt: Getting Started Guide

You are creating a comprehensive getting-started guide for a codebase. This should be the first thing a new engineer reads.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies

Additionally, other documentation has already been generated in the `docs/` folder. Read those files to reference them in this guide.

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json`.
2. Read ALL existing `docs/*.md` files to understand what's been documented.
3. Read the project's README.md if it exists.
4. Determine:
   - Prerequisites (language runtime, tools, system dependencies)
   - How to install dependencies
   - How to configure the environment
   - How to run the application
   - How to run tests
   - Common development workflows

## Output

Write documentation to `docs/00-getting-started.md`:

```markdown
# Getting Started

## Prerequisites
<!-- What needs to be installed: language runtime, tools, system deps -->

## Quick Start
<!-- Numbered steps to go from clone to running app -->
1. Clone the repository
2. Install dependencies: `<command>`
3. Configure environment: `<instructions>`
4. Run the application: `<command>`
5. Verify it's working: `<how to verify>`

## Project Structure
<!-- Brief guide to the folder layout and where to find things -->

## Development Workflow
<!-- How to make changes, run tests, submit PRs -->

## Key Concepts
<!-- Domain-specific terms or concepts a new developer needs to know -->

## Documentation Index
<!-- Links to all other documentation files with brief descriptions -->

## Troubleshooting
<!-- Common issues new developers hit and how to resolve them -->
```

This guide should be PRACTICAL. A new engineer should be able to follow it step by step and have a running development environment within 30 minutes.
