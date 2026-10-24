from fastapi import FastAPI
from fastapi.testclient import TestClient

from critsense.errors import ErrorCode


def test_unknown_route_is_problem_json(client: TestClient) -> None:
    response = client.get("/api/v1/nao-existe")

    assert response.status_code == 404
    assert response.headers["content-type"] == "application/problem+json"
    assert response.json() == {
        "type": "urn:critsense:problem:not-found",
        "title": "Recurso não encontrado",
        "status": 404,
        "detail": "Not Found",
        "code": "NOT_FOUND",
    }


def test_wrong_method(client: TestClient) -> None:
    response = client.get("/api/v1/auth/login")

    assert response.status_code == 405
    assert response.json()["code"] == ErrorCode.METHOD_NOT_ALLOWED.name


def test_malformed_json(client: TestClient) -> None:
    response = client.post(
        "/api/v1/auth/login",
        content=b"{nao e json",
        headers={"Content-Type": "application/json"},
    )

    assert response.status_code == 400
    assert response.json()["code"] == ErrorCode.MALFORMED_REQUEST.name


def test_unexpected_error_hides_details(app: FastAPI) -> None:
    @app.get("/boom")
    async def boom() -> None:
        raise RuntimeError("segredo interno")

    with TestClient(app, raise_server_exceptions=False) as client:
        response = client.get("/boom")

    assert response.status_code == 500
    assert response.json()["code"] == ErrorCode.INTERNAL_ERROR.name
    assert "segredo" not in response.text


def test_health(client: TestClient) -> None:
    assert client.get("/health").json() == {"status": "UP"}
