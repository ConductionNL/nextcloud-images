# Postgres Extensions Image (Bitnami-compatible)

This folder builds a Bitnami-compatible PostgreSQL 16 image with extensions available:

- pg_trgm
- uuid-ossp
- btree_gin
- btree_gist
- pgvector (extension name: `vector`)
- plpgsql (default)

## Why a custom image?
The Bitnami PostgreSQL Helm chart expects Bitnami filesystem layout and entrypoint conventions (`/bitnami/postgresql`).
Using non-Bitnami images (e.g. official postgres, pgvector/pgvector) can break the chart.

## Published image tags
The GitHub workflow publishes:
- `ghcr.io/conductionnl/nextcloud-images:postgres16-ext` (stable tag)
- `ghcr.io/conductionnl/nextcloud-images:postgres16-ext-sha-<sha>` (immutable build tag)

## Helm usage (new environments)
Use this image as override in the Nextcloud chart Postgres subchart:

```yaml
postgresql:
  enabled: true
  image:
    registry: ghcr.io
    repository: conductionnl/nextcloud-images
    tag: postgres16-ext
  primary:
    initdb:
      scripts:
        01-init-extensions.sh: |
          #!/bin/bash
          set -euo pipefail
          DB="${POSTGRESQL_DATABASE:-${POSTGRES_DB:-postgres}}"
          USER="${POSTGRESQL_USERNAME:-${POSTGRES_USER:-postgres}}"
          psql -v ON_ERROR_STOP=1 -U "${USER}" -d "${DB}" <<'SQL'
          CREATE EXTENSION IF NOT EXISTS pg_trgm;
          CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
          CREATE EXTENSION IF NOT EXISTS btree_gin;
          CREATE EXTENSION IF NOT EXISTS btree_gist;
          CREATE EXTENSION IF NOT EXISTS vector;
          SQL
