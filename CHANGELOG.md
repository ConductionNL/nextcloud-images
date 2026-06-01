# Changelog

All notable changes to this repository are documented here.

## 2026-06-01

### Changed
- **Registry migration off GitHub Container Registry (ghcr.io).** The GitHub
  org was flagged, so ghcr.io pushes are no longer possible. Image builds now
  target **Docker Hub** (`docker.io/conduction2022/nextcloud-images`).
- **CI moved to Forgejo Actions (Codeberg).** Added
  `.forgejo/workflows/build.yml`, which builds both images with `buildah`
  (`--storage-driver=vfs --isolation=chroot`) because Codeberg's hosted runners
  have no Docker daemon. Builds run on the `codeberg-medium` runner.

### Added
- Repository mirrored/migrated to `https://codeberg.org/Conduction/nextcloud-images`.

### Notes
- The legacy `.github/workflows/build.yml` still references ghcr.io and will fail
  on a flagged account; left in place pending a decision to remove it.
- Two required Docker Hub secrets on Codeberg: `DOCKERHUB_USERNAME`,
  `DOCKERHUB_TOKEN` (access token, not password).
- Codeberg hosted-runner resource limits (10 min, 2GB temp storage, vfs driver)
  may be too tight for the pgvector compile / nextcloud-fpm base; a self-hosted
  Forgejo runner is the fallback.
