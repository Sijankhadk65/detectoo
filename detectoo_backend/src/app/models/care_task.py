import uuid as uuid_pkg
from datetime import UTC, datetime

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column
from uuid6 import uuid7

from ..core.db.database import Base


class CareTask(Base):
    """Represents a plant care to-do item owned by a user."""

    __tablename__ = "care_task"

    id: Mapped[int] = mapped_column(autoincrement=True, primary_key=True, init=False)
    created_by_user_id: Mapped[int] = mapped_column(ForeignKey("user.id"), index=True)

    title: Mapped[str] = mapped_column(String(200))
    due_date: Mapped[datetime] = mapped_column(DateTime(timezone=True))

    done: Mapped[bool] = mapped_column(default=False, index=True)
    plant_id: Mapped[int | None] = mapped_column(ForeignKey("plant.id"), index=True, default=None)

    uuid: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), default_factory=uuid7, unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default_factory=lambda: datetime.now(UTC))
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    is_deleted: Mapped[bool] = mapped_column(default=False, index=True)
