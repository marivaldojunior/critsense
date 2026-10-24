import json

import pytest
from fastapi.testclient import TestClient

from critsense.errors import ErrorCode
from critsense.npc.schemas import Alignment, Npc, NpcRequest, SrdRace
from critsense.npc.service import matches_request
from critsense.ratelimit import REMAINING_HEADER

from .conftest import FakeChatModel, bearer, register
from .npc_fixtures import npc_json

URL = "/api/v1/npcs/generate"


def test_generates_npc(client: TestClient, fake_model: FakeChatModel) -> None:
    token = register(client)
    fake_model.reply(npc_json())

    response = client.post(
        URL, json={"race": "DWARF", "role": "  ferreira  "}, headers=bearer(token)
    )

    assert response.status_code == 200, response.text
    body = response.json()
    assert body["promptVersion"] == "npc-generator@v1"
    assert body["npc"]["personalityTraits"] == ["Teimosa", "Generosa com quem trabalha duro"]
    assert response.headers[REMAINING_HEADER] == "2"
    user_prompt = fake_model.calls[0][1][0].content
    assert "- Papel: ferreira\n" in user_prompt
    assert "- Tendência: livre" in user_prompt


def test_retries_when_race_does_not_match(client: TestClient, fake_model: FakeChatModel) -> None:
    token = register(client)
    fake_model.reply(npc_json(race="ELF")).reply(npc_json())

    response = client.post(URL, json={"race": "DWARF"}, headers=bearer(token))

    assert response.status_code == 200
    assert response.json()["npc"]["race"] == "DWARF"
    assert len(fake_model.calls) == 2


def test_requires_token(client: TestClient, fake_model: FakeChatModel) -> None:
    response = client.post(URL, json={})

    assert response.status_code == 401
    assert fake_model.calls == []


def test_validates_request(client: TestClient) -> None:
    token = register(client)

    response = client.post(URL, json={"race": "ORC", "role": "x" * 61}, headers=bearer(token))

    assert response.status_code == 400
    fields = {error["field"] for error in response.json()["errors"]}
    assert fields == {"race", "role"}


def test_rate_limit(client: TestClient, fake_model: FakeChatModel) -> None:
    token = register(client)
    for _ in range(3):
        fake_model.reply(npc_json())
        assert client.post(URL, json={}, headers=bearer(token)).status_code == 200

    response = client.post(URL, json={}, headers=bearer(token))

    assert response.status_code == 429
    assert response.json()["code"] == ErrorCode.RATE_LIMITED.name
    assert int(response.headers["Retry-After"]) >= 1


@pytest.mark.parametrize(
    ("prepare", "status", "code"),
    [
        (lambda m: m.refuse(), 422, ErrorCode.AI_REFUSED),
        (lambda m: m.reply("{}").reply("{}"), 502, ErrorCode.AI_INVALID_OUTPUT),
        (lambda m: m.fail(TimeoutError()), 504, ErrorCode.AI_TIMEOUT),
    ],
    ids=["recusa", "json-invalido", "timeout"],
)
def test_ai_errors(
    client: TestClient,
    fake_model: FakeChatModel,
    prepare: object,
    status: int,
    code: ErrorCode,
) -> None:
    token = register(client)
    prepare(fake_model)  # type: ignore[operator]

    response = client.post(URL, json={}, headers=bearer(token))

    assert response.status_code == status
    assert response.json()["code"] == code.name


def test_matches_request() -> None:
    npc = Npc.model_validate_json(npc_json())
    assert matches_request(NpcRequest(), npc) == []
    assert matches_request(NpcRequest(race=SrdRace.DWARF), npc) == []
    assert matches_request(NpcRequest(race=SrdRace.ELF, alignment=Alignment.CHAOTIC_EVIL), npc) == [
        "race: o pedido exige ELF",
        "alignment: o pedido exige CHAOTIC_EVIL",
    ]


def test_npc_schema_uses_camel_case() -> None:
    schema = json.dumps(Npc.model_json_schema(by_alias=True))
    assert '"storyHooks"' in schema
    assert "story_hooks" not in schema
