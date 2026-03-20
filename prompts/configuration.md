# Prompt: Configuration & Environment Documentation

You are documenting all configuration mechanisms, environment variables, and settings management in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Find all configuration sources:
   - `.env`, `.env.example`, `.env.test` files
   - Config files (config.py, settings.py, config.yaml, etc.)
   - Config classes/modules that load environment variables
   - Feature flags
   - Command-line argument parsing
3. Document every environment variable and config setting found.

## Output

Write documentation to `docs/11-configuration.md`:

```markdown
# Configuration & Environment

## Configuration Strategy
<!-- How config is loaded: env vars, files, config services, hierarchy/precedence -->

## Environment Variables
| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| ... | ... | ... | ... | ... |

## Configuration Files
<!-- For each config file: what it controls, format, key settings -->

## Environment Profiles
<!-- Different configs for dev/staging/prod, how they're selected -->

## Secrets Management
<!-- How secrets are handled (vault, env vars, etc.) — NO actual values -->

## Setup Guide
<!-- Step-by-step: how to configure the app from scratch for local development -->
```

CRITICAL: Never include actual secret values, API keys, or credentials. Only document variable names and descriptions.
