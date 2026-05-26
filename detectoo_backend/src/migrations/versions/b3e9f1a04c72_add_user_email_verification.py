"""Add email verification fields to user table

Revision ID: b3e9f1a04c72
Revises: 06a728fe2898
Create Date: 2026-05-26 00:00:00.000000

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b3e9f1a04c72"
down_revision: Union[str, None] = "06a728fe2898"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("user", sa.Column("is_verified", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.add_column("user", sa.Column("verification_code", sa.String(6), nullable=True))
    op.add_column("user", sa.Column("verification_code_expires_at", sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    op.drop_column("user", "verification_code_expires_at")
    op.drop_column("user", "verification_code")
    op.drop_column("user", "is_verified")
