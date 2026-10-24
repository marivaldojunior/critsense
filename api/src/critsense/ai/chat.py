"""Modelos de chat: uma interface pequena e um adaptador por provedor.

O resto da API só conhece ``ChatModel``. Os testes usam um modelo falso, então nenhum teste chama
um provedor real.
"""

from dataclasses import dataclass
from typing import Literal, Protocol

import anthropic
import openai
from anthropic.types.beta import BetaMessageParam
from openai.types.chat import ChatCompletionMessageParam

from critsense.config import Settings


@dataclass(frozen=True, slots=True)
class ChatMessage:
    role: Literal["user", "assistant"]
    content: str


@dataclass(frozen=True, slots=True)
class ChatResult:
    text: str
    refused: bool = False


class ProviderError(Exception):
    """Falha do provedor de IA que não é um tempo esgotado."""


class ChatModel(Protocol):
    async def complete(self, system: str, messages: list[ChatMessage]) -> ChatResult:
        """Lança ``TimeoutError`` quando o provedor demora demais e ``ProviderError`` nas outras
        falhas do provedor."""
        ...


class AnthropicChatModel:
    # O raciocínio do modelo conta dentro deste limite, então ele fica bem acima do tamanho
    # da resposta em JSON.
    MAX_TOKENS = 16_000
    # Com "default", a API refaz no próprio servidor um pedido recusado pelos classificadores
    # de segurança, num modelo escolhido pela categoria da recusa.
    FALLBACK_BETA = "server-side-fallback-2026-07-01"

    def __init__(self, client: anthropic.AsyncAnthropic, model: str) -> None:
        self._client = client
        self._model = model

    async def complete(self, system: str, messages: list[ChatMessage]) -> ChatResult:
        history: list[BetaMessageParam] = []
        for m in messages:
            if m.role == "user":
                history.append({"role": "user", "content": m.content})
            else:
                history.append({"role": "assistant", "content": m.content})
        try:
            response = await self._client.beta.messages.create(
                model=self._model,
                max_tokens=self.MAX_TOKENS,
                system=system,
                messages=history,
                output_config={"effort": "medium"},
                betas=[self.FALLBACK_BETA],
                fallbacks="default",
            )
        except anthropic.APITimeoutError as e:
            raise TimeoutError from e
        except anthropic.APIError as e:
            raise ProviderError(str(e)) from e
        if response.stop_reason == "refusal":
            return ChatResult("", refused=True)
        text = "".join(block.text for block in response.content if block.type == "text")
        return ChatResult(text)


class OpenAIChatModel:
    def __init__(self, client: openai.AsyncOpenAI, model: str) -> None:
        self._client = client
        self._model = model

    async def complete(self, system: str, messages: list[ChatMessage]) -> ChatResult:
        history: list[ChatCompletionMessageParam] = [{"role": "system", "content": system}]
        for m in messages:
            if m.role == "user":
                history.append({"role": "user", "content": m.content})
            else:
                history.append({"role": "assistant", "content": m.content})
        try:
            response = await self._client.chat.completions.create(
                model=self._model, messages=history
            )
        except openai.APITimeoutError as e:
            raise TimeoutError from e
        except openai.APIError as e:
            raise ProviderError(str(e)) from e
        message = response.choices[0].message
        if message.refusal:
            return ChatResult("", refused=True)
        return ChatResult(message.content or "")


def build_chat_model(settings: Settings) -> ChatModel | None:
    """Cria o modelo do provedor em ``AI_PROVIDER``. Sem provedor ou sem chave, devolve ``None``
    e os endpoints de IA respondem 503."""
    timeout = settings.ai_provider_timeout.total_seconds()
    if settings.ai_provider == "anthropic" and settings.anthropic_api_key:
        return AnthropicChatModel(
            anthropic.AsyncAnthropic(
                api_key=settings.anthropic_api_key.get_secret_value(),
                timeout=timeout,
                max_retries=1,
            ),
            settings.anthropic_model,
        )
    if settings.ai_provider == "openai" and settings.openai_api_key:
        return OpenAIChatModel(
            openai.AsyncOpenAI(
                api_key=settings.openai_api_key.get_secret_value(),
                timeout=timeout,
                max_retries=1,
            ),
            settings.openai_model,
        )
    return None
