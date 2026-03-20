# Prompt: CI/CD Pipelines Documentation

You are documenting the CI/CD (Continuous Integration / Continuous Deployment) pipelines in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Look for CI/CD configuration files:
   - `.github/workflows/*.yml` (GitHub Actions)
   - `.gitlab-ci.yml` (GitLab CI)
   - `Jenkinsfile` (Jenkins)
   - `.circleci/config.yml` (CircleCI)
   - `bitbucket-pipelines.yml` (Bitbucket)
   - `.travis.yml` (Travis CI)
   - `cloudbuild.yaml` (Google Cloud Build)
   - `azure-pipelines.yml` (Azure DevOps)
   - `Dockerfile`, `docker-compose.yml` (containerization)
   - `Makefile`, `Taskfile.yml`, `justfile` (task runners)
   - Deployment scripts in `scripts/`, `deploy/`, `infra/`
3. For each pipeline/workflow, read the full configuration and document:
   - Triggers (push, PR, schedule, manual)
   - Steps/stages
   - Environment and secrets required
   - Deployment targets

## Output

Write documentation to `docs/09-cicd-pipelines.md`:

```markdown
# CI/CD Pipelines

## Overview
<!-- What CI/CD system(s) are used, overall deployment strategy -->

## Pipelines

### [Pipeline Name]
- **File**: `path/to/config`
- **Trigger**: What causes this pipeline to run
- **Stages**:
  1. Stage name — what it does
  2. ...
- **Environment/Secrets Required**: List of secrets/env vars needed
- **Artifacts**: What's produced (Docker images, packages, etc.)
- **Deploy Target**: Where it deploys to

<!-- Repeat for each pipeline -->

## Containerization
<!-- Dockerfile analysis, base images, build stages, exposed ports -->

## Infrastructure as Code
<!-- Terraform, CloudFormation, Pulumi, Helm charts if present -->

## Deployment Strategy
<!-- Blue-green, rolling, canary, etc. -->

## Local Development
<!-- docker-compose setup, Makefile targets, how to run locally -->

## Release Process
<!-- How releases are tagged, versioned, and deployed -->
```

If no CI/CD configuration exists, document that fact and note any deployment scripts or manual processes found.
