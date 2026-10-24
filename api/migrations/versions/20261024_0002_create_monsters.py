"""Cria a tabela de monstros e importa os monstros do SRD 5.1.

Os dados vêm de ``migrations/data/srd_5_1_monsters.csv``, gerado da API 5e-bits (/api/2014). O XP de
quatro monstros vinha errado na fonte (Brass Dragon Wyrmling, Deep Gnome, Dretch e Riding Horse) e
foi corrigido pela tabela "XP por CR" do SRD.

A migração não importa os modelos da API: assim ela continua igual mesmo que os modelos mudem.

Revision ID: 0002
Revises: 0001
Create Date: 2026-10-24
"""

import csv
from collections.abc import Sequence
from decimal import Decimal
from fractions import Fraction
from pathlib import Path

import sqlalchemy as sa
from alembic import op

revision: str = "0002"
down_revision: str | None = "0001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

DATA = Path(__file__).resolve().parents[1] / "data" / "srd_5_1_monsters.csv"


def _challenge_rating(value: str) -> Decimal:
    fraction = Fraction(value)
    return Decimal(fraction.numerator) / Decimal(fraction.denominator)


def upgrade() -> None:
    monsters = op.create_table(
        "monsters",
        sa.Column("index", sa.String(80), primary_key=True),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("size", sa.String(20), nullable=False),
        sa.Column("type", sa.String(40), nullable=False),
        sa.Column("challenge_rating", sa.Numeric(6, 3), nullable=False),
        sa.Column("xp", sa.Integer(), nullable=False),
        sa.CheckConstraint("challenge_rating >= 0 AND challenge_rating <= 30", "monsters_cr_ck"),
        sa.CheckConstraint("xp >= 0", "monsters_xp_ck"),
    )
    op.create_index("monsters_challenge_rating_ix", "monsters", ["challenge_rating"])

    with DATA.open(encoding="utf-8", newline="") as file:
        rows = [
            {
                "index": row["index"],
                "name": row["name"],
                "size": row["size"],
                "type": row["type"],
                "challenge_rating": _challenge_rating(row["challenge_rating"]),
                "xp": int(row["xp"]),
            }
            for row in csv.DictReader(file)
        ]
    op.bulk_insert(monsters, rows)


def downgrade() -> None:
    op.drop_index("monsters_challenge_rating_ix", table_name="monsters")
    op.drop_table("monsters")
