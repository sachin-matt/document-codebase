# Prompt: API Routes Documentation

You are documenting all API routes/endpoints in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies, language, framework detection

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Find all files that define API routes, endpoints, or URL patterns. Look for:
   - Framework-specific patterns: Flask (`@app.route`), FastAPI (`@app.get/post`), Express (`router.get`), Django (`urlpatterns`), Spring (`@RequestMapping`), Go (`http.HandleFunc`), etc.
   - GraphQL schema definitions
   - gRPC/protobuf service definitions
   - WebSocket handlers
3. For each endpoint, read the handler function to understand:
   - HTTP method and path
   - Request parameters (path, query, body, headers)
   - Authentication/authorization requirements
   - Request validation
   - Response format and status codes
   - Error responses

## Output

Write the documentation to `docs/02-api-routes.md` with this structure:

```markdown
# API Routes

## Overview
<!-- Summary: how many endpoints, what API style (REST, GraphQL, gRPC), base URL pattern -->

## Authentication
<!-- Brief note on what auth is required (details in separate auth doc) -->

## Endpoints

### [GROUP NAME] (e.g., Users, Products, Auth)

#### `METHOD /path/to/endpoint`
- **Description**: What this endpoint does
- **Auth**: Required/Optional/None
- **Parameters**:
  | Name | In | Type | Required | Description |
  |------|------|------|----------|-------------|
  | ... | path/query/body/header | ... | ... | ... |
- **Request Body** (if applicable):
  ```json
  { "example": "payload" }
  ```
- **Response** (`200`):
  ```json
  { "example": "response" }
  ```
- **Error Responses**: List status codes and when they occur
- **Source**: `path/to/file.py:line`

<!-- Repeat for each endpoint -->
```

## Important

- Include the source file and line number for each endpoint.
- Group endpoints logically by resource or feature.
- Document request/response schemas from actual code (Pydantic models, TypeScript interfaces, Go structs, etc.).
- If no API routes exist, document that fact and explain how the system is invoked instead (CLI, library, message queue, etc.).
