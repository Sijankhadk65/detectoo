"""SQLAlchemy model for a plant owned by a user."""

import uuid as uuid_pkg
from datetime import UTC, datetime

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column
from uuid6 import uuid7

from ..core.db.database import Base


class Plant(Base):
    """A plant owned by a user."""

    __tablename__ = "plant"

    id: Mapped[int] = mapped_column(autoincrement=True, primary_key=True, init=False)
    created_by_user_id: Mapped[int] = mapped_column(ForeignKey("user.id"), index=True)

    name: Mapped[str] = mapped_column(String(100))
    health_status: Mapped[str] = mapped_column(String(20), default="healthy")
    last_watered: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    icon_code_point: Mapped[int] = mapped_column(default=0xE894)
    image_url: Mapped[str | None] = mapped_column(String(500), default=None)
    sunlight: Mapped[str | None] = mapped_column(String(30), default=None)
    humidity: Mapped[str | None] = mapped_column(String(20), default=None)

    uuid: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), default_factory=uuid7, unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default_factory=lambda: datetime.now(UTC))
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    is_deleted: Mapped[bool] = mapped_column(default=False, index=True)
