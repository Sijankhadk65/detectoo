"""FastCRUD instances for RecoveryPlan, RecoveryStep, and RecoveryStepPhoto."""

from fastcrud import FastCRUD

from ..models.recovery import RecoveryPlan, RecoveryStep, RecoveryStepPhoto
from ..schemas.recovery import (
    RecoveryPlanCreateInternal,
    RecoveryPlanDelete,
    RecoveryPlanRead,
    RecoveryPlanUpdate,
    RecoveryPlanUpdateInternal,
    RecoveryStepCreateInternal,
    RecoveryStepDelete,
    RecoveryStepPhotoCreateInternal,
    RecoveryStepPhotoRead,
    RecoveryStepRead,
    RecoveryStepUpdate,
    RecoveryStepUpdateInternal,
)

CRUDRecoveryPlan = FastCRUD[
    RecoveryPlan,
    RecoveryPlanCreateInternal,
    RecoveryPlanUpdate,
    RecoveryPlanUpdateInternal,
    RecoveryPlanDelete,
    RecoveryPlanRead,
]
crud_recovery_plans = CRUDRecoveryPlan(RecoveryPlan)

CRUDRecoveryStep = FastCRUD[
    RecoveryStep,
    RecoveryStepCreateInternal,
    RecoveryStepUpdate,
    RecoveryStepUpdateInternal,
    RecoveryStepDelete,
    RecoveryStepRead,
]
crud_recovery_steps = CRUDRecoveryStep(RecoveryStep)

CRUDRecoveryStepPhoto = FastCRUD[
    RecoveryStepPhoto,
    RecoveryStepPhotoCreateInternal,
    None,
    None,
    None,
    RecoveryStepPhotoRead,
]
crud_recovery_step_photos = CRUDRecoveryStepPhoto(RecoveryStepPhoto)
