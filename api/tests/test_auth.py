import uuid
from datetime import UTC, datetime, timedelta

import jwt
import pytest
from fastapi.testclient import TestClient

from critsense.auth.models import User
from critsense.auth.tokens import TokenService
from critsense.errors import ErrorCode

from .conftest import PASSWORD, TEST_SECRET, InMemoryUserRepository, bearer, register


def test_register_returns_bearer_token(client: TestClient) -> None:
    response = client.post(
        "/api/v1/auth/register", json={"username": "Thorin", "password": PASSWORD}
    )

    assert response.status_code == 201
    body = response.json()
    assert body["tokenType"] == "Bearer"
    assert body["expiresIn"] == 24 * 3600
    assert body["accessToken"]


def test_register_normalizes_username(client: TestClient, users: InMemoryUserRepository) -> None:
    register(client, "Thorin")

    assert list(users.users) == ["thorin"]
    assert users.users["thorin"].password_hash != PASSWORD


def test_register_rejects_taken_username_in_any_case(client: TestClient) -> None:
    register(client, "thorin")

    response = client.post(
        "/api/v1/auth/register", json={"username": "THORIN", "password": PASSWORD}
    )

    assert response.status_code == 409
    assert response.json()["code"] == ErrorCode.USERNAME_TAKEN.name


@pytest.mark.parametrize(
    ("body", "field"),
    [
        ({"username": "ab", "password": PASSWORD}, "username"),
        ({"username": "com espaço", "password": PASSWORD}, "username"),
        ({"username": "thorin", "password": "curta"}, "password"),
        ({"password": PASSWORD}, "username"),
    ],
)
def test_register_validates_fields(client: TestClient, body: dict[str, str], field: str) -> None:
    response = client.post("/api/v1/auth/register", json=body)

    assert response.status_code == 400
    problem = response.json()
    assert problem["code"] == ErrorCode.VALIDATION_FAILED.name
    assert [error["field"] for error in problem["errors"]] == [field]


def test_login_with_right_password(client: TestClient) -> None:
    register(client, "thorin")

    response = client.post("/api/v1/auth/login", json={"username": "Thorin", "password": PASSWORD})

    assert response.status_code == 200
    assert response.json()["accessToken"]


@pytest.mark.parametrize("username", ["thorin", "ninguem"])
def test_login_errors_are_the_same_for_wrong_password_and_unknown_user(
    client: TestClient, username: str
) -> None:
    register(client, "thorin")

    response = client.post(
        "/api/v1/auth/login", json={"username": username, "password": "senha-errada"}
    )

    assert response.status_code == 401
    assert response.json()["code"] == ErrorCode.INVALID_CREDENTIALS.name


def test_me_returns_token_user(client: TestClient) -> None:
    token = register(client, "thorin")

    response = client.get("/api/v1/me", headers=bearer(token))

    assert response.status_code == 200
    body = response.json()
    assert body["username"] == "thorin"
    uuid.UUID(body["id"])


def test_me_without_token(client: TestClient) -> None:
    response = client.get("/api/v1/me")

    assert response.status_code == 401
    assert response.headers["content-type"] == "application/problem+json"
    assert response.json()["code"] == ErrorCode.UNAUTHORIZED.name


@pytest.mark.parametrize(
    "token",
    [
        "nao-e-um-jwt",
        # Assinado com outra chave.
        TokenService(
            "outra-chave-com-pelo-menos-32-caracteres", timedelta(hours=1), "critsense-api"
        )
        .issue(User(id=uuid.uuid4(), username="thorin"))
        .value,
        # Outro emissor.
        TokenService(TEST_SECRET, timedelta(hours=1), "outra-api")
        .issue(User(id=uuid.uuid4(), username="thorin"))
        .value,
        # Expirado há mais tempo que a folga do relógio.
        TokenService(
            TEST_SECRET,
            timedelta(hours=1),
            "critsense-api",
            clock=lambda: datetime.now(UTC) - timedelta(hours=2),
        )
        .issue(User(id=uuid.uuid4(), username="thorin"))
        .value,
        # Algoritmo "none".
        jwt.encode({"sub": str(uuid.uuid4()), "iss": "critsense-api"}, key=None, algorithm="none"),
    ],
    ids=["malformado", "outra-chave", "outro-emissor", "expirado", "sem-assinatura"],
)
def test_me_rejects_invalid_tokens(client: TestClient, token: str) -> None:
    response = client.get("/api/v1/me", headers=bearer(token))

    assert response.status_code == 401
    assert response.json()["code"] == ErrorCode.UNAUTHORIZED.name


def test_token_carries_user_claims() -> None:
    now = datetime(2026, 10, 24, 12, 0, tzinfo=UTC)
    service = TokenService(TEST_SECRET, timedelta(minutes=30), "critsense-api", clock=lambda: now)
    user = User(id=uuid.uuid4(), username="thorin")

    token = service.issue(user)
    claims = jwt.decode(
        token.value, TEST_SECRET, algorithms=["HS256"], options={"verify_exp": False}
    )

    assert token.expires_in_seconds == 1800
    assert claims["sub"] == str(user.id)
    assert claims["username"] == "thorin"
    assert claims["iss"] == "critsense-api"
    assert claims["exp"] - claims["iat"] == 1800
