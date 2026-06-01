# nextcloud-images
This repository contains purpose built versions of the nextcloud community image. These images are for use at your own risk.

These images are temporary solutions until we can use an official Nextcloud image for our purposes.

## Images

| Path                    | Image tag                                              | What it adds                                              |
| ----------------------- | ------------------------------------------------------ | -------------------------------------------------------- |
| `soap-client/`          | `docker.io/conduction/nextcloud-images:fpm-soap`       | Nextcloud `fpm` with the PHP `xsl` and `soap` extensions |
| `postgres-extensions/`  | `docker.io/conduction/nextcloud-images:postgres16-ext` | Bitnami PostgreSQL 16 with `pgvector` built from source  |

## Building & publishing

Images are built by CI on [Codeberg](https://codeberg.org/Conduction/nextcloud-images)
via Forgejo Actions (`.forgejo/workflows/build.yml`) and pushed to Docker Hub.
Codeberg's runners have no Docker daemon, so builds use `buildah`. Pushing
requires the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` repository secrets.

To build locally with Docker:

```bash
docker build ./soap-client          -t docker.io/conduction/nextcloud-images:fpm-soap
docker build ./postgres-extensions  -t docker.io/conduction/nextcloud-images:postgres16-ext
```
