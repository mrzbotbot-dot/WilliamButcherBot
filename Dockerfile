# ============= BASE STAGE =============
FROM python:3.9-slim-bullseye AS base

WORKDIR /wbb

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHON_VERSION=3.9.18

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl ca-certificates \
    git gcc build-essential \
    iputils-ping \
    libxml2-dev libxslt-dev zlib1g-dev libffi-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

ENV PATH="/root/.local/bin/:$PATH"

COPY pyproject.toml .
COPY uv.lock .

# ============= PRODUCTION STAGE =============
FROM base

ENV UV_NO_DEV=1
ENV UV_PYTHON=python3.9

RUN uv sync

COPY . .

ENTRYPOINT ["uv", "run", "python", "-m", "wbb"]
