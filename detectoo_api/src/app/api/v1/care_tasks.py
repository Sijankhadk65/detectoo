"""Care task endpoints — list, get, create, update, soft-delete."""

from typing import Annotated, Any

from fastapi import APIRouter, Depends, Request
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_user
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import NotFoundException
from ...crud.crud_care_tasks import crud_care_tasks
from ...crud.crud_plants import crud_plants
from ...schemas.care_task import CareTaskCreate, CareTaskCreateInternal, CareTaskRead, CareTaskUpdate
from ...schemas.plant import PlantRead

router = APIRouter(tags=["care_tasks"])


async def _assert_user_owns_plant(plant_id: int, user_id: int, db: AsyncSession) -> None:
    """Raise NotFoundException if the plant does not belong to the user."""
    db_plant = await crud_plants.get(
        db=db,
        id=plant_id,
        created_by_user_id=user_id,
        is_deleted=False,
        schema_to_select=PlantRead,
    )
    if db_plant is None:
        raise NotFoundException("Plant not found")


@router.post("/care-task", response_model=CareTaskRead, status_code=201)
async def create_care_task(
    request: Request,
    care_task: CareTaskCreate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Create a new care task for the authenticated user."""
    if care_task.plant_id is not None:
        await _assert_user_owns_plant(care_task.plant_id, current_user["id"], db)

    task_internal_dict = care_task.model_dump()
    task_internal_dict["created_by_user_id"] = current_user["id"]

    task_internal = CareTaskCreateInternal(**task_internal_dict)
    created_task = await crud_care_tasks.create(db=db, object=task_internal, schema_to_select=CareTaskRead)

    if created_task is None:
        raise NotFoundException("Failed to create care task")

    return created_task


@router.get("/care-tasks", response_model=PaginatedListResponse[CareTaskRead])
async def read_care_tasks(
    request: Request,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
    plant_id: int | None = None,
    done: bool | None = None,
    page: int = 1,
    items_per_page: int = 10,
) -> dict[str, Any]:
    """List care tasks for the authenticated user, optionally filtered by plant or done status."""
    filters: dict[str, Any] = {
        "created_by_user_id": current_user["id"],
        "is_deleted": False,
    }
    if plant_id is not None:
        filters["plant_id"] = plant_id
    if done is not None:
        filters["done"] = done

    tasks_data = await crud_care_tasks.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        sort_columns=["due_date"],
        sort_orders=["asc"],
        **filters,
    )

    response: dict[str, Any] = paginated_response(crud_data=tasks_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/care-task/{id}", response_model=CareTaskRead)
async def read_care_task(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Get a single care task by ID."""
    db_task = await crud_care_tasks.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=CareTaskRead
    )
    if db_task is None:
        raise NotFoundException("Care task not found")

    return db_task


@router.patch("/care-task/{id}")
async def update_care_task(
    request: Request,
    id: int,
    values: CareTaskUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Update a care task owned by the authenticated user."""
    db_task = await crud_care_tasks.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=CareTaskRead
    )
    if db_task is None:
        raise NotFoundException("Care task not found")

    if values.plant_id is not None:
        await _assert_user_owns_plant(values.plant_id, current_user["id"], db)

    await crud_care_tasks.update(db=db, object=values, id=id)
    return {"message": "Care task updated"}


@router.delete("/care-task/{id}")
async def delete_care_task(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Soft-delete a care task owned by the authenticated user."""
    db_task = await crud_care_tasks.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=CareTaskRead
    )
    if db_task is None:
        raise NotFoundException("Care task not found")

    await crud_care_tasks.delete(db=db, id=id)
    return {"message": "Care task deleted"}
