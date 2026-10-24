"""Gera um modelo Pydantic a partir de um prompt versionado, com saída sempre validada.

1. O prompt recebe o JSON Schema do tipo pedido.
2. A resposta é validada com o Pydantic e com as regras extras de quem chama.
3. Se a resposta for inválida, o modelo recebe a lista de erros e tem mais uma tentativa.
4. Se ainda for inválida, a API devolve ``AI_INVALID_OUTPUT`` (502), nunca um JSON inválido.

Sem provedor configurado, os endpoints de IA devolvem ``AI_UNAVAILABLE`` (503) e o resto da API
continua funcionando.
"""

import json
import logging
import re
from collections.abc import Callable
from functools import partial

from pydantic import BaseModel, ValidationError

from critsense.ai.chat import ChatMessage, ChatModel, ChatResult
from critsense.ai.gateway import AiGateway
from critsense.ai.prompts import PromptCatalog, PromptId
from critsense.errors import ApiError, ErrorCode

log = logging.getLogger(__name__)

# Uma chamada e uma nova tentativa com a lista de erros.
MAX_ATTEMPTS = 2

_CODE_FENCE = re.compile(r"^\s*```(?:json)?\s*(.*?)\s*```\s*$", re.DOTALL)


def format_instructions(schema: dict[str, object]) -> str:
    return (
        "Responda só com um objeto JSON que siga este JSON Schema, sem texto antes ou depois "
        "e sem blocos de código Markdown.\n"
        f"```json\n{json.dumps(schema, ensure_ascii=False, indent=2)}\n```"
    )


class StructuredAiService:
    def __init__(
        self, chat_model: ChatModel | None, prompts: PromptCatalog, gateway: AiGateway
    ) -> None:
        self._chat_model = chat_model
        self._prompts = prompts
        self._gateway = gateway

    async def generate[T: BaseModel](
        self,
        prompt_id: PromptId,
        variables: dict[str, str],
        output_type: type[T],
        extra_checks: Callable[[T], list[str]] = lambda _: [],
    ) -> T:
        """
        :param variables: variáveis do ``user.txt``; a variável ``format`` é preenchida aqui.
        :param output_type: tipo da resposta, que define o JSON Schema.
        :param extra_checks: regras de negócio além do Pydantic; devolve a lista de erros (vazia
            quando a resposta é válida).
        """
        model = self._chat_model
        if model is None:
            raise ApiError(
                ErrorCode.AI_UNAVAILABLE, "Nenhum provedor de IA está configurado na API."
            )

        schema = output_type.model_json_schema(by_alias=True)
        system = self._prompts.system(prompt_id)
        user = self._prompts.user(prompt_id, {**variables, "format": format_instructions(schema)})
        messages = [ChatMessage("user", user)]

        for attempt in range(1, MAX_ATTEMPTS + 1):
            # Cópia da lista: a próxima tentativa acrescenta mensagens a ela.
            history = list(messages)
            result = await self._gateway.call(
                prompt_id.label, partial(model.complete, system, history)
            )
            text = _text_of(result, prompt_id)

            value, errors = _parse(text, output_type, extra_checks)
            if value is not None:
                log.info("%s gerado na tentativa %d", prompt_id.label, attempt)
                return value

            log.warning(
                "%s: resposta inválida na tentativa %d: %s", prompt_id.label, attempt, errors
            )
            messages += [
                ChatMessage("assistant", text),
                ChatMessage("user", _retry_instruction(errors)),
            ]

        raise ApiError(
            ErrorCode.AI_INVALID_OUTPUT,
            f"A IA não devolveu uma resposta válida depois de {MAX_ATTEMPTS} tentativas.",
        )


def _text_of(result: ChatResult, prompt_id: PromptId) -> str:
    if result.refused:
        log.info("%s: pedido recusado pelo modelo", prompt_id.label)
        raise ApiError(
            ErrorCode.AI_REFUSED,
            "A IA recusou este pedido. Mude o texto do pedido e tente de novo.",
        )
    return result.text


def _parse[T: BaseModel](
    text: str, output_type: type[T], extra_checks: Callable[[T], list[str]]
) -> tuple[T | None, list[str]]:
    if not text.strip():
        return None, ["a resposta veio vazia"]
    if match := _CODE_FENCE.match(text):
        text = match.group(1)
    try:
        value = output_type.model_validate_json(text)
    except ValidationError as e:
        if any(error["type"] == "json_invalid" for error in e.errors()):
            return None, ["a resposta não é um JSON válido para o schema pedido"]
        return None, [
            f"{'.'.join(str(part) for part in error['loc'])}: {error['msg']}"
            for error in e.errors()
        ]
    errors = extra_checks(value)
    return (None, errors) if errors else (value, [])


def _retry_instruction(errors: list[str]) -> str:
    return (
        "A resposta anterior tem estes problemas:\n- "
        + "\n- ".join(errors)
        + "\nResponda de novo só com o JSON corrigido, seguindo o mesmo schema."
    )
