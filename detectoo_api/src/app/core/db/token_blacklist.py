"""Token blacklist model — used to invalidate logged-out / deleted-user JWTs."""

from datetime import datetime

from sqlalchemy import DateTime, String
from sqlalchemy.orm import Mapped, mapped_column

from .database import Base


class TokenBlacklist(Base):
    """A single blacklisted JWT (access or refresh)."""

    __tablename__ = "token_blacklist"

    id: Mapped[int] = mapped_column("id", autoincrement=True, primary_key=True, init=False)
    token: Mapped[str] = mapped_column(String, unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime)
