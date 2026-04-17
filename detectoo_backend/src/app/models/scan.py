import uuid as uuid_pkg
from datetime import UTC, datetime
from typing import Any

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column
from uuid6 import uuid7

from ..core.db.database import Base


class Scan(Base):
    """Represents a scan of a plant that identifies species and any issues."""

    __tablename__ = "scan"

    id: Mapped[int] = mapped_column(autoincrement=True, primary_key=True, init=False)
    created_by_user_id: Mapped[int] = mapped_column(ForeignKey("user.id"), index=True)

    plant_name: Mapped[str] = mapped_column(String(100))
    species: Mapped[str] = mapped_column(String(100))

    plant_id: Mapped[int | None] = mapped_column(ForeignKey("plant.id"), index=True, default=None)
    is_healthy: Mapped[bool] = mapped_column(default=True)
    image_url: Mapped[str | None] = mapped_column(String, default=None)
    issues: Mapped[list[dict[str, Any]]] = mapped_column(JSONB, default_factory=list)

    uuid: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), default_factory=uuid7, unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default_factory=lambda: datetime.now(UTC))
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    is_deleted: Mapped[bool] = mapped_column(default=False, index=True)
