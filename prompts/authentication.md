# Prompt: Authentication & Authorization Documentation

You are documenting the authentication and authorization mechanisms in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies, language, framework detection

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Search for authentication-related code:
   - Auth middleware, decorators, guards
   - JWT token handling (generation, validation, refresh)
   - OAuth/OAuth2 flows
   - API key validation
   - Session management
   - Password hashing and verification
   - Role-based access control (RBAC)
   - Permission checks
3. Search for related configuration:
   - Secret keys, token expiry settings
   - Auth provider configurations
   - CORS settings
   - Rate limiting tied to auth

## Output

Write documentation to `docs/03-authentication.md`:

```markdown
# Authentication & Authorization

## Overview
<!-- What auth mechanism(s) does this system use? -->

## Authentication Flow
<!-- Step-by-step flow diagram (ASCII/mermaid) showing how a user/client authenticates -->

## Auth Mechanisms
<!-- For each mechanism found:
  - Type (JWT, API Key, OAuth, Session, etc.)
  - Implementation details
  - Token/session lifecycle (creation, validation, refresh, expiry)
  - Where credentials are stored/validated
-->

## Authorization / Access Control
<!-- How permissions are enforced:
  - Role definitions
  - Permission model
  - Middleware/decorator that enforces access
  - Resource-level permissions
-->

## Security Configuration
<!-- Environment variables, secrets management, token settings -->
<!-- DO NOT include actual secret values, only variable names and descriptions -->

## Protected Routes/Resources
<!-- Which endpoints or resources require auth, and what level -->

## Edge Cases & Security Considerations
<!-- Rate limiting, brute force protection, token revocation, etc. -->
```

If no authentication exists in the codebase, document that fact clearly and note if the system relies on external auth (API gateway, reverse proxy, etc.).
