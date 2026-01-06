# Best-practice: Bitnami-compatible Postgres image with extensions
# - Keeps Bitnami entrypoint + filesystem layout intact
# - Installs extensions as root during build
# - Runs as non-root (1001) at runtime

ARG PG_MAJOR=16
FROM bitnamilegacy/postgresql:${PG_MAJOR}

# Switch to root only for package installation
USER root

# Install required extension packages
# - postgresql-contrib provides: pg_trgm, uuid-ossp, btree_gin, btree_gist, etc.
# - postgresql-${PG_MAJOR}-pgvector provides: vector extension
RUN set -eux; \
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

# Back to Bitnami non-root runtime user
USER 1001
