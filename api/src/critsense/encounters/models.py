from decimal import Decimal

from sqlalchemy import Index, Integer, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column

from critsense.db import Base


class Monster(Base):
    """Monstro do SRD 5.1 (CC-BY-4.0), com o CR e o XP do bloco de estatísticas.

    A tabela vem da migração 0002 e só muda por migração: a API não depende de uma API externa
    para calcular a dificuldade de um encontro.
    """

    __tablename__ = "monsters"
    __table_args__ = (Index("monsters_challenge_rating_ix", "challenge_rating"),)

    # Identificador estável do SRD (ex: "adult-black-dragon"), o mesmo da API 5e-bits.
    index: Mapped[str] = mapped_column(String(80), primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    size: Mapped[str] = mapped_column(String(20))
    type: Mapped[str] = mapped_column(String(40))
    # Numeric guarda as frações do CR sem erro de arredondamento (1/8 = 0.125).
    challenge_rating: Mapped[Decimal] = mapped_column(Numeric(6, 3))
    xp: Mapped[int] = mapped_column(Integer)
