"""Pydantic schemas for the Plant model."""

from datetime import datetime
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field

from ..core.schemas import PersistentDeletion, TimestampSchema, UUIDSchema


class PlantBase(BaseModel):
    """Base schema for plant data."""

    name: Annotated[str, Field(min_length=1, max_length=100, examples=["Tomato Plant"])]
    health_status: Annotated[
        str,
        Field(
            pattern=r"^(healthy|needsAttention|recovering)$",
            examples=["healthy"],
            default="healthy",
        ),
    ]
    icon_code_point: Annotated[int, Field(examples=[59540], default=59540)]


class Plant(TimestampSchema, PlantBase, UUIDSchema, PersistentDeletion):
    """Full plant schema with all fields."""

    created_by_user_id: int
    last_watered: datetime | None = None


class PlantRead(BaseModel):
    """Schema for reading plant data."""

    id: int
    name: Annotated[str, Field(min_length=1, max_length=100, examples=["Tomato Plant"])]
    health_status: Annotated[str, Field(examples=["healthy"])]
    last_watered: datetime | None
    icon_code_point: int
    image_url: str | None
    sunlight: str | None
    humidity: str | None
    created_by_user_id: int
    created_at: datetime


class RecoveryStepDetectionRead(BaseModel):
    """A single recovery step suggested by Claude during plant detection."""

    title: str
    description: str
    step_order: int


class RecoveryPlanDetectionRead(BaseModel):
    """Disease/infestation data returned alongside the plant detection result.

    Only present when Claude identifies a condition requiring treatment.
    """

    condition: str
    severity: str
    summary: str
    estimated_recovery: str | None
    do_list: list[str]
    dont_list: list[str]
    signs_of_improvement: list[str]
    steps: list[RecoveryStepDetectionRead]


class PlantDetectionRead(BaseModel):
    """Detection result returned by the /plant/from-photo endpoint.

    Contains Claude's best guess for the plant. The client should
    present this to the user for confirmation before calling POST /plant.
    If a disease or infestation is detected, ``disease`` carries a full
    recovery plan payload ready to pass to POST /recovery-plan.
    """

    name: str
    health_status: str
    icon_code_point: int
    image_url: str
    sunlight: str
    humidity: str
    disease: RecoveryPlanDetectionRead | None = None


class PlantCreate(PlantBase):
    """Schema for creating a new plant."""

    model_config = ConfigDict(extra="forbid")

    last_watered: datetime | None = None
    image_url: str | None = None
    sunlight: str | None = None
    humidity: str | None = None


class PlantCreateInternal(PlantCreate):
    """Internal schema that includes the user ID."""

    created_by_user_id: int


class PlantUpdate(BaseModel):
    """Schema for updating a plant."""

    model_config = ConfigDict(extra="forbid")

    name: Annotated[str | None, Field(min_length=1, max_length=100, examples=["Updated Tomato Plant"], default=None)]
    health_status: Annotated[
        str | None,
        Field(
            pattern=r"^(healthy|needsAttention|recovering)$",
            examples=["needsAttention"],
            default=None,
        ),
    ]
    last_watered: datetime | None = None
    icon_code_point: Annotated[int | None, Field(examples=[59540], default=None)]


class PlantUpdateInternal(PlantUpdate):
    """Internal schema that includes the updated_at timestamp."""

    updated_at: datetime


class PlantDelete(BaseModel):
    """Schema for soft-deleting a plant."""

    model_config = ConfigDict(extra="forbid")

    is_deleted: bool
    deleted_at: datetime
