# syntax=docker/dockerfile:1.7

# ---- builder: resolve & install deps with uv ----
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# Install dependencies first so they're cached independently of source changes
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

# Copy source and install the project itself into the venv
COPY src ./src
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev


# ---- runtime: slim image with just python + venv + source ----
FROM python:3.11-slim-bookworm

WORKDIR /app

COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/src /app/src

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app/src

EXPOSE 8000

# Run migrations and seed as separate processes, then exec uvicorn as PID 1.
CMD ["sh", "-c", "alembic upgrade head && python seed.py && exec uvicorn app.main:app --host 0.0.0.0 --port 8000"]
