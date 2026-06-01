#!/usr/bin/env bash
# SPDX-License-Identifier: EUPL-1.2
# role: tool
#
# build-and-push.sh — build the purpose-built Nextcloud images locally and push them to Docker Hub.
#
# Codeberg's hosted CI runners OOM while pulling/building these images (the
# nextcloud-fpm base is too large for the vfs storage driver under their RAM
# limit), so building locally with Docker is the supported path until a
# self-hosted Forgejo runner exists. This script wraps the build + push for
# both images so the steps are repeatable and auditable.
#
# Credentials are read from the environment (or an existing `docker login`);
# they are NEVER written to a file and NEVER echoed. Do not put the token in a
# .env — use `docker login` or pass DOCKERHUB_TOKEN inline for one invocation.
#
# Writes: pushes image tags to ${REGISTRY} on Docker Hub. No local files written.
# Idempotent: yes — rebuilding/pushing the same source produces the same tags.
# Requires: docker (or podman via DOCKER=podman); git (optional, for the sha tag);
#           push rights on the Docker Hub namespace.
#
# Usage:
#   docker login -u conduction2022 docker.io && ./build-and-push.sh            # all images, reuse existing login
#   DOCKERHUB_USERNAME=conduction2022 DOCKERHUB_TOKEN=*** ./build-and-push.sh   # log in from env, build+push all
#   ./build-and-push.sh soap                                                   # only the soap-client image
#   ./build-and-push.sh postgres                                               # only the postgres-extensions image
#   REGISTRY=docker.io/myorg/myimg ./build-and-push.sh                         # override the target namespace

set -euo pipefail

readonly REGISTRY="${REGISTRY:-docker.io/conduction2022/nextcloud-images}"
readonly REGISTRY_HOST="docker.io"
readonly DOCKER_BIN="${DOCKER:-docker}"

maybe_login() {
  if [[ -n "${DOCKERHUB_USERNAME:-}" && -n "${DOCKERHUB_TOKEN:-}" ]]; then
    echo "info: logging in to ${REGISTRY_HOST} as ${DOCKERHUB_USERNAME}" >&2
    printf '%s' "${DOCKERHUB_TOKEN}" \
      | "${DOCKER_BIN}" login -u "${DOCKERHUB_USERNAME}" --password-stdin "${REGISTRY_HOST}"
  else
    echo "info: DOCKERHUB_USERNAME/DOCKERHUB_TOKEN not set; assuming 'docker login' was already done" >&2
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
  local tag="${REGISTRY}:fpm-soap"
  echo "==> building ${tag}" >&2
  "${DOCKER_BIN}" build ./soap-client -t "${tag}"
  echo "==> pushing ${tag}" >&2
  "${DOCKER_BIN}" push "${tag}"
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
