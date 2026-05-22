# detectoo_api

Lean FastAPI backend for Detectoo. This is a **development scaffold** — it carries the same auth and domain models as `detectoo_backend` but drops the heavier production-only modules (Redis, ARQ workers, rate limiting, tiers, posts, CRUDAdmin, NGINX/Gunicorn). The structure mirrors `detectoo_backend` so features can be promoted into a production-grade variant later.

---

## Local development

The API runs as a host process via uvicorn (fast hot-reload). Only Postgres + Adminer run in Docker.

```bash
# 1. Install dependencies
uv sync

# 2. Copy env file and edit secrets (POSTGRES_PASSWORD, SECRET_KEY, ADMIN_*)
cp .env.example src/.env

# 3. Start Postgres + Adminer
docker compose up -d db adminer

# 4. Apply migrations
cd src && uv run alembic upgrade head && cd ..

# 5. Run the API with hot-reload
uv run uvicorn src.app.main:app --reload
```

| What | Where |
| --- | --- |
| API | `http://localhost:8000/api/v1` |
| OpenAPI docs | `http://localhost:8000/docs` |
| Adminer (DB UI) | `http://localhost:8081` (server `db`, user/pass from `src/.env`) |
| Postgres (host) | `localhost:5433` |

### Day-to-day

```bash
# Lint / format
uv run ruff check src/
uv run ruff format src/

# Type check
uv run mypy src/

# New migration after model changes
cd src && uv run alembic revision --autogenerate -m "<message>"
cd src && uv run alembic upgrade head

# Verify model/DB drift
cd src && uv run alembic check
```

### Stop / reset

```bash
docker compose down            # stop containers, keep DB volume
docker compose down -v         # stop + wipe Postgres volume (destroys all data)
```

---

## Server deployment

The API is containerized behind the `server` profile so the local-dev workflow above keeps working unchanged. On the server, everything runs in Docker (db, adminer, web).

### First-time setup

```bash
# 1. Clone and cd in
git clone <repo> && cd detectoo/detectoo_api

# 2. Create src/.env with PRODUCTION secrets
cp .env.example src/.env
# edit src/.env — set POSTGRES_PASSWORD, SECRET_KEY (long random), ADMIN_PASSWORD,
# ENVIRONMENT=production, CORS_ORIGINS, etc.

# 3. Open required ports on the cloud firewall AND the host
sudo ufw allow 8000/tcp        # API (or 80/443 once you put TLS in front)
sudo ufw deny 5433/tcp         # don't expose Postgres publicly
sudo ufw deny 8081/tcp         # don't expose Adminer publicly

# 4. Build + start db + web (server profile pulls in the API container)
docker compose --profile server up -d --build

# 5. Apply migrations once the web container is healthy
docker compose --profile server exec -w /app/src web alembic upgrade head
```

The API is now reachable at `http://<server-ip>:8000`.

### Deploy a new version

```bash
git pull
docker compose --profile server up -d --build
docker compose --profile server exec -w /app/src web alembic upgrade head
```

### Day-to-day

```bash
# Status
docker compose --profile server ps

# Logs
docker compose --profile server logs -f web
docker compose --profile server logs -f db

# Restart after a config change
docker compose --profile server restart web

# Shell into the web container
docker compose --profile server exec web sh

# Run a one-off alembic command
docker compose --profile server exec -w /app/src web alembic check
docker compose --profile server exec -w /app/src web alembic revision --autogenerate -m "<message>"

# Stop everything (keeps DB volume)
docker compose --profile server down

# Stop + wipe Postgres volume (DESTRUCTIVE — production data lost)
docker compose --profile server down -v
```

### HTTPS / domains

Plain `http://<ip>:8000` works for testing, but:

- Browsers / mobile OSes increasingly reject plain HTTP — iOS App Transport Security and Android cleartext-traffic blocking will prevent the Flutter app from talking to the API in production.
- Let's Encrypt won't issue certs for bare IPs, so HTTPS requires a domain.

To enable HTTPS, point a domain (e.g. `api.detectoo.com`) at the server via an A record, then put a reverse proxy (Caddy is the lowest-effort option — auto-renews Let's Encrypt certs) in front of `web` on ports 80/443. Once that's in place, remove the `8000:8000` host port mapping from the `web` service so uvicorn is only reachable via the proxy.

---

## Project layout

```
detectoo_api/
├─ Dockerfile              # multi-stage uv build (server profile)
├─ docker-compose.yml      # db + adminer (always); web (server profile only)
├─ .dockerignore
├─ .env.example            # template — copy to src/.env and fill in
├─ pyproject.toml
├─ uv.lock
└─ src/
   ├─ alembic.ini
   ├─ migrations/          # Alembic migration scripts
   └─ app/
      ├─ main.py           # FastAPI entrypoint
      ├─ core/             # config, security, db, exceptions
      ├─ models/           # SQLAlchemy models
      ├─ schemas/          # Pydantic schemas
      ├─ crud/             # FastCRUD instances
      └─ api/v1/           # versioned routers
```

---

## Troubleshooting

**`SSL_ERROR_RX_RECORD_TOO_LONG` in browser**
You hit `https://...:8000`. The server speaks plain HTTP on 8000. Use `http://` (or set up a reverse proxy with TLS — see HTTPS section).

**`alembic upgrade head` hangs or fails to connect**
Locally: confirm `docker compose ps` shows `db` healthy and `src/.env` has `POSTGRES_SERVER=localhost` + `POSTGRES_PORT=5433`.
On the server: alembic must run inside the `web` container, not on the host. The compose service overrides `POSTGRES_SERVER=db` and `POSTGRES_PORT=5432` automatically.

**Cannot reach API on server IP**
Check both layers: the cloud provider's firewall/security group AND `sudo ufw status`. Both must allow inbound `8000/tcp` (or 80/443 once TLS is fronted).
