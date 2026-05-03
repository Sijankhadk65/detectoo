# detectoo_api

Lean FastAPI backend for Detectoo. This is a **development scaffold** — it carries the same auth and domain models as `detectoo_backend` but drops the heavier production-only modules (Redis, ARQ workers, rate limiting, tiers, posts, CRUDAdmin, NGINX/Gunicorn). The structure mirrors `detectoo_backend` so features can be promoted into a production-grade variant later.

## Quick start

```bash
# 1. Install dependencies
uv sync

# 2. Copy env file
cp .env.example src/.env

# 3. Start Postgres in Docker
docker compose up -d db

# 4. Apply migrations
cd src && uv run alembic upgrade head && cd ..

# 5. Run the API with hot-reload
uv run uvicorn src.app.main:app --reload
```

API is available at `http://localhost:8000/api/v1`. OpenAPI docs at `http://localhost:8000/docs`.

## Layout

```
src/
  alembic.ini
  migrations/         # Alembic migrations
  app/
    main.py           # FastAPI entrypoint
    core/             # config, security, db, exceptions
    models/           # SQLAlchemy models
    schemas/          # Pydantic schemas
    crud/             # FastCRUD instances
    api/v1/           # versioned routers
```

## Common commands

```bash
# Lint / format
uv run ruff check src/
uv run ruff format src/

# Type check
uv run mypy src/

# New migration
cd src && uv run alembic revision --autogenerate -m "<message>"
cd src && uv run alembic upgrade head
```
