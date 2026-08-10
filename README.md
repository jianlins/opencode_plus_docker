# opencode_plus Docker Build Workflow

This repository contains the build configuration for `brokenjade/opencode_plus`, a Docker image based on [`ghcr.io/anomalyco/opencode`](https://github.com/anomalyco/opencode) with additional development tools preinstalled.

## What's included

On top of the base `opencode` image, the [Dockerfile](Dockerfile) adds:

- `curl`, `git`, `make`, `zsh`, `bash`
- `gcc`, `musl-dev`, `libffi-dev`, `openssl-dev` (build toolchain for Python packages)
- [uv](https://astral.sh/uv/) Python package manager (`/root/.local/bin`)
- Python 3.14 (installed via uv)
- `UV_LINK_MODE=copy` set as the default

## How the build works

The [workflow](.github/workflows/rebuild-opencode-plus.yml) is a GitHub Actions job that:

1. **Triggers** on a weekly schedule (Sundays at 02:00) and manually via **Run workflow** in the GitHub UI.
2. **Logs in to Docker Hub** using the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` repository secrets.
3. **Checks whether the base image changed** by comparing the digest of `ghcr.io/anomalyco/opencode` against the recorded base digest label on the previously published `brokenjade/opencode_plus:latest` image.
4. **Builds and pushes** only when the base image has changed:
   - Platforms: `linux/amd64` and `linux/arm64` (via QEMU + Buildx)
   - Tags: `:latest` and `:<run-number>`
   - Labels: source repo, commit SHA, and base image digest
   - Registry cache under the `buildcache` tag for fast incremental rebuilds
5. **Skips** the rebuild with a log message if the base image is unchanged.

## Setup

Add the following secrets to the GitHub repository:

| Secret | Value |
| ------ | ----- |
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token (or account password) |

## Building locally

```bash
docker build -t brokenjade/opencode_plus:local .
```

## Running the container

See [scripts/docker_opencode.md](scripts/docker_opencode.md) for first-run, restart, exec, and JupyterLab instructions.
