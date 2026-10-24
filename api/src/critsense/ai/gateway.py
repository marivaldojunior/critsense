"""Ponto único por onde passa toda chamada ao provedor de IA.

Aplica o tempo máximo de ``AI_TIMEOUT`` e troca as falhas do provedor pelos erros da API:

- tempo esgotado (do lado da API ou do cliente HTTP do provedor): ``AI_TIMEOUT`` (504);
- qualquer outra falha do provedor: ``AI_PROVIDER_ERROR`` (502).

Um ``ApiError`` lançado dentro da chamada passa sem mudança.
"""

import asyncio
import logging
from collections.abc import Awaitable, Callable
from datetime import timedelta

from critsense.errors import ApiError, ErrorCode

log = logging.getLogger(__name__)


class AiGateway:
    def __init__(self, timeout: timedelta) -> None:
        self._timeout = timeout

    async def call[T](self, operation: str, call: Callable[[], Awaitable[T]]) -> T:
        try:
            async with asyncio.timeout(self._timeout.total_seconds()):
                return await call()
        except ApiError:
            raise
        except TimeoutError as e:
            log.warning("Tempo esgotado em %s (limite de %s)", operation, self._timeout)
            seconds = int(self._timeout.total_seconds())
            raise ApiError(
                ErrorCode.AI_TIMEOUT, f"A IA demorou mais que {seconds} s para responder."
            ) from e
        except Exception as e:
            log.warning("Falha do provedor de IA em %s", operation, exc_info=e)
            raise ApiError(
                ErrorCode.AI_PROVIDER_ERROR,
                "O provedor de IA falhou. Tente de novo em alguns instantes.",
            ) from e
