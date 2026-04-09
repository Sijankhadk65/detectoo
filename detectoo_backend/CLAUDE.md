# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies (uses uv package manager)
uv sync

# Run locally with hot-reload (requires Postgres + Redis running)
uv run uvicorn src.app.main:app --reload

# Run via Docker (starts app, Postgres, Redis, ARQ worker)
docker compose up

# Create first admin user
docker compose run --rm create_superuser

# Database migrations
cd src && uv run alembic revision --autogenerate && uv run alembic upgrade head

# Run tests (via Docker — tests depend on db + redis)
docker compose run --rm pytest

# Lint & format
uv run ruff check src/
uv run ruff format src/

# Type checking
uv run mypy src/
```

## Architecture

- **Entrypoint**: `src/app/main.py` — creates the FastAPI app with admin panel mounting
- **App factory**: `src/app/core/setup.py` — `create_application()` with lifespan management
- **Configuration**: `src/app/core/config.py` — layered `pydantic-settings` classes composing into a single `Settings` class, reads from `src/.env`
- **API routes**: `src/app/api/v1/` — versioned endpoints (users, posts, login/logout, tasks, tiers, rate_limits, health)
- **Database**: PostgreSQL with async SQLAlchemy 2.0 + asyncpg. Models in `src/app/models/`, CRUD operations via FastCRUD in `src/app/crud/`
- **Schemas**: Pydantic v2 models in `src/app/schemas/`
- **Auth**: JWT access + refresh tokens, token blacklist in `src/app/core/security.py` and `src/app/core/db/token_blacklist.py`
- **Background jobs**: ARQ workers (Redis-backed) configured in `src/app/core/worker/`
- **Caching & rate limiting**: Redis-backed, utilities in `src/app/core/utils/`
- **Admin panel**: CRUDAdmin mounted at `/admin`, configured in `src/app/admin/`
- **Migrations**: Alembic, config at `src/alembic.ini`, migration scripts in `src/migrations/`
- **Middleware**: Client cache headers and structured logging in `src/app/middleware/`

## Deployment Configurations

`setup.py` at project root copies the correct Dockerfile + docker-compose + .env for each environment:
- `./setup.py local` — Uvicorn with auto-reload
- `./setup.py staging` — Gunicorn managing Uvicorn workers
- `./setup.py production` — NGINX reverse proxy + Gunicorn/Uvicorn

## Code Formatting

- **Formatter/Linter**: Ruff — line length 120, target Python 3.11
- Run `uv run ruff check src/ --fix` to lint and auto-fix
- Run `uv run ruff format src/` to format
- **Type checking**: mypy — strict on `src.app.*` (disallow_untyped_defs), `ignore_missing_imports = true`

## Key Conventions

- Always add docstrings to new functions and classes
- Tests in `tests/` directory, run with pytest (uses pytest-asyncio)
