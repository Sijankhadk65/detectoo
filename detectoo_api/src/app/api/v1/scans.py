"""Scan endpoints — record, list, get, update, soft-delete."""

from typing import Annotated, Any

from fastapi import APIRouter, Depends, Request
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_user
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import NotFoundException
from ...crud.crud_plants import crud_plants
from ...crud.crud_scans import crud_scans
from ...schemas.plant import PlantRead
from ...schemas.scan import ScanCreate, ScanCreateInternal, ScanRead, ScanUpdate

router = APIRouter(tags=["scans"])


@router.post("/scan", response_model=ScanRead, status_code=201)
async def create_scan(
    request: Request,
    scan: ScanCreate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Record a new plant scan for the authenticated user."""
    if scan.plant_id is not None:
        db_plant = await crud_plants.get(
            db=db,
            id=scan.plant_id,
            created_by_user_id=current_user["id"],
            is_deleted=False,
            schema_to_select=PlantRead,
        )
        if db_plant is None:
            raise NotFoundException("Plant not found")

    scan_internal_dict = scan.model_dump()
    scan_internal_dict["created_by_user_id"] = current_user["id"]

    scan_internal = ScanCreateInternal(**scan_internal_dict)
    created_scan = await crud_scans.create(db=db, object=scan_internal, schema_to_select=ScanRead)

    if created_scan is None:
        raise NotFoundException("Failed to create scan")

    return created_scan


@router.get("/scans", response_model=PaginatedListResponse[ScanRead])
async def read_scans(
    request: Request,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
    plant_id: int | None = None,
    page: int = 1,
    items_per_page: int = 10,
) -> dict[str, Any]:
    """List scans for the authenticated user, optionally filtered by plant."""
    filters: dict[str, Any] = {
        "created_by_user_id": current_user["id"],
        "is_deleted": False,
    }
    if plant_id is not None:
        filters["plant_id"] = plant_id

    scans_data = await crud_scans.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        **filters,
    )

    response: dict[str, Any] = paginated_response(crud_data=scans_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/scan/{id}", response_model=ScanRead)
async def read_scan(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, Any]:
    """Get a single scan by ID."""
    db_scan = await crud_scans.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=ScanRead
    )
    if db_scan is None:
        raise NotFoundException("Scan not found")

    return db_scan


@router.patch("/scan/{id}")
async def update_scan(
    request: Request,
    id: int,
    values: ScanUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Update a scan (e.g. attach it to a plant) owned by the authenticated user."""
    db_scan = await crud_scans.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=ScanRead
    )
    if db_scan is None:
        raise NotFoundException("Scan not found")

    if values.plant_id is not None:
        db_plant = await crud_plants.get(
            db=db,
            id=values.plant_id,
            created_by_user_id=current_user["id"],
            is_deleted=False,
            schema_to_select=PlantRead,
        )
        if db_plant is None:
            raise NotFoundException("Plant not found")

    await crud_scans.update(db=db, object=values, id=id)
    return {"message": "Scan updated"}


@router.delete("/scan/{id}")
async def delete_scan(
    request: Request,
    id: int,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Soft-delete a scan owned by the authenticated user."""
    db_scan = await crud_scans.get(
        db=db, id=id, created_by_user_id=current_user["id"], is_deleted=False, schema_to_select=ScanRead
    )
    if db_scan is None:
        raise NotFoundException("Scan not found")

    await crud_scans.delete(db=db, id=id)
    return {"message": "Scan deleted"}
