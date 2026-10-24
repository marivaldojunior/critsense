"""Corpos de requisição e de resposta do gerador de NPCs."""

from enum import StrEnum
from typing import Annotated

from pydantic import Field, StringConstraints

from critsense.schemas import CamelModel


class SrdRace(StrEnum):
    """Raças jogáveis do SRD 5.1 (CC-BY-4.0). A API só aceita e só devolve estas."""

    DRAGONBORN = "DRAGONBORN"
    DWARF = "DWARF"
    ELF = "ELF"
    GNOME = "GNOME"
    HALF_ELF = "HALF_ELF"
    HALF_ORC = "HALF_ORC"
    HALFLING = "HALFLING"
    HUMAN = "HUMAN"
    TIEFLING = "TIEFLING"


class Alignment(StrEnum):
    """As nove tendências do SRD 5.1."""

    LAWFUL_GOOD = "LAWFUL_GOOD"
    NEUTRAL_GOOD = "NEUTRAL_GOOD"
    CHAOTIC_GOOD = "CHAOTIC_GOOD"
    LAWFUL_NEUTRAL = "LAWFUL_NEUTRAL"
    TRUE_NEUTRAL = "TRUE_NEUTRAL"
    CHAOTIC_NEUTRAL = "CHAOTIC_NEUTRAL"
    LAWFUL_EVIL = "LAWFUL_EVIL"
    NEUTRAL_EVIL = "NEUTRAL_EVIL"
    CHAOTIC_EVIL = "CHAOTIC_EVIL"


# Textos obrigatórios: sem espaços nas pontas, não vazios e com tamanho máximo.
Text80 = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=80)]
Text120 = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=120)]
Text200 = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=200)]
Text300 = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=300)]
Text400 = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=400)]


class NpcRequest(CamelModel):
    """Preferências do NPC. Todo campo é opcional: o que faltar, a IA escolhe."""

    race: Annotated[SrdRace | None, Field(description="Raça do NPC (SRD 5.1).")] = None
    role: Annotated[
        str | None,
        Field(max_length=60, description="Ocupação ou papel no mundo.", examples=["ferreiro"]),
    ] = None
    alignment: Alignment | None = None
    context: Annotated[
        str | None,
        Field(
            max_length=1000,
            description="Descrição livre da campanha ou da cena.",
            examples=["Uma vila mineira nas montanhas, ameaçada por kobolds."],
        ),
    ] = None


# Esta mesma classe define o JSON Schema enviado ao modelo, então as descrições e os limites aqui
# orientam a geração e são validados antes de a API responder.
class Npc(CamelModel):
    """NPC gerado."""

    name: Annotated[Text80, Field(description="Nome do NPC, coerente com a raça.")]
    race: SrdRace
    role: Annotated[Text80, Field(description="Ocupação ou papel no mundo.")]
    alignment: Alignment
    appearance: Annotated[Text400, Field(description="Aparência em uma ou duas frases.")]
    personality_traits: Annotated[
        list[Text120],
        Field(min_length=2, max_length=4, description="De 2 a 4 traços de personalidade curtos."),
    ]
    motivation: Annotated[Text300, Field(description="O que o NPC quer.")]
    secret: Annotated[Text300, Field(description="Algo que o NPC esconde.")]
    mannerism: Annotated[
        Text200, Field(description="Jeito de falar ou maneirismo para o mestre interpretar.")
    ]
    story_hooks: Annotated[
        list[Text300],
        Field(
            min_length=1,
            max_length=3,
            description="De 1 a 3 ganchos de aventura que envolvem o grupo.",
        ),
    ]


class NpcResponse(CamelModel):
    """NPC gerado e a versão do prompt usada."""

    npc: Npc
    prompt_version: Annotated[
        str, Field(description="Prompt que gerou este NPC.", examples=["npc-generator@v1"])
    ]
