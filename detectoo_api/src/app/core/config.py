"""Application settings, layered with `pydantic-settings`.

Settings are read from environment variables and from `src/.env` if present.
"""

import os
from enum import StrEnum

from pydantic import SecretStr, computed_field
from pydantic_settings import BaseSettings, SettingsConfigDict


class AppSettings(BaseSettings):
    """Basic FastAPI metadata."""

    APP_NAME: str = "Detectoo API"
    APP_DESCRIPTION: str | None = None
    APP_VERSION: str | None = "0.1.0"
    LICENSE_NAME: str | None = None
    CONTACT_NAME: str | None = None
    CONTACT_EMAIL: str | None = None


class CryptSettings(BaseSettings):
    """JWT signing / expiry config."""

    SECRET_KEY: SecretStr = SecretStr("change-me")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7


class PostgresSettings(BaseSettings):
    """Postgres connection settings."""

    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "detectoo"
    POSTGRES_SYNC_PREFIX: str = "postgresql://"
    POSTGRES_ASYNC_PREFIX: str = "postgresql+asyncpg://"

    @computed_field  # type: ignore[prop-decorator]
    @property
    def POSTGRES_URI(self) -> str:
        """Bare credentials@host:port/db (no driver prefix)."""
        credentials = f"{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
        location = f"{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        return f"{credentials}@{location}"


class FirstUserSettings(BaseSettings):
    """First (admin) user bootstrapped via the seed script."""

    ADMIN_NAME: str = "admin"
    ADMIN_EMAIL: str = "admin@example.com"
    ADMIN_USERNAME: str = "admin"
    ADMIN_PASSWORD: str = "Str1ngst!"


class TestUserSettings(BaseSettings):
    """Test user bootstrapped via the seed script."""

    TEST_USER_NAME: str = "Test User"
    TEST_USER_EMAIL: str = "test@example.com"
    TEST_USER_USERNAME: str = "testuser"
    TEST_USER_PASSWORD: str = "Test1234!"


class StorageSettings(BaseSettings):
    """File storage settings."""

    SERVER_URL: str = "http://localhost:8000"
    UPLOADS_DIR: str = "/app/uploads"


class AISettings(BaseSettings):
    """AI / LLM service settings."""

    ANTHROPIC_API_KEY: SecretStr = SecretStr("")


class EnvironmentOption(StrEnum):
    LOCAL = "local"
    STAGING = "staging"
    PRODUCTION = "production"


class EnvironmentSettings(BaseSettings):
    ENVIRONMENT: EnvironmentOption = EnvironmentOption.LOCAL


class CORSSettings(BaseSettings):
    CORS_ORIGINS: list[str] = ["*"]
    CORS_METHODS: list[str] = ["*"]
    CORS_HEADERS: list[str] = ["*"]


class Settings(
    AppSettings,
    PostgresSettings,
    CryptSettings,
    FirstUserSettings,
    TestUserSettings,
    StorageSettings,
    AISettings,
    EnvironmentSettings,
    CORSSettings,
):
    """Composed application settings."""

    model_config = SettingsConfigDict(
        env_file=os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "..", ".env"),
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )


settings = Settings()
