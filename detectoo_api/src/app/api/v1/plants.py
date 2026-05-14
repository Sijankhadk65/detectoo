"""Plant endpoints — list, get, create, update, soft/hard delete."""

import os
import random
import uuid
from typing import Annotated, Any

from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_superuser, get_current_user
from ...core.config import settings
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import NotFoundException
from ...crud.crud_plants import crud_plants
from ...schemas.plant import PlantCreate, PlantCreateInternal, PlantRead, PlantUpdate

_ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp", "image/heic"}
_UPLOADS_PLANTS_DIR = os.path.join(settings.UPLOADS_DIR, "plants")

router = APIRouter(tags=["plants"])

_MOCK_NAMES = [
    "Monstera Deliciosa", "Golden Pothos", "Snake Plant", "Peace Lily",
    "Fiddle Leaf Fig", "Spider Plant", "Rubber Plant", "Aloe Vera",
    "Boston Fern", "ZZ Plant", "Philodendron", "Calathea",
]
_MOCK_ICONS = [0xE56D, 0xE894, 0xEA1E, 0xF483]  # eco, local_florist, yard, forest


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


@router.post("/plant/from-photo", response_model=PlantRead, status_code=201)
async def create_plant_from_photo(
    request: Request,
    photo: Annotated[UploadFile, File(description="Plant photo")],
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Accept a plant photo, persist it, and create a mock plant record.

    The image is stored under UPLOADS_DIR and exposed via /uploads/plants/<filename>.
    Name and icon are randomly assigned — ML inference will replace this later.
    """
    if photo.content_type not in _ALLOWED_CONTENT_TYPES:
        raise HTTPException(status_code=422, detail=f"Unsupported image type: {photo.content_type}")

    ext = (photo.filename or "photo.jpg").rsplit(".", 1)[-1].lower() or "jpg"
    filename = f"{uuid.uuid4().hex}.{ext}"
    os.makedirs(_UPLOADS_PLANTS_DIR, exist_ok=True)
    dest = os.path.join(_UPLOADS_PLANTS_DIR, filename)
    contents = await photo.read()
    with open(dest, "wb") as f:
        f.write(contents)

    image_url = f"{settings.SERVER_URL}/uploads/plants/{filename}"

    plant_internal = PlantCreateInternal(
        name=random.choice(_MOCK_NAMES),
        health_status="healthy",
        icon_code_point=random.choice(_MOCK_ICONS),
        created_by_user_id=current_user["id"],
        image_url=image_url,
    )
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
) -> dict[str, Any]:
    """List all plants for the authenticated user."""
    plants_data = await crud_plants.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        created_by_user_id=current_user["id"],
        is_deleted=False,
    )

    response: dict[str, Any] = paginated_response(crud_data=plants_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/plant/{id}", response_model=PlantRead)
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
async def erase_db_plant(
    request: Request,
    id: int,
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Permanently delete a plant (superuser only)."""
    db_plant = await crud_plants.get(db=db, id=id, is_deleted=False, schema_to_select=PlantRead)
    if db_plant is None:
        raise NotFoundException("Plant not found")

    await crud_plants.db_delete(db=db, id=id)
    return {"message": "Plant deleted from the database"}
