"""Testes com um PostgreSQL real (Testcontainers) e as migrações do Alembic.

Sem Docker, os testes são pulados. No CI, todos rodam.
"""

from collections.abc import Iterator
from decimal import Decimal
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient

from critsense.db import create_engine, create_session_factory
from critsense.encounters.repository import MonsterRepository
from critsense.errors import ErrorCode
from critsense.main import create_app

from .conftest import PASSWORD, bearer, make_settings

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).resolve().parents[1]


def alembic_config(url: str) -> Config:
    config = Config(API_DIR / "alembic.ini")
    config.set_main_option("sqlalchemy.url", url)
    config.attributes["configure_logger"] = False
    return config


@pytest.fixture(scope="module")
def database_url() -> Iterator[str]:
    try:
        from testcontainers.community.postgres import PostgresContainer

        container = PostgresContainer("postgres:17-alpine", driver="asyncpg")
        container.start()
    except Exception as e:  # sem Docker ou sem a imagem
        pytest.skip(f"Docker indisponível: {e}")
    try:
        url: str = container.get_connection_url()
        command.upgrade(alembic_config(url), "head")
        yield url
    finally:
        container.stop()


@pytest.fixture
def client(database_url: str) -> Iterator[TestClient]:
    app = create_app(make_settings(database_url=database_url), chat_model=None)
    with TestClient(app) as client:
        yield client


def test_register_login_and_me(client: TestClient) -> None:
    register = client.post(
        "/api/v1/auth/register", json={"username": "Gimli", "password": PASSWORD}
    )
    assert register.status_code == 201

    duplicate = client.post(
        "/api/v1/auth/register", json={"username": "gimli", "password": PASSWORD}
    )
    assert duplicate.status_code == 409
    assert duplicate.json()["code"] == ErrorCode.USERNAME_TAKEN.name

    login = client.post("/api/v1/auth/login", json={"username": "GIMLI", "password": PASSWORD})
    assert login.status_code == 200

    me = client.get("/api/v1/me", headers=bearer(login.json()["accessToken"]))
    assert me.json()["username"] == "gimli"


def test_readiness_checks_the_database(client: TestClient) -> None:
    assert client.get("/health/ready").json() == {"status": "UP"}


def test_ai_without_provider_returns_503(client: TestClient) -> None:
    client.post("/api/v1/auth/register", json={"username": "legolas", "password": PASSWORD})
    login = client.post("/api/v1/auth/login", json={"username": "legolas", "password": PASSWORD})

    response = client.post(
        "/api/v1/npcs/generate", json={}, headers=bearer(login.json()["accessToken"])
    )

    assert response.status_code == 503
    assert response.json()["code"] == ErrorCode.AI_UNAVAILABLE.name


def test_models_match_the_migrations(database_url: str) -> None:
    # Falha se um modelo do SQLAlchemy mudou sem uma migração nova.
    command.check(alembic_config(database_url))


@pytest.mark.anyio
async def test_monsters_are_imported(database_url: str) -> None:
    engine = create_engine(database_url)
    try:
        async with create_session_factory(engine)() as session:
            repository = MonsterRepository(session)

            found = await repository.find_by_indexes(["aboleth", "giant-rat", "nao-existe"])
            assert set(found) == {"aboleth", "giant-rat"}
            assert found["giant-rat"].challenge_rating == Decimal("0.125")
            assert found["giant-rat"].xp == 25
            assert found["aboleth"].xp == 5_900

            cheap = await repository.list_up_to_xp(25)
            assert cheap
            assert all(monster.xp <= 25 for monster in cheap)
            assert [m.xp for m in cheap] == sorted((m.xp for m in cheap), reverse=True)
            assert len(await repository.list_up_to_xp(1_000_000)) == 334
    finally:
        await engine.dispose()


@pytest.fixture
def anyio_backend() -> str:
    return "asyncio"
