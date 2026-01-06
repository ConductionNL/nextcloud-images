#!/bin/bash
set -euo pipefail

# Bitnami env vars (preferred):
DB="${POSTGRESQL_DATABASE:-${POSTGRES_DB:-postgres}}"
USER="${POSTGRESQL_USERNAME:-${POSTGRES_USER:-postgres}}"

echo "Enabling PostgreSQL extensions on database: ${DB} (user: ${USER})"

psql -v ON_ERROR_STOP=1 -U "${USER}" -d "${DB}" <<'SQL'
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE EXTENSION IF NOT EXISTS vector;
SQL

echo "Done."
