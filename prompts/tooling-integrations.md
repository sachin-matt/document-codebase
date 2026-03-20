# Prompt: Tooling & Integrations Documentation

You are documenting all external integrations, third-party services, SDKs, and developer tooling in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Identify all external integrations:
   - Third-party APIs (Stripe, Twilio, SendGrid, AWS services, etc.)
   - Monitoring/observability (Datadog, Sentry, Prometheus, etc.)
   - Logging frameworks and configuration
   - Feature flags (LaunchDarkly, Unleash, etc.)
   - Analytics (Segment, Mixpanel, etc.)
   - Cloud provider SDKs
3. Identify developer tooling:
   - Linters, formatters (ESLint, Black, Prettier, etc.)
   - Type checkers (mypy, TypeScript, etc.)
   - Pre-commit hooks
   - Code generation tools
   - Documentation generators
   - Build tools (webpack, vite, gradle, make, etc.)

## Output

Write documentation to `docs/07-tooling-integrations.md`:

```markdown
# Tooling & Integrations

## External Service Integrations

### [Service Name]
- **Purpose**: Why it's used
- **SDK/Client**: Library or client used
- **Configuration**: Env vars needed (no actual values)
- **Usage Locations**: Where in the code it's called
- **Error Handling**: How failures are handled

<!-- Repeat for each integration -->

## Monitoring & Observability
<!-- Logging setup, metrics, tracing, alerting -->

## Developer Tooling
<!-- Linters, formatters, type checkers, pre-commit hooks -->

## Build System
<!-- Build tools, compilation steps, asset pipeline -->

## Environment Variables Summary
<!-- Complete list of all env vars referenced in the codebase -->
| Variable | Purpose | Required | Default |
|----------|---------|----------|---------|
| ... | ... | ... | ... |
```
