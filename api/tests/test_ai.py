import asyncio
from datetime import timedelta

import pytest

from critsense.ai.chat import ProviderError
from critsense.ai.gateway import AiGateway
from critsense.ai.prompts import PromptCatalog, PromptId
from critsense.ai.structured import MAX_ATTEMPTS, StructuredAiService
from critsense.errors import ApiError, ErrorCode
from critsense.npc.schemas import Npc

from .conftest import FakeChatModel
from .npc_fixtures import VARIABLES, npc_json

pytestmark = pytest.mark.anyio


@pytest.fixture
def anyio_backend() -> str:
    return "asyncio"


def service(model: FakeChatModel | None, timeout: float = 5) -> StructuredAiService:
    return StructuredAiService(model, PromptCatalog(), AiGateway(timedelta(seconds=timeout)))


# ── Prompts ──────────────────────────────────────────────────────────────


def test_prompt_label() -> None:
    assert PromptId.NPC_GENERATOR.label == "npc-generator@v1"


def test_prompt_renders_variables() -> None:
    catalog = PromptCatalog()

    user = catalog.user(PromptId.NPC_GENERATOR, {**VARIABLES, "format": "FORMATO"})

    assert "- Raça: DWARF" in user
    assert "<contexto>livre</contexto>" in user
    assert user.rstrip().endswith("FORMATO")
    assert "SRD 5.1" in catalog.system(PromptId.NPC_GENERATOR)


# ── Gateway ──────────────────────────────────────────────────────────────


async def test_gateway_timeout() -> None:
    async def slow() -> str:
        await asyncio.sleep(1)
        return "tarde demais"

    with pytest.raises(ApiError) as error:
        await AiGateway(timedelta(milliseconds=10)).call("teste", slow)

    assert error.value.code is ErrorCode.AI_TIMEOUT


@pytest.mark.parametrize(
    ("failure", "code"),
    [
        (TimeoutError(), ErrorCode.AI_TIMEOUT),
        (ProviderError("500"), ErrorCode.AI_PROVIDER_ERROR),
        (RuntimeError("inesperado"), ErrorCode.AI_PROVIDER_ERROR),
        (ApiError(ErrorCode.AI_REFUSED, "recusado"), ErrorCode.AI_REFUSED),
    ],
)
async def test_gateway_translates_failures(failure: Exception, code: ErrorCode) -> None:
    async def failing() -> str:
        raise failure

    with pytest.raises(ApiError) as error:
        await AiGateway(timedelta(seconds=1)).call("teste", failing)

    assert error.value.code is code


# ── Saída estruturada ────────────────────────────────────────────────────


async def test_valid_answer_on_first_attempt(fake_model: FakeChatModel) -> None:
    fake_model.reply(npc_json())

    npc = await service(fake_model).generate(PromptId.NPC_GENERATOR, VARIABLES, Npc)

    assert npc.name == "Brunna Martelo-Firme"
    system, messages = fake_model.calls[0]
    assert "SRD 5.1" in system
    # O prompt leva o JSON Schema do tipo pedido, com os nomes em camelCase.
    assert '"personalityTraits"' in messages[0].content


async def test_accepts_markdown_code_fence(fake_model: FakeChatModel) -> None:
    fake_model.reply(f"```json\n{npc_json()}\n```")

    npc = await service(fake_model).generate(PromptId.NPC_GENERATOR, VARIABLES, Npc)

    assert npc.race == "DWARF"


async def test_retries_with_the_list_of_errors(fake_model: FakeChatModel) -> None:
    fake_model.reply(npc_json(personalityTraits=["só um"])).reply(npc_json())

    npc = await service(fake_model).generate(PromptId.NPC_GENERATOR, VARIABLES, Npc)

    assert len(npc.personality_traits) == 2
    _, retry = fake_model.calls[1]
    assert [m.role for m in retry] == ["user", "assistant", "user"]
    assert "personalityTraits" in retry[2].content


async def test_extra_checks_count_as_errors(fake_model: FakeChatModel) -> None:
    fake_model.reply(npc_json(race="ELF")).reply(npc_json())

    npc = await service(fake_model).generate(
        PromptId.NPC_GENERATOR,
        VARIABLES,
        Npc,
        lambda generated: [] if generated.race == "DWARF" else ["race: o pedido exige DWARF"],
    )

    assert npc.race == "DWARF"
    assert "race: o pedido exige DWARF" in fake_model.calls[1][1][2].content


@pytest.mark.parametrize("answer", ["", "não é JSON", npc_json(name="")])
async def test_gives_up_after_max_attempts(fake_model: FakeChatModel, answer: str) -> None:
    for _ in range(MAX_ATTEMPTS):
        fake_model.reply(answer)

    with pytest.raises(ApiError) as error:
        await service(fake_model).generate(PromptId.NPC_GENERATOR, VARIABLES, Npc)

    assert error.value.code is ErrorCode.AI_INVALID_OUTPUT
    assert len(fake_model.calls) == MAX_ATTEMPTS


async def test_refusal(fake_model: FakeChatModel) -> None:
    fake_model.refuse()

    with pytest.raises(ApiError) as error:
        await service(fake_model).generate(PromptId.NPC_GENERATOR, VARIABLES, Npc)

    assert error.value.code is ErrorCode.AI_REFUSED


async def test_without_provider() -> None:
    with pytest.raises(ApiError) as error:
        await service(None).generate(PromptId.NPC_GENERATOR, VARIABLES, Npc)

    assert error.value.code is ErrorCode.AI_UNAVAILABLE
