import uuid
from datetime import datetime

from sqlalchemy import DateTime, Index, String
from sqlalchemy.orm import Mapped, mapped_column

from critsense.db import Base


class User(Base):
    """Usuário da API. A senha só existe como hash (Argon2, via ``pwdlib``)."""

    __tablename__ = "users"
    __table_args__ = (Index("users_username_uq", "username", unique=True),)

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True)
    # Salvo em minúsculas (normalizado pelo AuthService); o índice único impede duplicatas.
    username: Mapped[str] = mapped_column(String(30))
    password_hash: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
