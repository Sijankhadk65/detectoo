from datetime import datetime
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field

from ..core.schemas import PersistentDeletion, TimestampSchema, UUIDSchema


class DetectedIssue(BaseModel):
    """A single issue detected during a plant scan."""

    name: Annotated[str, Field(min_length=1, max_length=100, examples=["Leaf Blight"])]
    description: Annotated[str, Field(min_length=1, max_length=2000, examples=["Brown spots spreading on leaves..."])]
    severity: Annotated[
        str,
        Field(pattern=r"^(Mild|Moderate|Severe)$", examples=["Moderate"]),
    ]
    confidence: Annotated[float, Field(ge=0.0, le=1.0, examples=[0.87])]


class ScanBase(BaseModel):
    """Base schema for scan data."""

    plant_name: Annotated[str, Field(min_length=1, max_length=100, examples=["Tomato Plant"])]
    species: Annotated[str, Field(min_length=1, max_length=100, examples=["Solanum lycopersicum"])]
    is_healthy: Annotated[bool, Field(examples=[False], default=True)]
    image_url: Annotated[
        str | None,
        Field(
            pattern=r"^(https?|ftp)://[^\s/$.?#].[^\s]*$",
            examples=["https://cdn.example.com/scan.jpg"],
            default=None,
        ),
    ]
    issues: Annotated[list[DetectedIssue], Field(default_factory=list)]
    plant_id: Annotated[int | None, Field(examples=[1], default=None)]


class ScanRead(BaseModel):
    """Schema for reading scan data."""

    id: int
    created_by_user_id: int
    plant_id: int | None
    plant_name: str
    species: str
    is_healthy: bool
    image_url: str | None
    issues: list[DetectedIssue]
    created_at: datetime


class ScanCreate(ScanBase):
    """Schema for creating a new scan."""

    model_config = ConfigDict(extra="forbid")


class ScanCreateInternal(ScanBase):
    """Internal schema that includes the user ID."""

    created_by_user_id: int


class ScanUpdate(BaseModel):
    """Schema for updating a scan (e.g. linking it to a plant after the fact)."""

    model_config = ConfigDict(extra="forbid")

    plant_id: Annotated[int | None, Field(examples=[1], default=None)]


class ScanUpdateInternal(ScanUpdate):
    """Internal schema that includes the updated_at timestamp."""

    updated_at: datetime


class ScanDelete(BaseModel):
    """Schema for soft-deleting a scan."""

    model_config = ConfigDict(extra="forbid")

    is_deleted: bool
    deleted_at: datetime


class Scan(TimestampSchema, ScanBase, UUIDSchema, PersistentDeletion):
    """Full scan schema with all fields."""

    created_by_user_id: int
