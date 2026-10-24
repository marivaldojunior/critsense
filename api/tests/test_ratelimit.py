import pytest

from critsense.errors import ApiError, ErrorCode
from critsense.ratelimit import AiRateLimiter


class FakeClock:
    def __init__(self) -> None:
        self.now = 1000.0

    def __call__(self) -> float:
        return self.now


def test_consumes_until_limit_and_reports_retry_after() -> None:
    clock = FakeClock()
    limiter = AiRateLimiter(requests_per_minute=3, clock=clock)

    assert [limiter.consume("u1") for _ in range(3)] == [2, 1, 0]
    with pytest.raises(ApiError) as error:
        limiter.consume("u1")

    assert error.value.code is ErrorCode.RATE_LIMITED
    # Uma ficha volta a cada 20 s (3 por minuto).
    assert error.value.headers == {"Retry-After": "20"}


def test_tokens_refill_over_time() -> None:
    clock = FakeClock()
    limiter = AiRateLimiter(requests_per_minute=3, clock=clock)
    for _ in range(3):
        limiter.consume("u1")

    clock.now += 20
    assert limiter.consume("u1") == 0

    clock.now += 600
    assert limiter.consume("u1") == 2  # nunca passa da capacidade


def test_limit_is_per_user() -> None:
    limiter = AiRateLimiter(requests_per_minute=1, clock=FakeClock())
    limiter.consume("u1")

    assert limiter.consume("u2") == 0


def test_idle_buckets_are_removed() -> None:
    clock = FakeClock()
    limiter = AiRateLimiter(requests_per_minute=1, clock=clock)
    limiter.consume("u1")

    clock.now += 601
    limiter.consume("u2")

    assert set(limiter._buckets) == {"u2"}
