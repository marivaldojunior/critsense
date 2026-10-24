"""Adaptadores dos provedores, com clientes falsos no lugar dos SDKs (sem rede)."""

from datetime import timedelta
from types import SimpleNamespace
from typing import Any

import anthropic
import httpx2
import openai
import pytest
from pydantic import SecretStr

from critsense.ai.chat import (
    AnthropicChatModel,
    ChatMessage,
    OpenAIChatModel,
    ProviderError,
    build_chat_model,
)
from critsense.config import parse_duration

from .conftest import make_settings

pytestmark = pytest.mark.anyio

REQUEST = httpx2.Request("POST", "https://api.example.com")
MESSAGES = [
    ChatMessage("user", "oi"),
    ChatMessage("assistant", "{}"),
    ChatMessage("user", "de novo"),
]


@pytest.fixture
def anyio_backend() -> str:
    return "asyncio"


class FakeCreate:
    def __init__(self, result: object) -> None:
        self.result = result
        self.kwargs: dict[str, Any] = {}

    async def __call__(self, **kwargs: Any) -> object:
        self.kwargs = kwargs
        if isinstance(self.result, Exception):
            raise self.result
        return self.result


def anthropic_client(result: object) -> tuple[Any, FakeCreate]:
    create = FakeCreate(result)
    return SimpleNamespace(beta=SimpleNamespace(messages=SimpleNamespace(create=create))), create


def openai_client(result: object) -> tuple[Any, FakeCreate]:
    create = FakeCreate(result)
    return SimpleNamespace(chat=SimpleNamespace(completions=SimpleNamespace(create=create))), create


async def test_anthropic_joins_text_blocks_and_sends_fallbacks() -> None:
    response = SimpleNamespace(
        stop_reason="end_turn",
        content=[
            SimpleNamespace(type="thinking", thinking=""),
            SimpleNamespace(type="text", text='{"a":'),
            SimpleNamespace(type="text", text=" 1}"),
        ],
    )
    client, create = anthropic_client(response)

    result = await AnthropicChatModel(client, "claude-opus-5-5").complete("sistema", MESSAGES)

    assert result.text == '{"a": 1}'
    assert not result.refused
    assert create.kwargs["system"] == "sistema"
    assert [m["role"] for m in create.kwargs["messages"]] == ["user", "assistant", "user"]
    assert create.kwargs["fallbacks"] == "default"
    assert create.kwargs["betas"] == ["server-side-fallback-2026-07-01"]


async def test_anthropic_refusal() -> None:
    client, _ = anthropic_client(SimpleNamespace(stop_reason="refusal", content=[]))

    result = await AnthropicChatModel(client, "claude-opus-5-5").complete("s", MESSAGES)

    assert result.refused


@pytest.mark.parametrize(
    ("error", "expected"),
    [
        (anthropic.APITimeoutError(request=REQUEST), TimeoutError),
        (anthropic.APIConnectionError(request=REQUEST), ProviderError),
    ],
)
async def test_anthropic_errors(error: Exception, expected: type[Exception]) -> None:
    client, _ = anthropic_client(error)

    with pytest.raises(expected):
        await AnthropicChatModel(client, "claude-opus-5-5").complete("s", MESSAGES)


async def test_openai_text_and_refusal() -> None:
    def response(content: str | None, refusal: str | None) -> object:
        message = SimpleNamespace(content=content, refusal=refusal)
        return SimpleNamespace(choices=[SimpleNamespace(message=message)])

    client, create = openai_client(response("{}", None))
    result = await OpenAIChatModel(client, "gpt").complete("sistema", MESSAGES)
    assert result.text == "{}"
    assert create.kwargs["messages"][0] == {"role": "system", "content": "sistema"}

    client, _ = openai_client(response(None, "não posso"))
    assert (await OpenAIChatModel(client, "gpt").complete("s", MESSAGES)).refused


async def test_openai_timeout() -> None:
    client, _ = openai_client(openai.APITimeoutError(request=SimpleNamespace()))  # type: ignore[arg-type]

    with pytest.raises(TimeoutError):
        await OpenAIChatModel(client, "gpt").complete("s", MESSAGES)


def test_build_chat_model_needs_provider_and_key() -> None:
    assert build_chat_model(make_settings(ai_provider="anthropic")) is None
    assert build_chat_model(make_settings(ai_provider="none")) is None
    model = build_chat_model(
        make_settings(ai_provider="anthropic", anthropic_api_key=SecretStr("chave"))
    )
    assert isinstance(model, AnthropicChatModel)
    model = build_chat_model(make_settings(ai_provider="openai", openai_api_key=SecretStr("chave")))
    assert isinstance(model, OpenAIChatModel)


@pytest.mark.parametrize(
    ("value", "expected"),
    [
        ("120s", timedelta(seconds=120)),
        ("5m", timedelta(minutes=5)),
        ("24h", timedelta(hours=24)),
        ("1d", timedelta(days=1)),
        ("500ms", timedelta(milliseconds=500)),
        ("90", timedelta(seconds=90)),
        (30, timedelta(seconds=30)),
    ],
)
def test_parse_duration(value: object, expected: timedelta) -> None:
    assert parse_duration(value) == expected
