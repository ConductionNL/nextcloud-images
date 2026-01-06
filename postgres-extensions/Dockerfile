# Bitnami-compatible Postgres image with extensions
# - Keeps Bitnami entrypoint and /bitnami filesystem layout
# - Installs packages as root during build
# - Runs as non-root (1001) at runtime
#
# NOTE: Bitnami PostgreSQL uses /opt/bitnami/postgresql/ - extensions must be
# installed there, NOT in /usr/share/postgresql/ where apt packages install them.

ARG PG_MAJOR=16
FROM bitnamilegacy/postgresql:${PG_MAJOR}

# Docker ARG scope best practice: re-declare after FROM
ARG PG_MAJOR=16

USER root

# Install build dependencies, build pgvector, copy contrib extensions, then cleanup
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      git \
      ca-certificates \
      curl \
      gnupg \
    ; \
    \
    # Add PGDG repository for postgresql-server-dev and contrib packages
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      postgresql-server-dev-${PG_MAJOR} \
      postgresql-contrib \
    ; \
    \
    # Build and install pgvector into Bitnami's PostgreSQL location
    git clone --branch v0.8.0 --depth 1 https://github.com/pgvector/pgvector.git /tmp/pgvector; \
    cd /tmp/pgvector; \
    make PG_CONFIG=/opt/bitnami/postgresql/bin/pg_config; \
    make install PG_CONFIG=/opt/bitnami/postgresql/bin/pg_config; \
    rm -rf /tmp/pgvector; \
    \
    # Copy contrib extensions from apt location to Bitnami's location
    cp /usr/share/postgresql/${PG_MAJOR}/extension/pg_trgm* /opt/bitnami/postgresql/share/extension/; \
    cp /usr/share/postgresql/${PG_MAJOR}/extension/uuid-ossp* /opt/bitnami/postgresql/share/extension/; \
    cp /usr/share/postgresql/${PG_MAJOR}/extension/btree_gin* /opt/bitnami/postgresql/share/extension/; \
    cp /usr/share/postgresql/${PG_MAJOR}/extension/btree_gist* /opt/bitnami/postgresql/share/extension/; \
    cp /usr/lib/postgresql/${PG_MAJOR}/lib/pg_trgm.so /opt/bitnami/postgresql/lib/; \
    cp /usr/lib/postgresql/${PG_MAJOR}/lib/uuid-ossp.so /opt/bitnami/postgresql/lib/; \
    cp /usr/lib/postgresql/${PG_MAJOR}/lib/btree_gin.so /opt/bitnami/postgresql/lib/; \
    cp /usr/lib/postgresql/${PG_MAJOR}/lib/btree_gist.so /opt/bitnami/postgresql/lib/; \
    \
    # Fail fast: ensure all extension control files exist in Bitnami's location
    test -f /opt/bitnami/postgresql/share/extension/pg_trgm.control; \
    test -f /opt/bitnami/postgresql/share/extension/uuid-ossp.control; \
    test -f /opt/bitnami/postgresql/share/extension/btree_gin.control; \
    test -f /opt/bitnami/postgresql/share/extension/btree_gist.control; \
    test -f /opt/bitnami/postgresql/share/extension/vector.control; \
    \
    # Remove build dependencies to keep image small
    apt-get purge -y --auto-remove build-essential git postgresql-server-dev-${PG_MAJOR}; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

USER 1001
