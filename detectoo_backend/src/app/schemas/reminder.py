from datetime import datetime
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field


class ReminderBase(BaseModel):
    """Base schema for reminder data."""

    title: Annotated[str, Field(min_length=1, max_length=200, examples=["Water the tomato plant"])]
    time: Annotated[datetime, Field(examples=["2026-04-17T08:00:00Z"])]
    icon_code_point: Annotated[int, Field(examples=[59573], default=59573)]
    plant_id: Annotated[int | None, Field(examples=[1], default=None)]


class ReminderRead(BaseModel):
    """Schema for reading reminder data."""

    id: int
    title: str
    time: datetime
    icon_code_point: int
    plant_id: int | None
    created_by_user_id: int
    created_at: datetime


class ReminderCreate(ReminderBase):
    """Schema for creating a new reminder."""

    model_config = ConfigDict(extra="forbid")


class ReminderCreateInternal(ReminderCreate):
    """Internal schema that includes the user ID."""

    created_by_user_id: int


class ReminderUpdate(BaseModel):
    """Schema for updating a reminder."""

    model_config = ConfigDict(extra="forbid")

    title: Annotated[str | None, Field(min_length=1, max_length=200, default=None)]
    time: datetime | None = None
    icon_code_point: Annotated[int | None, Field(default=None)]
    plant_id: Annotated[int | None, Field(default=None)]


class ReminderUpdateInternal(ReminderUpdate):
    """Internal schema that includes the updated_at timestamp."""

    updated_at: datetime


class ReminderDelete(BaseModel):
    """Schema for soft-deleting a reminder."""

    model_config = ConfigDict(extra="forbid")

    is_deleted: bool
    deleted_at: datetime
