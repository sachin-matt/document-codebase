# Prompt: Architecture Overview

You are a senior software architect documenting a codebase. Your task is to produce a comprehensive **Architecture Overview** document.

## Context

You have been given access to a codebase. The file tree and metadata have been pre-extracted and saved to:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies, language, framework detection

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Identify the primary language, framework, and architectural pattern (MVC, microservices, monolith, hexagonal, etc.).
3. Read the main entry point(s) of the application (e.g., `main.py`, `app.py`, `index.ts`, `main.go`, etc.).
4. Read key configuration files (e.g., `settings.py`, `config/`, `.env.example`).
5. Trace the high-level request flow from entry to response.
6. Identify all major modules/packages and their responsibilities.
7. Map the dependency graph between modules (which module calls which).

## Output

Write the documentation to `docs/01-architecture-overview.md` with this structure:

```markdown
# Architecture Overview

## System Summary
<!-- 2-3 sentence description of what the system does and its primary purpose -->

## Tech Stack
<!-- Language, framework, key libraries, runtime requirements -->

## Architectural Pattern
<!-- Name the pattern and explain how this codebase implements it -->

## High-Level Architecture Diagram
<!-- ASCII diagram or mermaid diagram showing major components and data flow -->

## Module Breakdown
<!-- For each top-level module/package:
  - Name
  - Responsibility (1-2 sentences)
  - Key files
  - Dependencies on other modules
-->

## Entry Points
<!-- How the application starts, what bootstrapping happens -->

## Request/Data Flow
<!-- Trace a typical request from ingress to response -->

## Key Design Decisions
<!-- Notable patterns, abstractions, or unconventional choices with reasoning if apparent -->
```

Be factual. Only document what exists in the code. Do not speculate or add aspirational content.
