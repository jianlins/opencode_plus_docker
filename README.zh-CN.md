# opencode_plus Docker 构建工作流

本仓库包含 [`brokenjade/opencode_plus`](https://hub.docker.com/r/brokenjade/opencode_plus) 的构建配置。这是一个基于 [`ghcr.io/anomalyco/opencode`](https://github.com/anomalyco/opencode) 的 Docker 镜像，并预装了额外的开发工具。

# OpenCode Plus

[English](README.md) | [简体中文](README.zh-CN.md)

OpenCode Plus 是一个基于 OpenCode 的 Docker 镜像，预装了以下开发工具：

- `zsh`
- `git`
- `curl`
- `uv`
- Python 3.14
- 默认设置 `UV_LINK_MODE=copy`

该镜像用于运行 OpenCode，并将本地项目目录挂载到容器中。就这一点而言，它的使用方式与 Docker Sandbox 类似。

## 使用要求

开始前，请确认你已具备：

- 已安装并正在运行的 Docker
- 一个需要处理的项目目录
- 已在终端环境中设置 `OPENCODE_SERVER_USERNAME` 和 `OPENCODE_SERVER_PASSWORD`
- 可用的互联网连接

> OpenCode 在启动时，或执行需要在线服务的任务时，可能需要访问互联网。启动前请检查网络连接。在某些无法访问所需服务的网络环境中，包括中国境内的部分网络配置，OpenCode 可能无法正常启动或工作。

## 启动 OpenCode

1. 在终端中进入你的项目目录：

   ```bash
   cd /path/to/your/project
   ```

2. 选择一个主机端口。以下示例使用 `4086`，你可以改为任意未被占用的端口。

3. 启动容器：

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

4. 在浏览器中打开 OpenCode：

   ```text
   http://localhost:4086
   ```

如果你设置了不同的 `port` 值，请将网址中的 `4086` 替换为你选择的端口。

## 后续重启

容器名称会自动使用当前项目目录的名称。

首次启动容器后，之后只需回到同一个项目目录，并运行：

```bash
docker restart "$(basename "$PWD")"
```

然后再次在浏览器中打开：

```text
http://localhost:4086
```

## 进入容器终端

在项目目录中运行：

```bash
docker exec -it "$(basename "$PWD")" zsh -c 'cd "'"$PWD"'"; source .venv/bin/activate; exec zsh'
```

该命令会在容器中打开一个 `zsh` 终端，进入已挂载的项目目录，并激活项目的 `.venv` Python 虚拟环境。

退出容器终端时，运行：

```bash
exit
```

## 为什么使用此镜像？

与 Docker Sandbox 相比，此镜像更适合可持续使用的日常开发工作流：

- 当前项目目录会直接挂载到容器中。
- 你可以随时进入容器并使用交互式 `zsh` 终端。
- Python、`uv` 等常用开发工具已经预装。
- 你可以通过自己的 Dockerfile 扩展镜像，或添加项目专用工具。

Sandbox 对隔离的临时任务很方便，但在需要可重复使用、可定制的开发环境时，灵活性可能较低。此外，由于网络限制，Docker Sandbox 的镜像服务器可能无法从中国访问。

## 构建工作流

[工作流文件](.github/workflows/rebuild-opencode-plus.yml) 是一个 GitHub Actions 任务，其工作方式如下：

1. **触发方式**：每周日 02:00 UTC 自动运行，也可以在 GitHub 页面中通过 **Run workflow** 手动运行。
2. **登录 Docker Hub**：使用仓库 Secrets 中的 `DOCKERHUB_USERNAME` 和 `DOCKERHUB_TOKEN`。
3. **检查基础镜像是否更新**：比较 `ghcr.io/anomalyco/opencode` 的镜像摘要（digest），与已发布的 `brokenjade/opencode_plus:latest` 镜像中记录的基础镜像摘要。
4. **仅在基础镜像变更时构建并推送**：
   - 平台：`linux/amd64` 和 `linux/arm64`，通过 QEMU 和 Buildx 构建
   - 标签：`:latest` 和 `:<run-number>`
   - 标签元数据：源代码仓库、提交 SHA 和基础镜像摘要
   - 使用 `buildcache` Registry 缓存标签，加快后续增量构建
5. **基础镜像未变化时跳过构建**，并输出日志信息。

## 配置

如需构建并发布你自己的定制镜像，请在 GitHub 仓库中添加以下 Secrets：

| Secret | 值 |
| ------ | ----- |
| `DOCKERHUB_USERNAME` | 你的 Docker Hub 用户名 |
| `DOCKERHUB_TOKEN` | Docker Hub 访问令牌或账户密码 |

## 本地构建

```bash
docker build -t brokenjade/opencode_plus:local .
```
