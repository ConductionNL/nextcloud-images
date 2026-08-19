#!/usr/bin/env bash
# SPDX-License-Identifier: EUPL-1.2
# role: tool
#
# soap-image-version.sh — print the Nextcloud patch version the SOAP image is built on.
#
# The soap-client image has to be published under a tag that names the exact
# Nextcloud patch release it contains, otherwise a deployment has nothing to
# pin to. The single source of truth for that version is the `FROM` line in
# soap-client/Dockerfile. All three publishers (GitHub Actions, Forgejo
# Actions, build-and-push.sh) read it through this script, so they cannot
# drift apart.
#
# Exits non-zero when the base image is not pinned to a full
# major.minor.patch version. That is deliberate: without a patch number there
# is nothing to lock to, and a silent fallback would quietly re-introduce the
# floating `fpm-soap` tag this script exists to replace.
#
# Writes: read-only (prints the version to stdout)
# Idempotent: yes
# Requires: bash, sed; soap-client/Dockerfile relative to this script
#
# Usage:
#   ./soap-image-version.sh                                     # -> 32.0.6
#   docker build ./soap-client -t "img:$(./soap-image-version.sh)-fpm-soap"
#   DOCKERFILE=other/Dockerfile ./soap-image-version.sh          # read another Dockerfile

set -euo pipefail

readonly DOCKERFILE="${DOCKERFILE:-$(dirname "$0")/soap-client/Dockerfile}"

main() {
  if [[ ! -f "${DOCKERFILE}" ]]; then
    echo "error: Dockerfile not found: ${DOCKERFILE}" >&2
    exit 1
  fi

  local version
  version="$(sed -n \
    's|^FROM[[:space:]]\+.*nextcloud:\([0-9]\+\.[0-9]\+\.[0-9]\+\)-fpm.*|\1|p' \
    "${DOCKERFILE}" | head -1)"

  if [[ -z "${version}" ]]; then
    echo "error: no pinned nextcloud:<major>.<minor>.<patch>-fpm base in ${DOCKERFILE}" >&2
    echo "       the published tag must name a patch version; fix the FROM line" >&2
    exit 2
  fi

  echo "${version}"
}

main "$@"
