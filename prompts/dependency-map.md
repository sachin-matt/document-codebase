# Prompt: Dependency Map Documentation

You are documenting all dependencies (both external packages and internal module dependencies) in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Document external dependencies:
   - Read package manifests (requirements.txt, package.json, go.mod, Cargo.toml, pom.xml, etc.)
   - For each dependency: purpose, version, whether it's a core or dev dependency
   - Flag any known deprecated or outdated packages
3. Document internal module dependencies:
   - Read import statements across key files
   - Map which modules depend on which
   - Identify circular dependencies if any
   - Create a dependency graph

## Output

Write documentation to `docs/10-dependency-map.md`:

```markdown
# Dependency Map

## External Dependencies

### Production Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| ... | ... | ... |

### Development Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| ... | ... | ... |

## Internal Module Dependencies

### Dependency Graph
<!-- ASCII or Mermaid diagram showing how internal modules depend on each other -->

### Module Details
<!-- For each module: what it imports from other internal modules -->

## Dependency Analysis
<!-- Notable observations: tightly coupled modules, circular dependencies, heavy transitive dependencies -->
```
