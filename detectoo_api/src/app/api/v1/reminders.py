"""Reminder endpoints — list, get, create, update, soft-delete."""

from typing import Annotated, Any

from fastapi import APIRouter, Depends, Request
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_user
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import NotFoundException
from ...crud.crud_plants import crud_plants
from ...crud.crud_reminders import crud_reminders
from ...schemas.plant import PlantRead
from ...schemas.reminder import ReminderCreate, ReminderCreateInternal, ReminderRead, ReminderUpdate

router = APIRouter(tags=["reminders"])


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


@router.post("/reminder", response_model=ReminderRead, status_code=201)
async def create_reminder(
    request: Request,
    reminder: ReminderCreate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Create a new reminder for the authenticated user."""
    if reminder.plant_id is not None:
        await _assert_user_owns_plant(reminder.plant_id, current_user["id"], db)

    reminder_internal_dict = reminder.model_dump()
    reminder_internal_dict["created_by_user_id"] = current_user["id"]

    reminder_internal = ReminderCreateInternal(**reminder_internal_dict)
    created_reminder = await crud_reminders.create(db=db, object=reminder_internal, schema_to_select=ReminderRead)

    if created_reminder is None:
        raise NotFoundException("Failed to create reminder")

    return created_reminder


@router.get("/reminders", response_model=PaginatedListResponse[ReminderRead])
async def read_reminders(
    request: Request,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
    plant_id: int | None = None,
    page: int = 1,
    items_per_page: int = 10,
) -> dict[str, Any]:
    """List reminders for the authenticated user, optionally filtered by plant."""
    filters: dict[str, Any] = {
        "created_by_user_id": current_user["id"],
        "is_deleted": False,
    }
    if plant_id is not None:
        filters["plant_id"] = plant_id

    reminders_data = await crud_reminders.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        sort_columns=["time"],
        sort_orders=["asc"],
        **filters,
    )

    response: dict[str, Any] = paginated_response(crud_data=reminders_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/reminder/{id}", response_model=ReminderRead)
async def read_reminder(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Get a single reminder by ID."""
    db_reminder = await crud_reminders.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=ReminderRead
    )
    if db_reminder is None:
        raise NotFoundException("Reminder not found")

    return db_reminder


@router.patch("/reminder/{id}")
async def update_reminder(
    request: Request,
    id: int,
    values: ReminderUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Update a reminder owned by the authenticated user."""
    db_reminder = await crud_reminders.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=ReminderRead
    )
    if db_reminder is None:
        raise NotFoundException("Reminder not found")

    if values.plant_id is not None:
        await _assert_user_owns_plant(values.plant_id, current_user["id"], db)

    await crud_reminders.update(db=db, object=values, id=id)
    return {"message": "Reminder updated"}


@router.delete("/reminder/{id}")
async def delete_reminder(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Soft-delete a reminder owned by the authenticated user."""
    db_reminder = await crud_reminders.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=ReminderRead
    )
    if db_reminder is None:
        raise NotFoundException("Reminder not found")

    await crud_reminders.delete(db=db, id=id)
    return {"message": "Reminder deleted"}
