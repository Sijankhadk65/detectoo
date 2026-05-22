"""FastCRUD instances for RecoveryPlan and RecoveryStep."""

from fastcrud import FastCRUD

from ..models.recovery import RecoveryPlan, RecoveryStep
from ..schemas.recovery import (
    RecoveryPlanCreateInternal,
    RecoveryPlanDelete,
    RecoveryPlanRead,
    RecoveryPlanUpdate,
    RecoveryPlanUpdateInternal,
    RecoveryStepCreateInternal,
    RecoveryStepDelete,
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
