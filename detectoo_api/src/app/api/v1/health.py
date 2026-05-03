"""Liveness / readiness endpoints."""

import logging
from datetime import UTC, datetime
from typing import Annotated

from fastapi import APIRouter, Depends, status
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.config import settings
from ...core.db.database import async_get_db
from ...core.schemas import HealthCheck

router = APIRouter(tags=["health"])

LOGGER = logging.getLogger(__name__)
STATUS_HEALTHY = "healthy"
STATUS_UNHEALTHY = "unhealthy"


@router.get("/health", response_model=HealthCheck)
async def health() -> JSONResponse:
    """Liveness check — confirms the app process is up."""
    return JSONResponse(
        status_code=status.HTTP_200_OK,
        content={
            "status": STATUS_HEALTHY,
            "environment": settings.ENVIRONMENT.value,
            "version": settings.APP_VERSION,
            "timestamp": datetime.now(UTC).isoformat(timespec="seconds"),
        },
    )


@router.get("/ready")
async def ready(db: Annotated[AsyncSession, Depends(async_get_db)]) -> JSONResponse:
    """Readiness check — verifies the DB is reachable."""
    db_ok = True
    try:
        await db.execute(text("SELECT 1"))
    except Exception as exc:  # pragma: no cover
        LOGGER.exception("Database readiness check failed: %s", exc)
        db_ok = False

    overall = STATUS_HEALTHY if db_ok else STATUS_UNHEALTHY
    http_status = status.HTTP_200_OK if db_ok else status.HTTP_503_SERVICE_UNAVAILABLE

    return JSONResponse(
        status_code=http_status,
        content={
            "status": overall,
            "environment": settings.ENVIRONMENT.value,
            "version": settings.APP_VERSION,
            "database": STATUS_HEALTHY if db_ok else STATUS_UNHEALTHY,
            "timestamp": datetime.now(UTC).isoformat(timespec="seconds"),
        },
    )
