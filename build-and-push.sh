#!/usr/bin/env bash
# SPDX-License-Identifier: EUPL-1.2
# role: tool
#
# build-and-push.sh — build the purpose-built Nextcloud images locally and push them to a registry.
#
# Manual fallback for when neither CI path can run. The primary publisher is
# .github/workflows/build.yml (ghcr.io); .forgejo/workflows/build.yml is the
# backup. This script wraps the same build + push so the steps stay repeatable
# and auditable, and so a hand-built image carries the same tags as a CI-built
# one.
#
# The soap-client image gets two tags: <version>-fpm-soap (immutable, names the
# Nextcloud patch release from soap-client/Dockerfile) and fpm-soap (moving,
# kept only so existing references keep resolving). Do not push the moving tag
# on its own — that is what made the deployed version unknowable before.
#
# Credentials are read from the environment (or an existing `docker login`);
# they are NEVER written to a file and NEVER echoed. Do not put the token in a
# .env — use `docker login` or pass the token inline for one invocation.
#
# Writes: pushes image tags to ${REGISTRY}. No local files written.
# Idempotent: yes — rebuilding/pushing the same source produces the same tags.
# Requires: docker (or podman via DOCKER=podman); git (optional, for the sha tag);
#           ./soap-image-version.sh; push rights on the target namespace.
#
# Usage:
#   docker login ghcr.io && ./build-and-push.sh                                 # all images, reuse existing login
#   REGISTRY_USERNAME=me REGISTRY_TOKEN=*** ./build-and-push.sh                 # log in from env, build+push all
#   ./build-and-push.sh soap                                                    # only the soap-client image
#   ./build-and-push.sh postgres                                                # only the postgres-extensions image
#   REGISTRY=docker.io/conduction2022/nextcloud-images ./build-and-push.sh      # push to the Docker Hub mirror instead
#
# DOCKERHUB_USERNAME / DOCKERHUB_TOKEN are still honoured as fallbacks for
# REGISTRY_USERNAME / REGISTRY_TOKEN, so existing invocations keep working.

set -euo pipefail

readonly REGISTRY="${REGISTRY:-ghcr.io/conductionnl/nextcloud-images}"
readonly REGISTRY_HOST="${REGISTRY%%/*}"
readonly DOCKER_BIN="${DOCKER:-docker}"
VERSION_SCRIPT="$(dirname "$0")/soap-image-version.sh"
readonly VERSION_SCRIPT

maybe_login() {
  local username="${REGISTRY_USERNAME:-${DOCKERHUB_USERNAME:-}}"
  local token="${REGISTRY_TOKEN:-${DOCKERHUB_TOKEN:-}}"

  if [[ -n "${username}" && -n "${token}" ]]; then
    echo "info: logging in to ${REGISTRY_HOST} as ${username}" >&2
    printf '%s' "${token}" \
      | "${DOCKER_BIN}" login -u "${username}" --password-stdin "${REGISTRY_HOST}"
  else
    echo "info: REGISTRY_USERNAME/REGISTRY_TOKEN not set; assuming 'docker login ${REGISTRY_HOST}' was already done" >&2
  fi
}

git_sha() {
  if git rev-parse --short HEAD >/dev/null 2>&1; then
    git rev-parse --short HEAD
  else
    echo "unknown"
  fi
}

build_soap() {
  local version version_tag moving_tag
  version="$("${VERSION_SCRIPT}")"
  version_tag="${REGISTRY}:${version}-fpm-soap"
  moving_tag="${REGISTRY}:fpm-soap"

  echo "==> building ${version_tag} (+ ${moving_tag})" >&2
  "${DOCKER_BIN}" build ./soap-client -t "${version_tag}" -t "${moving_tag}"
  echo "==> pushing ${version_tag} and ${moving_tag}" >&2
  "${DOCKER_BIN}" push "${version_tag}"
  "${DOCKER_BIN}" push "${moving_tag}"
}

build_postgres() {
  local tag="${REGISTRY}:postgres16-ext"
  local sha_tag
  sha_tag="${REGISTRY}:postgres16-ext-sha-$(git_sha)"
  echo "==> building ${tag} (+ ${sha_tag})" >&2
  "${DOCKER_BIN}" build ./postgres-extensions -t "${tag}" -t "${sha_tag}"
  echo "==> pushing ${tag} and ${sha_tag}" >&2
  "${DOCKER_BIN}" push "${tag}"
  "${DOCKER_BIN}" push "${sha_tag}"
}

main() {
  local target="${1:-all}"

  if ! command -v "${DOCKER_BIN}" >/dev/null 2>&1; then
    echo "error: '${DOCKER_BIN}' not found on PATH" >&2
    exit 1
  fi

  if [[ ! -x "${VERSION_SCRIPT}" ]]; then
    echo "error: '${VERSION_SCRIPT}' missing or not executable" >&2
    exit 1
  fi

  maybe_login

  case "${target}" in
    soap)     build_soap ;;
    postgres) build_postgres ;;
    all)      build_soap; build_postgres ;;
    *)
      echo "error: unknown target '${target}' (expected: soap | postgres | all)" >&2
      exit 2
      ;;
  esac

  echo "==> done" >&2
}

main "$@"
