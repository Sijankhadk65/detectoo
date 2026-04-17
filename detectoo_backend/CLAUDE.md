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

# Database migrations (run inside the web container; migrations/ and alembic.ini are mounted at /code)
docker compose exec -w /code web alembic revision --autogenerate -m "<message>"
docker compose exec -w /code web alembic upgrade head

# Verify no drift between models and DB
docker compose exec -w /code web alembic check

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
- **API routes**: `src/app/api/v1/` — versioned endpoints. Current routers: `health`, `login`, `logout`, `users`, `posts`, `plants`, `scans`, `recovery`, `reminders`, `care_tasks`, `tasks` (ARQ background jobs, unrelated to plant-care tasks), `tiers`, `rate_limits`. Each new router is imported and registered in `src/app/api/v1/__init__.py`
- **Database**: PostgreSQL with async SQLAlchemy 2.0 + asyncpg. Models in `src/app/models/`, CRUD operations via FastCRUD in `src/app/crud/`
- **Schemas**: Pydantic v2 models in `src/app/schemas/`
- **Auth**: JWT access + refresh tokens, token blacklist in `src/app/core/security.py` and `src/app/core/db/token_blacklist.py`
- **Background jobs**: ARQ workers (Redis-backed) configured in `src/app/core/worker/`
- **Caching & rate limiting**: Redis-backed, utilities in `src/app/core/utils/`
- **Admin panel**: CRUDAdmin mounted at `/admin`, configured in `src/app/admin/`. Every new model should be registered in `src/app/admin/views.py`
- **Migrations**: Alembic is the single source of truth for schema. Config at `src/alembic.ini`, migration scripts in `src/migrations/versions/`. `env.py` walks both `app.models` and `app.core.db` so models in either location are picked up. `create_tables_on_start` is disabled in `main.py` — schema changes must go through a migration
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

## Domain Models

Detectoo is a plant disease detection app. The core domain entities are:

- **User** (`models/user.py`) — authenticated user
- **Plant** (`models/plant.py`) — a plant owned by a user (name, health status, last_watered, icon)
- **Scan** (`models/scan.py`) — a recorded plant scan. Optionally linked to a Plant. Detected issues are stored inline as JSONB on the scan row (immutable per scan)
- **RecoveryPlan** / **RecoveryStep** (`models/recovery.py`) — a recovery plan for a diseased plant. `do_list` / `dont_list` / `signs_of_improvement` are JSONB. Steps live in a separate `recovery_step` table so individual steps can be toggled `completed`
- **Reminder** (`models/reminder.py`) — a plant-care reminder (title, time, icon_code_point). Optional `plant_id` FK
- **CareTask** (`models/care_task.py`) — a plant-care to-do item (title, done, due_date). Optional `plant_id` FK. Table `care_task` and URL prefix `/care-task(s)` — named to avoid collision with the ARQ `/tasks` router

All user-owned resources (plants, scans, recovery plans) enforce `created_by_user_id` ownership in the API layer and support soft deletion via `is_deleted` + `deleted_at`.

## Dependencies

Managed with `uv`. Runtime deps go in `[project].dependencies`; dev/test deps (pytest, faker, pytest-mock, types-redis, pre-commit, pytest-asyncio) go in `[dependency-groups].dev` in `pyproject.toml`. Do **not** use `[project.optional-dependencies]` — `uv sync` ignores it by default, and tools installed there will be missing from the Docker images.

## Key Conventions

- Always add docstrings to new functions and classes
- Do not set `unique=True` or `nullable=False` on primary-key columns — both are implied by `primary_key=True` and the redundancy causes false drift in `alembic check`
- When adding a new model: register it in `src/app/models/__init__.py`, add a router in `src/app/api/v1/`, register the router in `src/app/api/v1/__init__.py`, register the admin view in `src/app/admin/views.py`, then run `alembic revision --autogenerate` + `alembic upgrade head`
- Tests in `tests/` directory, run with pytest (uses pytest-asyncio)
