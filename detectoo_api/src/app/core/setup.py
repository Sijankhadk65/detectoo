"""FastAPI application factory + lifespan for `detectoo_api`."""

from collections.abc import AsyncGenerator, Callable
from contextlib import _AsyncGeneratorContextManager, asynccontextmanager
from typing import Any

import fastapi
from fastapi import APIRouter, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.docs import get_redoc_html, get_swagger_ui_html
from fastapi.openapi.utils import get_openapi

from ..models import *  # noqa: F401, F403  -- ensure models are imported for SQLAlchemy metadata
from .config import AppSettings, CORSSettings, EnvironmentOption, EnvironmentSettings, settings
from .db.database import Base
from .db.database import async_engine as engine


async def create_tables() -> None:
    """Create all tables defined on ``Base.metadata`` (used only in dev fast-boot)."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


def lifespan_factory(
    create_tables_on_start: bool = False,
) -> Callable[[FastAPI], _AsyncGeneratorContextManager[Any]]:
    """Create a lifespan context manager. Alembic is the source of truth for schema, so
    ``create_tables_on_start`` defaults to ``False``; set it to ``True`` only for ad-hoc dev.
    """

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
        if create_tables_on_start:
            await create_tables()
        yield

    return lifespan


def create_application(
    router: APIRouter,
    create_tables_on_start: bool = False,
    lifespan: Callable[[FastAPI], _AsyncGeneratorContextManager[Any]] | None = None,
    **kwargs: Any,
) -> FastAPI:
    """Build the FastAPI app: metadata, CORS, lifespan, the v1 router, and docs handling."""
    kwargs.update(
        {
            "title": settings.APP_NAME,
            "description": settings.APP_DESCRIPTION,
            "contact": {"name": settings.CONTACT_NAME, "email": settings.CONTACT_EMAIL},
            "license_info": {"name": settings.LICENSE_NAME},
        }
    )

    # In non-local environments hide the auto-generated docs endpoints (we still serve our own below).
    if isinstance(settings, EnvironmentSettings) and settings.ENVIRONMENT != EnvironmentOption.LOCAL:
        kwargs.update({"docs_url": None, "redoc_url": None, "openapi_url": None})

    if lifespan is None:
        lifespan = lifespan_factory(create_tables_on_start=create_tables_on_start)

    application = FastAPI(lifespan=lifespan, **kwargs)
    application.include_router(router)

    if isinstance(settings, CORSSettings):
        application.add_middleware(
            CORSMiddleware,
            allow_origins=settings.CORS_ORIGINS,
            allow_credentials=True,
            allow_methods=settings.CORS_METHODS,
            allow_headers=settings.CORS_HEADERS,
        )

    if isinstance(settings, EnvironmentSettings) and settings.ENVIRONMENT != EnvironmentOption.LOCAL:
        # In staging/production, surface docs at the same paths but route via a controlled router.
        docs_router = APIRouter()

        @docs_router.get("/docs", include_in_schema=False)
        async def get_swagger_documentation() -> fastapi.responses.HTMLResponse:
            return get_swagger_ui_html(openapi_url="/openapi.json", title="docs")

        @docs_router.get("/redoc", include_in_schema=False)
        async def get_redoc_documentation() -> fastapi.responses.HTMLResponse:
            return get_redoc_html(openapi_url="/openapi.json", title="docs")

        @docs_router.get("/openapi.json", include_in_schema=False)
        async def openapi() -> dict[str, Any]:
            return get_openapi(title=application.title, version=application.version, routes=application.routes)

        application.include_router(docs_router)

    # Silence unused import warning (the import is for SQLAlchemy metadata side-effects).
    _ = (AppSettings,)

    return application
