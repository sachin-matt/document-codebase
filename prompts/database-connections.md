# Prompt: Database & Data Storage Documentation

You are documenting all database connections, data models, and storage mechanisms in a codebase.

## Context

Pre-extracted context is available at:
- `__dc_context/file-tree.txt` — full file listing
- `__dc_context/metadata.json` — package info, dependencies

## Instructions

1. Read `__dc_context/file-tree.txt` and `__dc_context/metadata.json` first.
2. Identify all data storage mechanisms:
   - SQL databases (PostgreSQL, MySQL, SQLite, etc.)
   - NoSQL databases (MongoDB, Redis, DynamoDB, etc.)
   - File-based storage (local filesystem, S3, GCS, etc.)
   - In-memory caches (Redis, Memcached)
   - Message queues (RabbitMQ, Kafka, SQS)
   - Search engines (Elasticsearch, Solr)
3. For each storage mechanism:
   - Read connection/configuration code
   - Read data model/schema definitions
   - Read migration files if present
   - Read repository/DAO classes
   - Identify query patterns and optimization (indexes, caching)

## Output

Write documentation to `docs/05-database-connections.md`:

```markdown
# Database & Data Storage

## Overview
<!-- What storage systems does this project use and why? -->

## Connection Configuration
<!-- How connections are configured (env vars, config files) -->
<!-- DO NOT include actual credentials, only variable names -->

## Data Models / Schemas

### [ModelName]
- **Storage**: Which database/storage
- **Table/Collection**: Name
- **Fields**:
  | Field | Type | Constraints | Description |
  |-------|------|-------------|-------------|
  | ... | ... | ... | ... |
- **Relationships**: Foreign keys, references
- **Indexes**: What's indexed and why

<!-- Repeat for each model -->

## Migrations
<!-- Migration strategy, tools used, how to run them -->

## Repository / Data Access Layer
<!-- How data access is organized, patterns used (Repository, Active Record, etc.) -->

## Caching Strategy
<!-- What's cached, cache invalidation approach, TTLs -->

## Storage Interfaces
<!-- Abstract interfaces for storage (if any), making it swappable -->
```
