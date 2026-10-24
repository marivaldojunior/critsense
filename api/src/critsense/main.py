"""Monta a aplicação FastAPI.

Rode com ``uvicorn --factory critsense.main:create_app``. A fábrica recebe as dependências externas
(configuração e modelo de chat) como parâmetros, então os testes trocam essas peças sem mocks
globais.
"""

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI

from critsense import health
from critsense.ai.chat import ChatModel, build_chat_model
from critsense.ai.gateway import AiGateway
from critsense.ai.prompts import PromptCatalog
from critsense.ai.structured import StructuredAiService
from critsense.auth import router as auth
from critsense.auth.service import PasswordHasher
from critsense.auth.tokens import TokenService
from critsense.config import Settings, get_settings
from critsense.db import create_engine, create_session_factory
from critsense.errors import register_error_handlers
from critsense.npc import router as npc
from critsense.openapi import build_openapi
from critsense.ratelimit import AiRateLimiter

_FROM_SETTINGS: Any = object()


def create_app(
    settings: Settings | None = None, chat_model: ChatModel | None = _FROM_SETTINGS
) -> FastAPI:
    """
    :param settings: configuração; sem ela, vem das variáveis de ambiente.
    :param chat_model: modelo de chat; sem ele, vem do provedor em ``AI_PROVIDER``. ``None``
        desliga a IA.
    """
    settings = settings or get_settings()
    logging.basicConfig(
        level=settings.log_level, format="%(asctime)s %(levelname)s %(name)s: %(message)s"
    )
    if chat_model is _FROM_SETTINGS:
        chat_model = build_chat_model(settings)

    engine = create_engine(settings.database_url)

    @asynccontextmanager
    async def lifespan(_: FastAPI) -> AsyncIterator[None]:
        yield
        await engine.dispose()

    app = FastAPI(title="CritSense API", version="v1", lifespan=lifespan)

    # Peças com estado, criadas uma vez por aplicação. As dependências de cada rota leem daqui.
    app.state.settings = settings
    app.state.engine = engine
    app.state.session_factory = create_session_factory(engine)
    app.state.password_hasher = PasswordHasher()
    app.state.token_service = TokenService(
        settings.jwt_secret.get_secret_value(), settings.jwt_ttl, settings.jwt_issuer
    )
    app.state.rate_limiter = AiRateLimiter(settings.ai_rate_limit_per_minute)
    app.state.structured_ai = StructuredAiService(
        chat_model, PromptCatalog(), AiGateway(settings.ai_timeout)
    )

    register_error_handlers(app)
    app.include_router(auth.router)
    app.include_router(npc.router)
    app.include_router(health.router)
    app.openapi = lambda: build_openapi(app)  # type: ignore[method-assign]
    return app
