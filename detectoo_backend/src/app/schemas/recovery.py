from datetime import datetime
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field

from ..core.schemas import PersistentDeletion, TimestampSchema, UUIDSchema


# ---------------- recovery step ----------------
class RecoveryStepBase(BaseModel):
    """Base schema for a single recovery step."""

    title: Annotated[str, Field(min_length=1, max_length=200, examples=["Remove affected leaves"])]
    description: Annotated[
        str, Field(min_length=1, max_length=2000, examples=["Carefully prune visibly diseased leaves..."])
    ]
    icon_code_point: Annotated[int, Field(examples=[57691], default=57691)]
    step_order: Annotated[int, Field(ge=0, examples=[0], default=0)]


class RecoveryStepCreate(RecoveryStepBase):
    """Schema for creating a new recovery step (via nested plan creation)."""

    model_config = ConfigDict(extra="forbid")


class RecoveryStepCreateInternal(RecoveryStepBase):
    """Internal schema that includes the parent plan ID."""

    recovery_plan_id: int


class RecoveryStepRead(BaseModel):
    """Schema for reading a recovery step."""

    id: int
    recovery_plan_id: int
    title: str
    description: str
    icon_code_point: int
    completed: bool
    step_order: int


class RecoveryStepUpdate(BaseModel):
    """Schema for updating a recovery step."""

    model_config = ConfigDict(extra="forbid")

    title: Annotated[str | None, Field(min_length=1, max_length=200, default=None)]
    description: Annotated[str | None, Field(min_length=1, max_length=2000, default=None)]
    icon_code_point: Annotated[int | None, Field(default=None)]
    completed: Annotated[bool | None, Field(default=None)]
    step_order: Annotated[int | None, Field(ge=0, default=None)]


class RecoveryStepUpdateInternal(RecoveryStepUpdate):
    """Internal schema that includes the updated_at timestamp."""

    updated_at: datetime


class RecoveryStepDelete(BaseModel):
    """Placeholder delete schema (steps are hard-deleted with their parent plan)."""

    model_config = ConfigDict(extra="forbid")


# ---------------- recovery plan ----------------
class RecoveryPlanBase(BaseModel):
    """Base schema for a recovery plan."""

    condition: Annotated[str, Field(min_length=1, max_length=100, examples=["Leaf Blight"])]
    severity: Annotated[str, Field(pattern=r"^(Mild|Moderate|Severe)$", examples=["Moderate"])]
    summary: Annotated[
        str,
        Field(min_length=1, max_length=2000, examples=["A fungal infection causing leaf browning and defoliation..."]),
    ]
    estimated_recovery: Annotated[str | None, Field(max_length=100, examples=["2-3 weeks"], default=None)]
    do_list: Annotated[list[str], Field(default_factory=list)]
    dont_list: Annotated[list[str], Field(default_factory=list)]
    signs_of_improvement: Annotated[list[str], Field(default_factory=list)]


class RecoveryPlanCreate(RecoveryPlanBase):
    """Schema for creating a new recovery plan, including nested steps."""

    model_config = ConfigDict(extra="forbid")

    plant_id: Annotated[int, Field(examples=[1])]
    scan_id: Annotated[int | None, Field(examples=[1], default=None)]
    steps: Annotated[list[RecoveryStepCreate], Field(default_factory=list)]


class RecoveryPlanCreateInternal(RecoveryPlanBase):
    """Internal schema that includes user and plant IDs (no nested steps)."""

    created_by_user_id: int
    plant_id: int
    scan_id: int | None = None


class RecoveryPlanRead(BaseModel):
    """Schema for reading a recovery plan without nested steps."""

    id: int
    created_by_user_id: int
    plant_id: int
    scan_id: int | None
    condition: str
    severity: str
    summary: str
    progress: float
    started_on: datetime
    estimated_recovery: str | None
    is_active: bool
    do_list: list[str]
    dont_list: list[str]
    signs_of_improvement: list[str]
    created_at: datetime


class RecoveryPlanReadWithSteps(RecoveryPlanRead):
    """Schema for reading a recovery plan with its steps."""

    steps: list[RecoveryStepRead]


class RecoveryPlanUpdate(BaseModel):
    """Schema for updating a recovery plan."""

    model_config = ConfigDict(extra="forbid")

    condition: Annotated[str | None, Field(min_length=1, max_length=100, default=None)]
    severity: Annotated[str | None, Field(pattern=r"^(Mild|Moderate|Severe)$", default=None)]
    summary: Annotated[str | None, Field(min_length=1, max_length=2000, default=None)]
    progress: Annotated[float | None, Field(ge=0.0, le=1.0, default=None)]
    estimated_recovery: Annotated[str | None, Field(max_length=100, default=None)]
    is_active: Annotated[bool | None, Field(default=None)]
    do_list: Annotated[list[str] | None, Field(default=None)]
    dont_list: Annotated[list[str] | None, Field(default=None)]
    signs_of_improvement: Annotated[list[str] | None, Field(default=None)]


class RecoveryPlanUpdateInternal(RecoveryPlanUpdate):
    """Internal schema that includes the updated_at timestamp."""

    updated_at: datetime


class RecoveryPlanDelete(BaseModel):
    """Schema for soft-deleting a recovery plan."""

    model_config = ConfigDict(extra="forbid")

    is_deleted: bool
    deleted_at: datetime


class RecoveryPlan(TimestampSchema, RecoveryPlanBase, UUIDSchema, PersistentDeletion):
    """Full recovery plan schema with all fields."""

    created_by_user_id: int
    plant_id: int
    scan_id: int | None
    progress: float
    started_on: datetime
    is_active: bool
