"""SQLAlchemy models for recovery plans and their steps."""

import uuid as uuid_pkg
from datetime import UTC, datetime

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column
from uuid6 import uuid7

from ..core.db.database import Base


class RecoveryPlan(Base):
    """A recovery plan for a diseased plant.

    ``do_list``/``dont_list``/``signs_of_improvement`` are stored as JSONB.
    Individual steps live in :class:`RecoveryStep` so they can be toggled
    independently.
    """

    __tablename__ = "recovery_plan"

    id: Mapped[int] = mapped_column(autoincrement=True, primary_key=True, init=False)
    created_by_user_id: Mapped[int] = mapped_column(ForeignKey("user.id"), index=True)
    plant_id: Mapped[int] = mapped_column(ForeignKey("plant.id"), index=True)

    condition: Mapped[str] = mapped_column(String(100))
    severity: Mapped[str] = mapped_column(String(20))
    summary: Mapped[str] = mapped_column(String(2000))

    scan_id: Mapped[int | None] = mapped_column(ForeignKey("scan.id"), index=True, default=None)
    progress: Mapped[float] = mapped_column(Float, default=0.0)
    started_on: Mapped[datetime] = mapped_column(DateTime(timezone=True), default_factory=lambda: datetime.now(UTC))
    estimated_recovery: Mapped[str | None] = mapped_column(String(100), default=None)
    is_active: Mapped[bool] = mapped_column(default=True, index=True)

    do_list: Mapped[list[str]] = mapped_column(JSONB, default_factory=list)
    dont_list: Mapped[list[str]] = mapped_column(JSONB, default_factory=list)
    signs_of_improvement: Mapped[list[str]] = mapped_column(JSONB, default_factory=list)

    uuid: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), default_factory=uuid7, unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default_factory=lambda: datetime.now(UTC))
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
    is_deleted: Mapped[bool] = mapped_column(default=False, index=True)


class RecoveryStep(Base):
    """A single step within a recovery plan."""

    __tablename__ = "recovery_step"

    id: Mapped[int] = mapped_column(autoincrement=True, primary_key=True, init=False)
    recovery_plan_id: Mapped[int] = mapped_column(ForeignKey("recovery_plan.id"), index=True)

    title: Mapped[str] = mapped_column(String(200))
    description: Mapped[str] = mapped_column(String(2000))

    icon_code_point: Mapped[int] = mapped_column(Integer, default=0xE15B)
    completed: Mapped[bool] = mapped_column(default=False)
    step_order: Mapped[int] = mapped_column(Integer, default=0)

    uuid: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), default_factory=uuid7, unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default_factory=lambda: datetime.now(UTC))
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), default=None)
