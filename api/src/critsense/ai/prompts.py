"""Prompts versionados em ``critsense/prompts/<nome>/v<versão>/``.

Cada prompt tem um ``system.txt`` (regras fixas) e um ``user.txt`` (o pedido, com variáveis no
formato ``{variavel}``). Para mudar um prompt, crie uma versão nova em vez de editar a antiga:
assim o histórico mostra qual texto gerou cada resultado, e a troca de versão fica num único lugar
(``PromptId``).
"""

from enum import Enum
from functools import cache
from importlib.resources import files


class PromptId(Enum):
    """Prompts conhecidos e a versão em uso de cada um."""

    NPC_GENERATOR = ("npc-generator", 1)

    def __init__(self, prompt_name: str, version: int) -> None:
        self.prompt_name = prompt_name
        self.version = version

    @property
    def label(self) -> str:
        """Identificador legível da versão, ex: ``npc-generator@v1``."""
        return f"{self.prompt_name}@v{self.version}"


class PromptCatalog:
    def system(self, prompt_id: PromptId) -> str:
        return _load(prompt_id, "system.txt")

    def user(self, prompt_id: PromptId, variables: dict[str, str]) -> str:
        """Prompt do usuário com as variáveis substituídas."""
        return _load(prompt_id, "user.txt").format_map(variables)


@cache
def _load(prompt_id: PromptId, file: str) -> str:
    path = files("critsense") / "prompts" / prompt_id.prompt_name / f"v{prompt_id.version}" / file
    return path.read_text(encoding="utf-8")
