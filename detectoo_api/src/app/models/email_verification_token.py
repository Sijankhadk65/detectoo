"""SQLAlchemy model for email verification tokens."""

import uuid as uuid_pkg
from datetime import UTC, datetime, timedelta

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from ..core.db.database import Base

VERIFICATION_TOKEN_TTL_HOURS = 24


class EmailVerificationToken(Base):
    """A one-time token used to verify a user's email address.

    Tokens are consumed (deleted) on successful verification.
    Expired tokens are pruned lazily on each verification attempt.
    """

    __tablename__ = "email_verification_token"

    id: Mapped[int] = mapped_column(autoincrement=True, primary_key=True, init=False)
    user_id: Mapped[int] = mapped_column(ForeignKey("user.id", ondelete="CASCADE"), index=True)
    token: Mapped[str] = mapped_column(
        String(36),
        unique=True,
        index=True,
        default_factory=lambda: str(uuid_pkg.uuid4()),
    )
    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default_factory=lambda: datetime.now(UTC) + timedelta(hours=VERIFICATION_TOKEN_TTL_HOURS),
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default_factory=lambda: datetime.now(UTC),
    )
