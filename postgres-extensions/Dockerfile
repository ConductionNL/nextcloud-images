# Bitnami-compatible Postgres image with extensions
# - Keeps Bitnami entrypoint and /bitnami filesystem layout
# - Installs packages as root during build
# - Runs as non-root (1001) at runtime
#
# NOTE: Bitnami PostgreSQL uses /opt/bitnami/postgresql/ - extensions must be
# installed there, NOT in /usr/share/postgresql/ where apt packages install them.
# Contrib extensions (pg_trgm, uuid-ossp, btree_gin, btree_gist) are included in Bitnami.

ARG PG_MAJOR=16
FROM bitnamilegacy/postgresql:${PG_MAJOR}

# Docker ARG scope best practice: re-declare after FROM
ARG PG_MAJOR=16

USER root

# Build pgvector from source and install into Bitnami's PostgreSQL location
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      git \
      ca-certificates \
    ; \
    \
    # Build and install pgvector
    git clone --branch v0.8.0 --depth 1 https://github.com/pgvector/pgvector.git /tmp/pgvector; \
    cd /tmp/pgvector; \
    make PG_CONFIG=/opt/bitnami/postgresql/bin/pg_config; \
    make install PG_CONFIG=/opt/bitnami/postgresql/bin/pg_config; \
    rm -rf /tmp/pgvector; \
    \
    # Fail fast: ensure all extension control files exist in Bitnami's location
    # (contrib extensions should already be present in Bitnami image)
    test -f /opt/bitnami/postgresql/share/extension/pg_trgm.control; \
    test -f /opt/bitnami/postgresql/share/extension/uuid-ossp.control; \
    test -f /opt/bitnami/postgresql/share/extension/btree_gin.control; \
    test -f /opt/bitnami/postgresql/share/extension/btree_gist.control; \
    test -f /opt/bitnami/postgresql/share/extension/vector.control; \
    \
    # Remove build dependencies to keep image small
    apt-get purge -y --auto-remove build-essential git; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

USER 1001
