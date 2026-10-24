"""Configuração da API, lida das variáveis de ambiente (e de um ``.env``, quando existe)."""

import re
from datetime import timedelta
from functools import cache
from typing import Annotated, Literal

from pydantic import BeforeValidator, Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict

_DURATION = re.compile(r"^\s*(\d+)\s*(ms|s|m|h|d)?\s*$")
_UNITS = {"ms": "milliseconds", "s": "seconds", "m": "minutes", "h": "hours", "d": "days"}


def parse_duration(value: object) -> object:
    """Aceita ``120s``, ``5m``, ``24h``, ``1d``, ``500ms`` ou um número de segundos."""
    if isinstance(value, int | float):
        return timedelta(seconds=value)
    if isinstance(value, str) and (match := _DURATION.match(value)):
        amount, unit = match.groups()
        return timedelta(**{_UNITS[unit or "s"]: int(amount)})
    return value


Duration = Annotated[timedelta, BeforeValidator(parse_duration)]

DEFAULT_DATABASE_URL = "postgresql+asyncpg://critsense:critsense@localhost:5432/critsense"


class Settings(BaseSettings):
    # O .env da raiz do repositório (o mesmo do Docker Compose) e, por cima, um .env em api/.
    model_config = SettingsConfigDict(env_file=("../.env", ".env"), extra="ignore")

    database_url: str = DEFAULT_DATABASE_URL

    # Sem valor padrão de propósito: a API não sobe sem JWT_SECRET.
    jwt_secret: SecretStr = Field(min_length=32)
    jwt_ttl: Duration = timedelta(hours=24)
    jwt_issuer: str = "critsense-api"

    # "none" desliga a IA: os endpoints de IA devolvem 503 e o resto funciona.
    ai_provider: Literal["anthropic", "openai", "none"] = "anthropic"
    anthropic_api_key: SecretStr | None = None
    anthropic_model: str = "claude-opus-5-5"
    openai_api_key: SecretStr | None = None
    openai_model: str = "gpt-5-mini"

    # Tempo máximo de uma chamada de IA, do lado da API. Acima disso, a API devolve 504.
    ai_timeout: Duration = timedelta(seconds=120)
    # Tempo máximo de cada requisição HTTP ao provedor (o SDK tenta mais uma vez).
    ai_provider_timeout: Duration = timedelta(seconds=90)
    ai_rate_limit_per_minute: int = Field(default=10, ge=1)

    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"] = "INFO"


@cache
def get_settings() -> Settings:
    return Settings()  # os valores vêm do ambiente
