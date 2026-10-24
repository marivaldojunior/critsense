"""Cria a tabela de usuários.

O nome de usuário é salvo em minúsculas (normalizado pelo AuthService), então o índice único já
impede duplicatas como "Thorin" e "thorin".

Revision ID: 0001
Revises:
Create Date: 2026-10-24
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0001"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("username", sa.String(30), nullable=False),
        sa.Column("password_hash", sa.String(255), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("users_username_uq", "users", ["username"], unique=True)


def downgrade() -> None:
    op.drop_index("users_username_uq", table_name="users")
    op.drop_table("users")
