from collections import deque
from collections.abc import Iterator

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pydantic import SecretStr

from critsense.ai.chat import ChatMessage, ChatResult
from critsense.auth.dependencies import get_user_repository
from critsense.auth.models import User
from critsense.auth.repository import UsernameTakenError
from critsense.config import Settings
from critsense.main import create_app

TEST_SECRET = "test-secret-with-at-least-32-characters!!"
PASSWORD = "uma-senha-longa"


class FakeChatModel:
    """Modelo de chat falso: devolve as respostas da fila, em ordem, e guarda as chamadas.

    Nenhum teste chama um provedor real.
    """

    def __init__(self) -> None:
        self._responses: deque[ChatResult | Exception] = deque()
        self.calls: list[tuple[str, list[ChatMessage]]] = []

    def reply(self, text: str) -> FakeChatModel:
        self._responses.append(ChatResult(text))
        return self

    def refuse(self) -> FakeChatModel:
        self._responses.append(ChatResult("", refused=True))
        return self

    def fail(self, error: Exception) -> FakeChatModel:
        self._responses.append(error)
        return self

    async def complete(self, system: str, messages: list[ChatMessage]) -> ChatResult:
        self.calls.append((system, messages))
        if not self._responses:
            raise AssertionError("FakeChatModel sem respostas na fila")
        response = self._responses.popleft()
        if isinstance(response, Exception):
            raise response
        return response


class InMemoryUserRepository:
    """Repositório em memória para os testes da API que não precisam do PostgreSQL."""

    def __init__(self) -> None:
        self.users: dict[str, User] = {}

    async def find_by_username(self, username: str) -> User | None:
        return self.users.get(username)

    async def exists_by_username(self, username: str) -> bool:
        return username in self.users

    async def add(self, user: User) -> None:
        if user.username in self.users:
            raise UsernameTakenError
        self.users[user.username] = user


def make_settings(**overrides: object) -> Settings:
    values: dict[str, object] = {
        "jwt_secret": SecretStr(TEST_SECRET),
        "ai_provider": "none",
        "ai_rate_limit_per_minute": 3,
        **overrides,
    }
    # _env_file=None: os testes não leem o .env de quem roda.
    return Settings(_env_file=None, **values)  # type: ignore[arg-type]


@pytest.fixture
def settings() -> Settings:
    return make_settings()


@pytest.fixture
def fake_model() -> FakeChatModel:
    return FakeChatModel()


@pytest.fixture
def users() -> InMemoryUserRepository:
    return InMemoryUserRepository()


@pytest.fixture
def app(settings: Settings, fake_model: FakeChatModel, users: InMemoryUserRepository) -> FastAPI:
    app = create_app(settings, fake_model)
    app.dependency_overrides[get_user_repository] = lambda: users
    return app


@pytest.fixture
def client(app: FastAPI) -> Iterator[TestClient]:
    with TestClient(app) as client:
        yield client


def register(client: TestClient, username: str = "thorin") -> str:
    """Cria uma conta e devolve o token."""
    response = client.post(
        "/api/v1/auth/register", json={"username": username, "password": PASSWORD}
    )
    assert response.status_code == 201, response.text
    token: str = response.json()["accessToken"]
    return token


def bearer(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}
