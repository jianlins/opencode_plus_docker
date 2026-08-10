# opencode_plus Docker Build Workflow

This repository contains the build configuration for `brokenjade/opencode_plus`, a Docker image based on [`ghcr.io/anomalyco/opencode`](https://github.com/anomalyco/opencode) with additional development tools preinstalled.

# OpenCode Plus


[English](https://github.com/jianlins/opencode_plus_docker/blob/main/README.md) | [简体中文](https://github.com/jianlins/opencode_plus_docker/blob/main/README.zh-CN.md)

OpenCode Plus is a Docker image based on OpenCode with the following development tools preinstalled:

- `zsh`
- `git`
- `curl`
- `uv`
- Python 3.14
- `UV_LINK_MODE=copy` configured by default

It is intended for running OpenCode with a local project directory mounted from your host machine. In that respect, it works similarly to a Docker sandbox.

## Requirements

Before starting, make sure you have:

- Docker installed and running
- A project directory to work with
- `OPENCODE_SERVER_USERNAME` and `OPENCODE_SERVER_PASSWORD` set in your terminal environment
- An active internet connection

> OpenCode may require internet access when starting or when performing tasks that use online services. Check your connection before launching it. In environments where required services are unreachable, including some network configurations in China, OpenCode may fail to start or work correctly.

## Start OpenCode

1. In a terminal, navigate to your project directory:

   ```bash
   cd /path/to/your/project
   ```

2. Choose a host port. In the example below, OpenCode is available on port `4086`. You can change this to any unused port.

3. Start the container:

   ```bash
   port=4086 && docker run -d \
     --name "$(basename "$PWD")" \
     -v "$(pwd):$(pwd)" \
     -p "${port}:4096" \
     -e OPENCODE_SERVER_USERNAME="$OPENCODE_SERVER_USERNAME" \
     -e OPENCODE_SERVER_PASSWORD="$OPENCODE_SERVER_PASSWORD" \
     brokenjade/opencode_plus \
     web --hostname 0.0.0.0 --port 4096
   ```

4. Open OpenCode in your browser:

   ```text
   http://localhost:4086
   ```

If you selected a different value for `port`, replace `4086` in the URL with the port you chose.

## Restart later

The container name is automatically set to the name of your current project directory.

After starting the container once, return to the same project directory and restart it with:

```bash
docker restart "$(basename "$PWD")"
```

Then open the same address in your browser:

```text
http://localhost:4086
```

## Open a terminal in the container

From the project directory, run:

```bash
docker exec -it "$(basename "$PWD")" zsh -c 'cd "'"$PWD"'"; source .venv/bin/activate; exec zsh'
```

This opens a `zsh` shell inside the container, changes to your mounted project directory, and activates the project’s `.venv` virtual environment.

To leave the container shell, run:

```bash
exit
```

## Why use this image?

Compared with a Docker sandbox, this image is designed to be more adaptable to a regular development workflow:

- Your current project directory is mounted directly into the container.
- You can open an interactive `zsh` terminal in the container at any time.
- Common development tools, including Python and `uv`, are already available.
- You can extend the image with your own Dockerfile or add project-specific tools.

A sandbox can be convenient for isolated, temporary tasks, but it may be less suitable when you need a reusable, customized environment. In addition, Docker Sandbox image servers may be inaccessible from China due to network restrictions.

## How the build works

The [workflow](.github/workflows/rebuild-opencode-plus.yml) is a GitHub Actions job that:

1. **Triggers** on a weekly schedule—Sunday at 02:00 UTC—and manually through **Run workflow** in the GitHub UI.
2. **Logs in to Docker Hub** using the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` repository secrets.
3. **Checks whether the base image has changed** by comparing the digest of `ghcr.io/anomalyco/opencode` with the recorded base-image digest label on the previously published `brokenjade/opencode_plus:latest` image.
4. **Builds and pushes** only when the base image has changed:
   - Platforms: `linux/amd64` and `linux/arm64`, using QEMU and Buildx
   - Tags: `:latest` and `:<run-number>`
   - Labels: source repository, commit SHA, and base-image digest
   - Registry cache: the `buildcache` tag, used for faster incremental rebuilds
5. **Skips** the rebuild and writes a log message when the base image is unchanged.

## Setup

To build and publish your own customized image with this workflow, add the following secrets to the GitHub repository:

| Secret | Value |
| ------ | ----- |
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | A Docker Hub access token, or your account password |

## Build locally

```bash
docker build -t brokenjade/opencode_plus:local .
```