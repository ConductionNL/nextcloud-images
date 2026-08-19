# Changelog

All notable changes to this repository are documented here.

## 2026-08-18

### Added
- `soap-image-version.sh` — prints the Nextcloud patch version the soap-client
  image is built on, read from the `FROM` line in `soap-client/Dockerfile`.
  Exits non-zero when that base is not pinned to a full `major.minor.patch`
  version, so a floating base cannot silently produce an unversioned image.
  All three publishers read the version through this one script.
- **Versioned tag for the soap-client image.** Every build now publishes
  `<version>-fpm-soap` (immutable) alongside `fpm-soap` (moving). Deployments
  pin the versioned tag; `fpm-soap` is kept only so existing references keep
  resolving and can be dropped once nothing uses it.

  Why: `fpm-soap` was the only tag, carried no version, and was overwritten on
  every build. Combined with `imagePullPolicy: IfNotPresent` that made the
  running Nextcloud version depend on when a node last pulled — not knowable
  from Git. Measured 2026-08-18: seven deployments across `rijswijk-accept`,
  `beek`, `sluis`, `bct` and `vaals` all ran 32.0.6, from two different builds
  in two different registries, none of it stated anywhere.

### Changed
- **ghcr.io is the primary registry again.** `.github/workflows/build.yml`
  publishes both images to `ghcr.io/conductionnl/nextcloud-images` and is the
  supported path. The 2026-06-01 note below said ghcr.io pushes were no longer
  possible because the GitHub org was flagged; that is no longer the case —
  the org has been pushing to ghcr.io again since at least 2026-07-17.
- `.forgejo/workflows/build.yml` is now documented as the **backup** path and
  publishes the same tag names, so a failover does not change what a
  deployment resolves to. Its registry stays Docker Hub (different
  credentials); switching it to ghcr.io needs a token change and was not done.
- `.github/workflows/build.yml`: `actions/checkout@v1` → `@v4`, and the
  soap-client job gained the `packages: write` permission it was missing.
- `build-and-push.sh`: defaults to ghcr.io, derives the registry host from
  `REGISTRY` instead of hardcoding `docker.io`, and accepts
  `REGISTRY_USERNAME` / `REGISTRY_TOKEN` (with `DOCKERHUB_*` still honoured as
  fallbacks). It publishes both soap tags, like CI.

### Added (CI)
- **The two status contexts the org ruleset requires.** `Main Branch Protection`
  requires `branch-protection / check-branch` and `quality / Quality Report`;
  neither existed here, so a PR into main sat at BLOCKED with zero checks.
  `.github/workflows/branch-protection.yml` is taken over from the fleet
  unchanged. The quality context is produced by a repo-local reusable workflow
  (`code-quality.yml` calling `quality-report.yml`) instead of the shared fleet
  pipeline.

  Why local: the shared `ConductionNL/.github` quality.yml is a Nextcloud
  PHP-app pipeline. This repo has no composer.json, package.json or
  appinfo/info.xml, so nearly every leg has no subject matter. Calling it with
  every leg disabled produced a green report about nothing, and here it did not
  start at all — run 32234870604, `startup_failure`, zero jobs, no log and no
  error banner. The local gate runs shellcheck on both scripts, hadolint on both
  Dockerfiles (`--failure-threshold error`), and asserts that
  `soap-image-version.sh` still resolves a patch version, which is the invariant
  this repo exists to hold.

  Note that `hotfix/*` is required as the branch prefix: the shared
  branch-protection check accepts only `beta -> main` or `hotfix/* -> main`.

### Not done
- `postgres16-ext` still has no version tag — same class of problem, left
  alone deliberately; this change is scoped to the soap-client image.
- Nothing was rebuilt or pushed. The versioned tag does not exist in any
  registry until the workflow runs.

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

### Added (later same day)
- `build-and-push.sh` — local build & push helper for both images. Reads
  credentials from `docker login` or `DOCKERHUB_USERNAME`/`DOCKERHUB_TOKEN`
  env vars (never from a committed file).

### Known issue
- Codeberg's **hosted** runners OOM (`signal: killed`) while pulling/building the
  nextcloud-fpm base under the `vfs` storage driver. Local build is the
  supported path until a self-hosted Forgejo runner is available; the Forgejo
  workflow stays in place for that runner.

### Notes
- The legacy `.github/workflows/build.yml` still references ghcr.io and will fail
  on a flagged account; left in place pending a decision to remove it.
- Two required Docker Hub secrets on Codeberg: `DOCKERHUB_USERNAME`,
  `DOCKERHUB_TOKEN` (access token, not password).
- Codeberg hosted-runner resource limits (10 min, 2GB temp storage, vfs driver)
  may be too tight for the pgvector compile / nextcloud-fpm base; a self-hosted
  Forgejo runner is the fallback.
