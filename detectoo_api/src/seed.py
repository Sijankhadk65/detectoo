"""Idempotent database seed: creates the admin superuser and a test user if they don't exist."""

import asyncio

from sqlalchemy import select

from app.core.db.database import async_engine, local_session
from app.core.config import settings
from app.core.security import get_password_hash
from app.models.user import User  # noqa: F401 – registers the model on Base.metadata


async def _create_user_if_missing(
    session,
    *,
    name: str,
    username: str,
    email: str,
    password: str,
    is_superuser: bool,
) -> None:
    result = await session.execute(select(User).where(User.username == username))
    if result.scalar_one_or_none() is not None:
        print(f"  [seed] user '{username}' already exists — skipping")
        return

    user = User(
        name=name,
        username=username,
        email=email,
        hashed_password=get_password_hash(password),
        is_superuser=is_superuser,
    )
    session.add(user)
    await session.commit()
    label = "superuser" if is_superuser else "user"
    print(f"  [seed] created {label} '{username}'")


async def seed() -> None:
    """Seed the database with the admin superuser and a test user."""
    async with local_session() as session:
        await _create_user_if_missing(
            session,
            name=settings.ADMIN_NAME,
            username=settings.ADMIN_USERNAME,
            email=settings.ADMIN_EMAIL,
            password=settings.ADMIN_PASSWORD,
            is_superuser=True,
        )
        await _create_user_if_missing(
            session,
            name=settings.TEST_USER_NAME,
            username=settings.TEST_USER_USERNAME,
            email=settings.TEST_USER_EMAIL,
            password=settings.TEST_USER_PASSWORD,
            is_superuser=False,
        )


async def main() -> None:
    await seed()
    await async_engine.dispose()


if __name__ == "__main__":
    asyncio.run(main())
