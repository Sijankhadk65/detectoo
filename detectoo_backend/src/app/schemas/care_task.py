from datetime import datetime
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field


class CareTaskBase(BaseModel):
    """Base schema for care task data."""

    title: Annotated[str, Field(min_length=1, max_length=200, examples=["Water the aloe"])]
    due_date: Annotated[datetime, Field(examples=["2026-04-17T08:00:00Z"])]
    plant_id: Annotated[int | None, Field(examples=[1], default=None)]


class CareTaskRead(BaseModel):
    """Schema for reading care task data."""

    id: int
    title: str
    done: bool
    due_date: datetime
    plant_id: int | None
    created_by_user_id: int
    created_at: datetime


class CareTaskCreate(CareTaskBase):
    """Schema for creating a new care task."""

    model_config = ConfigDict(extra="forbid")

    done: bool = False


class CareTaskCreateInternal(CareTaskCreate):
    """Internal schema that includes the user ID."""

    created_by_user_id: int


class CareTaskUpdate(BaseModel):
    """Schema for updating a care task."""

    model_config = ConfigDict(extra="forbid")

    title: Annotated[str | None, Field(min_length=1, max_length=200, default=None)]
    done: bool | None = None
    due_date: datetime | None = None
    plant_id: Annotated[int | None, Field(default=None)]


class CareTaskUpdateInternal(CareTaskUpdate):
    """Internal schema that includes the updated_at timestamp."""

    updated_at: datetime


class CareTaskDelete(BaseModel):
    """Schema for soft-deleting a care task."""

    model_config = ConfigDict(extra="forbid")

    is_deleted: bool
    deleted_at: datetime
