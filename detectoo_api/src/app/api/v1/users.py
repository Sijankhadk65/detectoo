"""User CRUD endpoints — register, list, fetch, update, soft/hard delete, email verification."""

from datetime import UTC, datetime
from typing import Annotated, Any

from fastapi import APIRouter, Depends, Query, Request
from fastapi.responses import HTMLResponse
from fastcrud import PaginatedListResponse, compute_offset, paginated_response
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.dependencies import get_current_superuser, get_current_user
from ...core.db.database import async_get_db
from ...core.exceptions.http_exceptions import DuplicateValueException, ForbiddenException, NotFoundException
from ...core.security import blacklist_token, get_password_hash, oauth2_scheme
from ...core.utils.email import send_verification_email
from ...crud.crud_users import crud_users
from ...models.email_verification_token import EmailVerificationToken
from ...schemas.user import UserCreate, UserCreateInternal, UserRead, UserUpdate

router = APIRouter(tags=["users"])


async def _create_and_send_token(db: AsyncSession, user_id: int, email: str, name: str) -> None:
    """Create a fresh verification token and send it by email."""
    # Delete any existing tokens for this user first (clean slate)
    await db.execute(delete(EmailVerificationToken).where(EmailVerificationToken.user_id == user_id))
    token_row = EmailVerificationToken(user_id=user_id)
    db.add(token_row)
    # Commit before sending so the token is durably stored regardless of caller
    # (the request session does not auto-commit) and we never email a token that
    # isn't in the DB. token_row.token stays valid (session is expire_on_commit=False).
    await db.commit()
    await send_verification_email(to_email=email, name=name, token=token_row.token)


@router.post("/user", response_model=UserRead, status_code=201)
async def write_user(
    request: Request, user: UserCreate, db: Annotated[AsyncSession, Depends(async_get_db)]
) -> dict[str, Any]:
    """Register a new user and send a verification email."""
    if await crud_users.exists(db=db, email=user.email):
        raise DuplicateValueException("Email is already registered")

    if await crud_users.exists(db=db, username=user.username):
        raise DuplicateValueException("Username not available")

    user_internal_dict = user.model_dump()
    user_internal_dict["hashed_password"] = get_password_hash(password=user_internal_dict["password"])
    del user_internal_dict["password"]

    user_internal = UserCreateInternal(**user_internal_dict)
    created_user = await crud_users.create(db=db, object=user_internal, schema_to_select=UserRead)

    if created_user is None:
        raise NotFoundException("Failed to create user")

    await _create_and_send_token(
        db=db,
        user_id=created_user["id"],
        email=created_user["email"],
        name=created_user["name"],
    )

    return created_user


@router.get("/verify-email", response_class=HTMLResponse, include_in_schema=False)
async def verify_email(
    token: Annotated[str, Query()],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> HTMLResponse:
    """Consume a verification token and mark the user's email as verified."""

    def _page(title: str, heading: str, body: str, success: bool) -> HTMLResponse:
        color = "#2e7d32" if success else "#c62828"
        icon = "✅" if success else "❌"
        html = f"""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1.0" />
  <title>{title}</title>
  <style>
    body{{margin:0;padding:40px 16px;background:#f6f7f5;font-family:Arial,sans-serif;
          display:flex;align-items:center;justify-content:center;min-height:100vh;box-sizing:border-box;}}
    .card{{background:#fff;border-radius:16px;box-shadow:0 4px 24px rgba(0,0,0,.08);
            padding:48px 40px;max-width:440px;width:100%;text-align:center;}}
    h1{{margin:0 0 12px;color:{color};font-size:22px;}}
    p{{margin:0;color:#555;font-size:15px;line-height:1.6;}}
    .icon{{font-size:48px;margin-bottom:20px;}}
    a{{color:{color};font-weight:600;}}
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">{icon}</div>
    <h1>{heading}</h1>
    <p>{body}</p>
  </div>
</body>
</html>"""
        return HTMLResponse(content=html)

    result = await db.execute(select(EmailVerificationToken).where(EmailVerificationToken.token == token))
    token_row = result.scalar_one_or_none()

    if token_row is None:
        return _page(
            "Invalid link",
            "Invalid or expired link",
            "This verification link is invalid or has already been used. Open the Detectoo app and request a new link.",
            success=False,
        )

    if token_row.expires_at.replace(tzinfo=UTC) < datetime.now(UTC):
        await db.delete(token_row)
        await db.commit()
        return _page(
            "Link expired",
            "Verification link expired",
            "This link expired after 24 hours. Open the Detectoo app and tap "
            "<strong>Resend Email</strong> to get a new one.",
            success=False,
        )

    await crud_users.update(db=db, object={"is_email_verified": True}, id=token_row.user_id)
    await db.delete(token_row)
    await db.commit()

    return _page(
        "Email verified",
        "Email verified!",
        "Your Detectoo account is now active. You can close this tab and return to the app.",
        success=True,
    )


@router.post("/user/me/resend-verification")
async def resend_verification(
    request: Request,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Resend the verification email for the currently authenticated user."""
    if current_user.get("is_email_verified"):
        return {"message": "Email is already verified"}

    await _create_and_send_token(
        db=db,
        user_id=current_user["id"],
        email=current_user["email"],
        name=current_user["name"],
    )
    return {"message": "Verification email sent"}


@router.get("/users", response_model=PaginatedListResponse[UserRead])
async def read_users(
    request: Request,
    db: Annotated[AsyncSession, Depends(async_get_db)],
    page: int = 1,
    items_per_page: int = 10,
) -> dict[str, Any]:
    """List active users (paginated)."""
    users_data = await crud_users.get_multi(
        db=db,
        offset=compute_offset(page, items_per_page),
        limit=items_per_page,
        is_deleted=False,
    )

    response: dict[str, Any] = paginated_response(crud_data=users_data, page=page, items_per_page=items_per_page)
    return response


@router.get("/user/me/", response_model=UserRead)
async def read_users_me(request: Request, current_user: Annotated[dict, Depends(get_current_user)]) -> dict[str, Any]:
    """Return the authenticated user."""
    return current_user


@router.get("/user/{username}", response_model=UserRead)
async def read_user(
    request: Request, username: str, db: Annotated[AsyncSession, Depends(async_get_db)]
) -> dict[str, Any]:
    """Look up a user by username."""
    db_user = await crud_users.get(db=db, username=username, is_deleted=False, schema_to_select=UserRead)
    if db_user is None:
        raise NotFoundException("User not found")

    return db_user


@router.patch("/user/{username}")
async def patch_user(
    request: Request,
    values: UserUpdate,
    username: str,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
) -> dict[str, str]:
    """Update the authenticated user's own profile."""
    db_user = await crud_users.get(db=db, username=username)
    if db_user is None:
        raise NotFoundException("User not found")

    db_username = db_user["username"]
    db_email = db_user["email"]

    if db_username != current_user["username"]:
        raise ForbiddenException()

    if values.email is not None and values.email != db_email:
        if await crud_users.exists(db=db, email=values.email):
            raise DuplicateValueException("Email is already registered")

    if values.username is not None and values.username != db_username:
        if await crud_users.exists(db=db, username=values.username):
            raise DuplicateValueException("Username not available")

    await crud_users.update(db=db, object=values, username=username)
    return {"message": "User updated"}


@router.delete("/user/{username}")
async def erase_user(
    request: Request,
    username: str,
    current_user: Annotated[dict, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(async_get_db)],
    token: Annotated[str, Depends(oauth2_scheme)],
) -> dict[str, str]:
    """Soft-delete the authenticated user's own account."""
    db_user = await crud_users.get(db=db, username=username, schema_to_select=UserRead)
    if not db_user:
        raise NotFoundException("User not found")

    if username != current_user["username"]:
        raise ForbiddenException()

    await crud_users.delete(db=db, username=username)
    await blacklist_token(token=token, db=db)
    return {"message": "User deleted"}


@router.delete("/db_user/{username}", dependencies=[Depends(get_current_superuser)])
async def erase_db_user(
    request: Request,
    username: str,
    db: Annotated[AsyncSession, Depends(async_get_db)],
    token: Annotated[str, Depends(oauth2_scheme)],
) -> dict[str, str]:
    """Hard-delete a user (superuser only)."""
    if not await crud_users.exists(db=db, username=username):
        raise NotFoundException("User not found")

    await crud_users.db_delete(db=db, username=username)
    await blacklist_token(token=token, db=db)
    return {"message": "User deleted from the database"}
