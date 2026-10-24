"""Cadastro e login de usuários."""

import asyncio
import uuid
from collections.abc import Callable
from datetime import UTC, datetime

from pwdlib import PasswordHash

from critsense.auth.models import User
from critsense.auth.repository import UsernameTakenError, UserRepository
from critsense.auth.tokens import IssuedToken, TokenService
from critsense.errors import ApiError, ErrorCode


class PasswordHasher:
    """Hash de senha com Argon2. O cálculo é lento de propósito, então roda numa thread."""

    def __init__(self) -> None:
        self._hash = PasswordHash.recommended()
        # Hash usado quando o usuário não existe, para o login levar o mesmo tempo nos dois
        # casos e não revelar quais nomes de usuário estão cadastrados.
        self.dummy_hash = self._hash.hash("dummy-password-for-timing")

    async def hash(self, password: str) -> str:
        return await asyncio.to_thread(self._hash.hash, password)

    async def verify(self, password: str, password_hash: str) -> bool:
        return await asyncio.to_thread(self._hash.verify, password, password_hash)


def normalize(username: str) -> str:
    return username.strip().lower()


class AuthService:
    def __init__(
        self,
        users: UserRepository,
        hasher: PasswordHasher,
        tokens: TokenService,
        clock: Callable[[], datetime] = lambda: datetime.now(UTC),
    ) -> None:
        self._users = users
        self._hasher = hasher
        self._tokens = tokens
        self._clock = clock

    async def register(self, username: str, password: str) -> IssuedToken:
        normalized = normalize(username)
        if await self._users.exists_by_username(normalized):
            raise _username_taken()
        user = User(
            id=uuid.uuid4(),
            username=normalized,
            password_hash=await self._hasher.hash(password),
            created_at=self._clock(),
        )
        try:
            await self._users.add(user)
        except UsernameTakenError as e:
            # Dois cadastros simultâneos com o mesmo nome: o índice único decide.
            raise _username_taken() from e
        return self._tokens.issue(user)

    async def login(self, username: str, password: str) -> IssuedToken:
        user = await self._users.find_by_username(normalize(username))
        password_hash = user.password_hash if user else self._hasher.dummy_hash
        matches = await self._hasher.verify(password, password_hash)
        if user is None or not matches:
            raise ApiError(ErrorCode.INVALID_CREDENTIALS, "Usuário ou senha incorretos.")
        return self._tokens.issue(user)


def _username_taken() -> ApiError:
    return ApiError(ErrorCode.USERNAME_TAKEN, "Este nome de usuário já está em uso.")
