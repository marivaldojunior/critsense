from typing import Protocol

from sqlalchemy import exists, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from critsense.auth.models import User


class UsernameTakenError(Exception):
    """O índice único recusou o nome de usuário."""


class UserRepository(Protocol):
    async def find_by_username(self, username: str) -> User | None: ...

    async def exists_by_username(self, username: str) -> bool: ...

    async def add(self, user: User) -> None:
        """Grava o usuário. Lança ``UsernameTakenError`` se o nome já existe."""
        ...


class SqlUserRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def find_by_username(self, username: str) -> User | None:
        return await self._session.scalar(select(User).where(User.username == username))

    async def exists_by_username(self, username: str) -> bool:
        return bool(await self._session.scalar(select(exists().where(User.username == username))))

    async def add(self, user: User) -> None:
        self._session.add(user)
        try:
            await self._session.commit()
        except IntegrityError as e:
            await self._session.rollback()
            raise UsernameTakenError from e
