# Prompt: Edge Cases & Error Handling Documentation

You are documenting edge cases, error handling patterns, and defensive coding in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Search the codebase systematically for:
   - Custom exception/error classes
   - Try/catch blocks and error handling patterns
   - Input validation logic (boundary checks, type checks, sanitization)
   - Retry logic, circuit breakers, fallback mechanisms
   - Timeout handling
   - Race condition guards (locks, mutexes, semaphores)
   - Null/undefined checks and defensive patterns
   - Graceful degradation patterns
   - Error response formatting (error codes, messages)
3. Identify areas where edge cases are NOT handled (potential risks).

## Output

Write documentation to `docs/06-edge-cases.md`:

```markdown
# Edge Cases & Error Handling

## Error Handling Strategy
<!-- Overall approach: custom exceptions, error middleware, error codes -->

## Custom Exceptions / Error Types
<!-- List all custom error/exception classes, their hierarchy, and when each is used -->

## Input Validation
<!-- How inputs are validated, where, and what happens on invalid input -->

## Retry & Resilience Patterns
<!-- Retry logic, circuit breakers, exponential backoff, fallbacks -->

## Timeout Handling
<!-- Where timeouts are configured, what happens on timeout -->

## Concurrency & Race Conditions
<!-- Locking mechanisms, thread safety patterns, atomic operations -->

## Known Edge Cases
<!-- Document specific edge cases the code explicitly handles -->

## Potential Risk Areas
<!-- Areas where edge cases may NOT be handled — document cautiously as observations -->

## Error Response Format
<!-- Standard error response structure returned to clients -->
```

Be observational and factual. When identifying risk areas, phrase them as observations, not criticisms.
