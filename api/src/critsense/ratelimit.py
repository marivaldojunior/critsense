"""Limite de chamadas de IA por usuário, com um token bucket.

Cada usuário tem ``requests_per_minute`` fichas, repostas aos poucos ao longo de um minuto. Os
buckets ficam em memória e somem depois de 10 minutos sem uso. Com mais de uma instância da API, o
limite passa a valer por instância; um bucket compartilhado (ex: no Redis) resolve isso quando for
preciso.
"""

import math
import time
from collections.abc import Callable
from dataclasses import dataclass
from typing import Annotated

from fastapi import Depends, Request, Response

from critsense.auth.dependencies import CurrentUser
from critsense.errors import ApiError, ErrorCode

# Cabeçalho com as chamadas de IA que ainda restam no minuto.
REMAINING_HEADER = "X-RateLimit-Remaining"
IDLE_EXPIRY_SECONDS = 600.0


@dataclass(slots=True)
class _Bucket:
    tokens: float
    updated_at: float


class AiRateLimiter:
    def __init__(
        self, requests_per_minute: int, clock: Callable[[], float] = time.monotonic
    ) -> None:
        self._capacity = requests_per_minute
        self._refill_per_second = requests_per_minute / 60
        self._clock = clock
        self._buckets: dict[str, _Bucket] = {}
        self._last_cleanup = clock()

    def consume(self, user_id: str) -> int:
        """Gasta uma ficha de ``user_id`` e devolve quantas ainda restam.

        Lança ``ApiError`` com ``RATE_LIMITED`` e o cabeçalho ``Retry-After`` quando o usuário não
        tem mais fichas. O método não tem ``await``, então é atômico no event loop.
        """
        now = self._clock()
        self._cleanup(now)
        bucket = self._buckets.get(user_id)
        if bucket is None:
            bucket = self._buckets[user_id] = _Bucket(float(self._capacity), now)
        else:
            elapsed = now - bucket.updated_at
            bucket.tokens = min(self._capacity, bucket.tokens + elapsed * self._refill_per_second)
            bucket.updated_at = now

        if bucket.tokens >= 1:
            bucket.tokens -= 1
            return math.floor(bucket.tokens)

        retry_after = max(1, math.ceil((1 - bucket.tokens) / self._refill_per_second))
        raise ApiError(
            ErrorCode.RATE_LIMITED,
            f"Limite de {self._capacity} chamadas de IA por minuto atingido. "
            f"Tente de novo em {retry_after} s.",
            headers={"Retry-After": str(retry_after)},
        )

    def _cleanup(self, now: float) -> None:
        if now - self._last_cleanup < IDLE_EXPIRY_SECONDS:
            return
        self._last_cleanup = now
        idle = [key for key, b in self._buckets.items() if now - b.updated_at > IDLE_EXPIRY_SECONDS]
        for key in idle:
            del self._buckets[key]


def ai_rate_limited(request: Request, response: Response, user: CurrentUser) -> None:
    """Dependência dos endpoints que chamam a IA: cada chamada gasta uma ficha do usuário.

    A chave é o id do token, então o limite segue o usuário, não o IP.
    """
    limiter: AiRateLimiter = request.app.state.rate_limiter
    remaining = limiter.consume(str(user.user_id))
    response.headers[REMAINING_HEADER] = str(remaining)


AiRateLimited = Annotated[None, Depends(ai_rate_limited)]
