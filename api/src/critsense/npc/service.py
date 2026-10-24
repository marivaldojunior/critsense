"""Gera NPCs com a IA, respeitando as preferências do pedido."""

from critsense.ai.prompts import PromptId
from critsense.ai.structured import StructuredAiService
from critsense.npc.schemas import Npc, NpcRequest, NpcResponse

FREE_CHOICE = "livre"


class NpcService:
    def __init__(self, ai: StructuredAiService) -> None:
        self._ai = ai

    async def generate(self, request: NpcRequest) -> NpcResponse:
        variables = {
            "race": request.race or FREE_CHOICE,
            "role": _or_free(request.role),
            "alignment": request.alignment or FREE_CHOICE,
            "context": _or_free(request.context),
        }
        npc = await self._ai.generate(
            PromptId.NPC_GENERATOR,
            variables,
            Npc,
            lambda generated: matches_request(request, generated),
        )
        return NpcResponse(npc=npc, prompt_version=PromptId.NPC_GENERATOR.label)


def matches_request(request: NpcRequest, npc: Npc) -> list[str]:
    """A raça e a tendência pedidas são obrigatórias na resposta; o resto é sugestão."""
    errors = []
    if request.race and npc.race != request.race:
        errors.append(f"race: o pedido exige {request.race}")
    if request.alignment and npc.alignment != request.alignment:
        errors.append(f"alignment: o pedido exige {request.alignment}")
    return errors


def _or_free(value: str | None) -> str:
    return value.strip() if value and value.strip() else FREE_CHOICE
