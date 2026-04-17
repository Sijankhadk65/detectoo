from typing import Annotated, Any

from fastapi import APIRouter, Depends, Request
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_superuser, get_current_user
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import NotFoundException
from ...core.utils.cache import cache
from ...crud.crud_plants import crud_plants
from ...schemas.plant import PlantCreate, PlantCreateInternal, PlantRead, PlantUpdate

router = APIRouter(tags=["plants"])


@router.post("/plant", response_model=PlantRead, status_code=201)
async def create_plant(
    request: Request,
    plant: PlantCreate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Create a new plant for the authenticated user."""
    plant_internal_dict = plant.model_dump()
    plant_internal_dict["created_by_user_id"] = current_user["id"]

    plant_internal = PlantCreateInternal(**plant_internal_dict)
    created_plant = await crud_plants.create(db=db, object=plant_internal, schema_to_select=PlantRead)

    if created_plant is None:
        raise NotFoundException("Failed to create plant")

    return created_plant


@router.get("/plants", response_model=PaginatedListResponse[PlantRead])
async def read_plants(
    request: Request,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
    page: int = 1,
    items_per_page: int = 10,
) -> dict:
    """List all plants for the authenticated user."""
    user_id = current_user["id"]

    plants_data = await crud_plants.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        created_by_user_id=user_id,
        is_deleted=False,
    )

    response: dict[str, Any] = paginated_response(crud_data=plants_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/plant/{id}", response_model=PlantRead)
@cache(key_prefix="plant_cache", resource_id_name="id")
async def read_plant(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Get a single plant by ID."""
    db_plant = await crud_plants.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=PlantRead
    )
    if db_plant is None:
        raise NotFoundException("Plant not found")

    return db_plant


@router.patch("/plant/{id}")
@cache("plant_cache", resource_id_name="id", pattern_to_invalidate_extra=["user_*_plants:*"])
async def update_plant(
    request: Request,
    id: int,
    values: PlantUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Update a plant owned by the authenticated user."""
    db_plant = await crud_plants.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=PlantRead
    )
    if db_plant is None:
        raise NotFoundException("Plant not found")

    await crud_plants.update(db=db, object=values, id=id)
    return {"message": "Plant updated"}


@router.delete("/plant/{id}")
@cache("plant_cache", resource_id_name="id", pattern_to_invalidate_extra=["user_*_plants:*"])
async def delete_plant(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Soft-delete a plant owned by the authenticated user."""
    db_plant = await crud_plants.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=PlantRead
    )
    if db_plant is None:
        raise NotFoundException("Plant not found")

    await crud_plants.delete(db=db, id=id)
    return {"message": "Plant deleted"}


@router.delete("/db_plant/{id}", dependencies=[Depends(get_current_superuser)])
@cache("plant_cache", resource_id_name="id", pattern_to_invalidate_extra=["user_*_plants:*"])
async def erase_db_plant(
    request: Request,
    id: int,
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Permanently delete a plant from the database (superuser only)."""
    db_plant = await crud_plants.get(db=db, id=id, is_deleted=False, schema_to_select=PlantRead)
    if db_plant is None:
        raise NotFoundException("Plant not found")

    await crud_plants.db_delete(db=db, id=id)
    return {"message": "Plant deleted from the database"}
