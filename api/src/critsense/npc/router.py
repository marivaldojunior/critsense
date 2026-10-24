from typing import Annotated

from fastapi import APIRouter, Depends, Request

from critsense.npc.schemas import NpcRequest, NpcResponse
from critsense.npc.service import NpcService
from critsense.ratelimit import AiRateLimited

router = APIRouter(prefix="/api/v1/npcs", tags=["NPCs"])


def get_npc_service(request: Request) -> NpcService:
    return NpcService(request.app.state.structured_ai)


@router.post(
    "/generate",
    operation_id="generateNpc",
    summary="Gera um NPC com a IA",
    description=(
        "Conta no limite de chamadas de IA do usuário (cabeçalho X-RateLimit-Remaining)."
        " Erros: 429 RATE_LIMITED, 422 AI_REFUSED, 502 AI_INVALID_OUTPUT ou"
        " AI_PROVIDER_ERROR, 503 AI_UNAVAILABLE, 504 AI_TIMEOUT."
    ),
)
async def generate(
    request: NpcRequest,
    _: AiRateLimited,
    service: Annotated[NpcService, Depends(get_npc_service)],
) -> NpcResponse:
    return await service.generate(request)
