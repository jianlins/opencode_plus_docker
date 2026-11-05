FROM ghcr.io/anomalyco/opencode

USER root

# Pin this deliberately. Bump it in a pull request when you want to upgrade
# OpenHands, so image builds remain reproducible.
ARG OPENHANDS_AGENT_CANVAS_VERSION=1.35.0

RUN apk update \
    && apk add --no-cache \
        bash \
        curl \
        gcc \
        git \
        libffi-dev \
        make \
        musl-dev \
        nodejs \
        npm \
        openssl-dev \
        supervisor \
        zsh \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && export PATH="/root/.local/bin:$PATH" \
    && uv python install 3.14 \
    && npm install --global "@openhands/agent-canvas@${OPENHANDS_AGENT_CANVAS_VERSION}" \
    && agent-canvas --version \
    && uv cache clean \
    && npm cache clean --force \
    && rm -rf /root/.cache/uv /root/.cache/pip /tmp/* \
    && apk cache clean \
    && rm -rf /var/cache/apk/*

ENV PATH="/root/.local/bin:${PATH}"
ENV UV_LINK_MODE=copy
ENV HOME=/root
ENV PROJECTS_PATH=/projects

WORKDIR /projects

COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/start-services.sh /usr/local/bin/start-services

RUN chmod +x /usr/local/bin/start-services

# OpenCode and OpenHands Agent Canvas, respectively.
EXPOSE 4096 8000

# Override the OpenCode base image's default TUI entrypoint.
ENTRYPOINT ["/usr/local/bin/start-services"]
