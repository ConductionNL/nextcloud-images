# nextcloud-images
This repository contains purpose built versions of the nextcloud community image. These images are for use at your own risk.

These images are temporary solutions until we can use an official Nextcloud image for our purposes.

## Images

| Path                    | Image tag                                              | What it adds                                              |
| ----------------------- | ------------------------------------------------------ | -------------------------------------------------------- |
| `soap-client/`          | `docker.io/conduction2022/nextcloud-images:fpm-soap`       | Nextcloud `fpm` with the PHP `xsl` and `soap` extensions |
| `postgres-extensions/`  | `docker.io/conduction2022/nextcloud-images:postgres16-ext` | Bitnami PostgreSQL 16 with `pgvector` built from source  |

## Building & publishing

**Supported path today: build locally and push.** Codeberg's *hosted* CI
runners OOM while building these images (the nextcloud-fpm base is too large
for the `vfs` storage driver under their RAM limit), so use the helper script:

```bash
# log in once (paste a Docker Hub access token as the password), then:
docker login -u conduction2022 docker.io
./build-and-push.sh                 # both images
./build-and-push.sh soap            # only the soap-client image
./build-and-push.sh postgres        # only the postgres-extensions image
```

Credentials are read from `docker login` (or `DOCKERHUB_USERNAME` /
`DOCKERHUB_TOKEN` env vars) — never store the token in a `.env` or commit it.

Or build the images by hand:

```bash
docker build ./soap-client          -t docker.io/conduction2022/nextcloud-images:fpm-soap
docker build ./postgres-extensions  -t docker.io/conduction2022/nextcloud-images:postgres16-ext
```

**CI (`.forgejo/workflows/build.yml`)** builds with `buildah` (Codeberg runners
have no Docker daemon) and pushes to Docker Hub using the `DOCKERHUB_USERNAME`
and `DOCKERHUB_TOKEN` repository secrets. It currently fails on Codeberg's
hosted runners due to the RAM/storage limits above; it is intended for a
**self-hosted Forgejo runner**, which has no such limits.
