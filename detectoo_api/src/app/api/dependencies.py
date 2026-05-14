"""Reusable FastAPI dependencies — current user, optional user, superuser guard."""

from typing import Annotated, Any

from fastapi import Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.db.database import async_get_db
from ..core.exceptions.http_exceptions import ForbiddenException, UnauthorizedException
from ..core.security import TokenType, oauth2_scheme, verify_token
from ..crud.crud_users import crud_users


async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)], db: Annotated[AsyncSession, Depends(async_get_db)]
) -> dict[str, Any]:
    """Resolve the current user from a Bearer access token. Raises 401 if invalid."""
    token_data = await verify_token(token, TokenType.ACCESS, db)
    if token_data is None:
        raise UnauthorizedException("User not authenticated.")

    user = await crud_users.get(db=db, email=token_data.email, is_deleted=False)
    if user:
        return user

    raise UnauthorizedException("User not authenticated.")


async def get_optional_user(
    request: Request, db: Annotated[AsyncSession, Depends(async_get_db)]
) -> dict[str, Any] | None:
    """Return the current user if a valid Bearer token is present, otherwise ``None``."""
    token = request.headers.get("Authorization")
    if not token:
        return None

    try:
        token_type, _, token_value = token.partition(" ")
        if token_type.lower() != "bearer" or not token_value:
            return None

        token_data = await verify_token(token_value, TokenType.ACCESS, db)
        if token_data is None:
            return None

        return await get_current_user(token_value, db=db)

    except HTTPException:
        return None


async def get_current_superuser(current_user: Annotated[dict, Depends(get_current_user)]) -> dict[str, Any]:
    """Require the current user to have ``is_superuser=True``."""
    if not current_user["is_superuser"]:
        raise ForbiddenException("You do not have enough privileges.")

    return current_user
