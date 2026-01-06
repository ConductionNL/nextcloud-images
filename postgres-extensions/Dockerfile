# Bitnami-compatible Postgres image with extensions
# - Keeps Bitnami entrypoint and /bitnami filesystem layout
# - Installs packages as root during build
# - Runs as non-root (1001) at runtime

ARG PG_MAJOR=16
FROM bitnamilegacy/postgresql:${PG_MAJOR}

# Docker ARG scope best practice: re-declare after FROM
ARG PG_MAJOR=16

USER root

# Install prerequisites and add PGDG apt repository for pgvector
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
    ; \
    # Add PostgreSQL PGDG repository (contains pgvector)
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      postgresql-contrib \
      postgresql-${PG_MAJOR}-pgvector \
    ; \
    # Fail fast: ensure extension control files exist
    test -f /usr/share/postgresql/${PG_MAJOR}/extension/pg_trgm.control; \
    test -f /usr/share/postgresql/${PG_MAJOR}/extension/uuid-ossp.control; \
    test -f /usr/share/postgresql/${PG_MAJOR}/extension/btree_gin.control; \
    test -f /usr/share/postgresql/${PG_MAJOR}/extension/btree_gist.control; \
    test -f /usr/share/postgresql/${PG_MAJOR}/extension/vector.control; \
    # Cleanup to keep image small
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

USER 1001
