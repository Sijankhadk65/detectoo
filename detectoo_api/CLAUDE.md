# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`detectoo_api` is a lean FastAPI backend scaffold for Detectoo. It carries the same auth flow and domain models as `detectoo_backend` (the heavier sibling project) but intentionally drops production-only modules so it is easier to develop against.

**Included:** JWT auth (access + refresh + token blacklist), User, Plant, Scan, RecoveryPlan/Step, Reminder, CareTask. FastCRUD, async SQLAlchemy 2.0, Alembic migrations, Postgres via Docker.

**Not included (intentional):** Redis, ARQ background workers, rate limiting, tiers, posts, CRUDAdmin, structured logging, NGINX/Gunicorn deployment configs.

## Commands

```bash
# Install dependencies (uses uv)
uv sync

# Bring up Postgres only (the API runs locally via uvicorn for fast dev iteration)
docker compose up -d db

# Run the API with hot-reload
uv run uvicorn src.app.main:app --reload

# Migrations
cd src && uv run alembic revision --autogenerate -m "<message>"
cd src && uv run alembic upgrade head
cd src && uv run alembic check

# Lint & format
uv run ruff check src/
uv run ruff format src/

# Type checking
uv run mypy src/
```

## Architecture

- **Entrypoint**: `src/app/main.py` — calls `create_application()` with the v1 router.
- **App factory**: `src/app/core/setup.py` — slim `create_application()` plus a `lifespan_factory` for startup/shutdown.
- **Configuration**: `src/app/core/config.py` — layered `pydantic-settings` classes composed into a single `Settings` class, reads from `src/.env`.
- **API routes**: `src/app/api/v1/` — versioned. Routers: `health`, `login`, `logout`, `users`, `plants`, `scans`, `recovery`, `reminders`, `care_tasks`. Each new router is imported and registered in `src/app/api/v1/__init__.py`.
- **Database**: PostgreSQL with async SQLAlchemy 2.0 + asyncpg. Models in `src/app/models/`, CRUD via FastCRUD in `src/app/crud/`.
- **Schemas**: Pydantic v2 in `src/app/schemas/`.
- **Auth**: JWT access + refresh tokens, token blacklist in `src/app/core/security.py` and `src/app/core/db/token_blacklist.py`.
- **Migrations**: Alembic is the single source of truth for schema. Config at `src/alembic.ini`, scripts in `src/migrations/versions/`. `env.py` walks both `app.models` and `app.core.db` so models in either location are picked up.

## Domain models

`detectoo_api` uses the same domain entities as `detectoo_backend`:

- **User** (`models/user.py`) — authenticated user. (No `tier_id` here — tiers are dropped.)
- **Plant** (`models/plant.py`) — a plant owned by a user.
- **Scan** (`models/scan.py`) — a recorded plant scan with detected issues stored inline as JSONB.
- **RecoveryPlan / RecoveryStep** (`models/recovery.py`) — a recovery plan and its steps.
- **Reminder** (`models/reminder.py`) — a plant-care reminder.
- **CareTask** (`models/care_task.py`) — a plant-care to-do item.

All user-owned resources enforce `created_by_user_id` ownership in the API layer and support soft deletion via `is_deleted` + `deleted_at`.

## Code conventions

- Always add docstrings to new functions and classes.
- Do not set `unique=True` or `nullable=False` on primary-key columns — both are implied by `primary_key=True`.
- When adding a new model: register it in `src/app/models/__init__.py`, add a router in `src/app/api/v1/`, register the router in `src/app/api/v1/__init__.py`, then run `alembic revision --autogenerate` + `alembic upgrade head`.
- Ruff: line length 120, target Python 3.11.
