"""Recovery plan + step endpoints."""

from typing import Annotated, Any

from fastapi import APIRouter, Depends, Request
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_user
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import NotFoundException
from ...crud.crud_plants import crud_plants
from ...crud.crud_recovery import crud_recovery_plans, crud_recovery_steps
from ...crud.crud_scans import crud_scans
from ...schemas.plant import PlantRead
from ...schemas.recovery import (
    RecoveryPlanCreate,
    RecoveryPlanCreateInternal,
    RecoveryPlanRead,
    RecoveryPlanReadWithSteps,
    RecoveryPlanUpdate,
    RecoveryStepCreateInternal,
    RecoveryStepRead,
    RecoveryStepUpdate,
)
from ...schemas.scan import ScanRead

router = APIRouter(tags=["recovery"])


async def _assert_user_owns_plan(db: AsyncSession, plan_id: int, user_id: int) -> dict[str, Any]:
    """Fetch a recovery plan and ensure it belongs to the given user."""
    db_plan = await crud_recovery_plans.get(
        db=db, id=plan_id, created_by_user_id=user_id, is_deleted=False, schema_to_select=RecoveryPlanRead
    )
    if db_plan is None:
        raise NotFoundException("Recovery plan not found")
    return dict(db_plan)


@router.post("/recovery-plan", response_model=RecoveryPlanReadWithSteps, status_code=201)
async def create_recovery_plan(
    request: Request,
    plan: RecoveryPlanCreate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Create a recovery plan for a plant, with an ordered list of steps."""
    db_plant = await crud_plants.get(
        db=db,
        id=plan.plant_id,
        created_by_user_id=current_user["id"],
        is_deleted=False,
        schema_to_select=PlantRead,
    )
    if db_plant is None:
        raise NotFoundException("Plant not found")

    if plan.scan_id is not None:
        db_scan = await crud_scans.get(
            db=db,
            id=plan.scan_id,
            created_by_user_id=current_user["id"],
            is_deleted=False,
            schema_to_select=ScanRead,
        )
        if db_scan is None:
            raise NotFoundException("Scan not found")

    plan_data = plan.model_dump(exclude={"steps"})
    plan_data["created_by_user_id"] = current_user["id"]

    plan_internal = RecoveryPlanCreateInternal(**plan_data)
    created_plan = await crud_recovery_plans.create(db=db, object=plan_internal, schema_to_select=RecoveryPlanRead)

    if created_plan is None:
        raise NotFoundException("Failed to create recovery plan")

    created_steps: list[dict[str, Any]] = []
    for step in plan.steps:
        step_data = step.model_dump()
        step_data["recovery_plan_id"] = created_plan["id"]
        step_internal = RecoveryStepCreateInternal(**step_data)
        created_step = await crud_recovery_steps.create(
            db=db, object=step_internal, schema_to_select=RecoveryStepRead
        )
        if created_step is not None:
            created_steps.append(dict(created_step))

    result = dict(created_plan)
    result["steps"] = created_steps
    return result


@router.get("/recovery-plans", response_model=PaginatedListResponse[RecoveryPlanRead])
async def read_recovery_plans(
    request: Request,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
    plant_id: int | None = None,
    is_active: bool | None = None,
    page: int = 1,
    items_per_page: int = 10,
) -> dict[str, Any]:
    """List recovery plans for the authenticated user."""
    filters: dict[str, Any] = {
        "created_by_user_id": current_user["id"],
        "is_deleted": False,
    }
    if plant_id is not None:
        filters["plant_id"] = plant_id
    if is_active is not None:
        filters["is_active"] = is_active

    plans_data = await crud_recovery_plans.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        **filters,
    )

    response: dict[str, Any] = paginated_response(crud_data=plans_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/recovery-plan/{id}", response_model=RecoveryPlanReadWithSteps)
async def read_recovery_plan(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Get a single recovery plan with all its steps."""
    db_plan = await _assert_user_owns_plan(db=db, plan_id=id, user_id=current_user["id"])

    steps_data = await crud_recovery_steps.get_multi(
        db=db,
        recovery_plan_id=id,
        sort_columns="step_order",
        sort_orders="asc",
    )

    db_plan["steps"] = steps_data.get("data", [])
    return db_plan


@router.patch("/recovery-plan/{id}")
async def update_recovery_plan(
    request: Request,
    id: int,
    values: RecoveryPlanUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Update a recovery plan (progress, active flag, lists, etc.)."""
    await _assert_user_owns_plan(db=db, plan_id=id, user_id=current_user["id"])
    await crud_recovery_plans.update(db=db, object=values, id=id)
    return {"message": "Recovery plan updated"}


@router.delete("/recovery-plan/{id}")
async def delete_recovery_plan(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Soft-delete a recovery plan owned by the authenticated user."""
    await _assert_user_owns_plan(db=db, plan_id=id, user_id=current_user["id"])
    await crud_recovery_plans.delete(db=db, id=id)
    return {"message": "Recovery plan deleted"}


@router.patch("/recovery-plan/{plan_id}/step/{step_id}")
async def update_recovery_step(
    request: Request,
    plan_id: int,
    step_id: int,
    values: RecoveryStepUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Update a recovery step (e.g. mark it completed)."""
    await _assert_user_owns_plan(db=db, plan_id=plan_id, user_id=current_user["id"])

    db_step = await crud_recovery_steps.get(
        db=db, id=step_id, recovery_plan_id=plan_id, schema_to_select=RecoveryStepRead
    )
    if db_step is None:
        raise NotFoundException("Recovery step not found")

    await crud_recovery_steps.update(db=db, object=values, id=step_id)
    return {"message": "Recovery step updated"}
