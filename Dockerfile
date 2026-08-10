FROM ghcr.io/anomalyco/opencode

USER root

RUN apk update \
    && apk add --no-cache \
        curl \
        gcc \
        git \
        make \
        zsh \
        bash \
        musl-dev \
        libffi-dev \
        openssl-dev \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && export PATH="/root/.local/bin:$PATH" \
    && uv python install 3.14 \
    && apk cache clean

ENV PATH="/root/.local/bin:${PATH}"
ENV UV_LINK_MODE=copy

WORKDIR /root
