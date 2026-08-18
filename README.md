# nextcloud-images
This repository contains purpose built versions of the nextcloud community image. These images are for use at your own risk.

These images are temporary solutions until we can use an official Nextcloud image for our purposes.

## Images

The primary registry is **ghcr.io**.

| Path                    | Image tag                                                        | What it adds                                              |
| ----------------------- | ---------------------------------------------------------------- | -------------------------------------------------------- |
| `soap-client/`          | `ghcr.io/conductionnl/nextcloud-images:<version>-fpm-soap`        | Nextcloud `fpm` with the PHP `xsl` and `soap` extensions |
| `postgres-extensions/`  | `ghcr.io/conductionnl/nextcloud-images:postgres16-ext`            | Bitnami PostgreSQL 16 with `pgvector` built from source  |

### Pin the soap-client image to a version

Every build of the soap-client image publishes **two** tags:

| Tag                    | Mutable? | Use it for                                              |
| ---------------------- | -------- | ------------------------------------------------------- |
| `<version>-fpm-soap`   | no       | **everything** — this is what a deployment should pin to |
| `fpm-soap`             | yes      | migration only; it moves on every build                 |

`<version>` is the Nextcloud patch release the image contains, e.g.
`32.0.6-fpm-soap`. It is derived from the `FROM` line in
`soap-client/Dockerfile` by `./soap-image-version.sh`, which **fails the build**
if that base is not pinned to a full `major.minor.patch` version — without a
patch number there is nothing to lock to.

`fpm-soap` exists because deployments referenced it before versioned tags
existed. Combined with `imagePullPolicy: IfNotPresent` it means the running
Nextcloud version depends on when a node last pulled, which is not knowable
from Git. Move references to the versioned tag; the moving tag can be dropped
once nothing uses it.

## Building & publishing

**Primary: GitHub Actions (`.github/workflows/build.yml`).** Runs on every push
to `main`, builds both images and pushes them to ghcr.io using the built-in
`GITHUB_TOKEN`. No repository secrets needed.

**Backup: Forgejo Actions (`.forgejo/workflows/build.yml`).** For when GitHub
Actions is unavailable. Builds with `buildah` (Codeberg runners have no Docker
daemon) and pushes to Docker Hub using the `DOCKERHUB_USERNAME` and
`DOCKERHUB_TOKEN` repository secrets. Note that Codeberg's *hosted* runners OOM
on these images (the nextcloud-fpm base is too large for the `vfs` storage
driver under their RAM limit) — it is intended for a **self-hosted Forgejo
runner**, which has no such limits.

**Manual fallback: `./build-and-push.sh`.** Same tags as CI, for when neither
workflow can run:

```bash
docker login ghcr.io
./build-and-push.sh                 # both images
./build-and-push.sh soap            # only the soap-client image
./build-and-push.sh postgres        # only the postgres-extensions image

# push to the Docker Hub mirror instead
REGISTRY=docker.io/conduction2022/nextcloud-images ./build-and-push.sh
```

Credentials are read from `docker login` (or `REGISTRY_USERNAME` /
`REGISTRY_TOKEN` env vars; `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN` still work)
— never store the token in a `.env` or commit it.

Building by hand works too, but push **both** tags or the versioned one alone;
pushing only `fpm-soap` is what made the deployed version unknowable before:

```bash
V=$(./soap-image-version.sh)
docker build ./soap-client -t ghcr.io/conductionnl/nextcloud-images:$V-fpm-soap \
                           -t ghcr.io/conductionnl/nextcloud-images:fpm-soap
docker build ./postgres-extensions -t ghcr.io/conductionnl/nextcloud-images:postgres16-ext
```
