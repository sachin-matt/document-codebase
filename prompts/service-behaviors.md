# Prompt: Service Behaviors Documentation

You are documenting the core business logic and service behaviors in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Identify service/business logic layers (not controllers/routes, not data access — the middle layer).
3. For each service class/module:
   - Read the full source code
   - Document each public method's purpose, inputs, outputs, and side effects
   - Identify business rules and validation logic
   - Note error handling patterns
   - Document any state machines, workflows, or multi-step processes
   - Identify event emission, message publishing, or async task dispatch

## Output

Write documentation to `docs/04-service-behaviors.md`:

```markdown
# Service Behaviors

## Overview
<!-- How is business logic organized? Service layer pattern? Domain-driven? -->

## Services

### [ServiceName]
- **File**: `path/to/service.py`
- **Responsibility**: What this service handles
- **Dependencies**: Other services, repositories, or external clients it uses

#### Methods

##### `method_name(params) -> return_type`
- **Purpose**: What it does
- **Business Rules**: Key validation or logic rules applied
- **Side Effects**: Events emitted, notifications sent, external calls made
- **Error Handling**: What exceptions are raised and when

<!-- Repeat for each service -->

## Business Rules Summary
<!-- Cross-cutting business rules that span multiple services -->

## Workflows / State Machines
<!-- Multi-step processes, their states, and transitions -->

## Event/Message Flows
<!-- What events are published, what subscribes to them -->
```

Focus on documenting BEHAVIOR, not just structure. A developer reading this should understand what the system DOES, not just what files exist.
