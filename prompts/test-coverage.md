# Prompt: Test Coverage Documentation

You are documenting the testing strategy, test cases, and coverage in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Find all test files and test directories.
3. Identify the testing framework(s) used (pytest, jest, JUnit, Go test, etc.).
4. Categorize tests:
   - Unit tests
   - Integration tests
   - End-to-end tests
   - Performance/load tests
   - Contract tests
5. For each test file:
   - Read it to understand what's being tested
   - Document the test cases and what scenarios they cover
   - Note use of mocks, fixtures, factories
6. Identify testing utilities, helpers, and shared fixtures.
7. Look for test configuration (conftest.py, jest.config.js, etc.).

## Output

Write documentation to `docs/08-test-coverage.md`:

```markdown
# Test Coverage

## Testing Strategy
<!-- Overall approach: what's tested, what framework(s), test pyramid -->

## Test Structure
<!-- Directory layout, naming conventions, how tests map to source code -->

## Test Configuration
<!-- Config files, environment setup for tests, test databases -->

## Test Categories

### Unit Tests
<!-- List test files, what they test, key scenarios covered -->

### Integration Tests
<!-- List test files, what they test, what systems they integrate -->

### E2E Tests
<!-- List test files, user flows covered -->

## Test Utilities
<!-- Shared fixtures, factories, mocks, helpers -->

## Running Tests
<!-- Commands to run tests, options, environment requirements -->

## Coverage Gaps
<!-- Areas of the codebase that appear to lack test coverage -->
```

When noting coverage gaps, be observational: "The X module does not appear to have associated tests" rather than "X is untested and needs tests."
