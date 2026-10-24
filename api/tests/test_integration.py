"""Testes com um PostgreSQL real (Testcontainers) e as migrações do Alembic.

Sem Docker, os testes são pulados. No CI, todos rodam.
"""

from collections.abc import Iterator
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient

from critsense.errors import ErrorCode
from critsense.main import create_app

from .conftest import PASSWORD, bearer, make_settings

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).resolve().parents[1]


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
        config = Config(API_DIR / "alembic.ini")
        config.set_main_option("sqlalchemy.url", url)
        config.attributes["configure_logger"] = False
        command.upgrade(config, "head")
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
