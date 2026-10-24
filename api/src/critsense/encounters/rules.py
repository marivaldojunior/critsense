"""Dificuldade de encontros de combate, sem IA e sem banco.

As regras seguem a seção "Combat Encounter Difficulty" do SRD 5.2.1. O SRD 5.1 não tem regras de
dificuldade de encontro, só a tabela de XP por CR. Os monstros continuam vindo do SRD 5.1.

1. A dificuldade é Baixa, Moderada ou Alta.
2. O orçamento de XP é o valor da tabela "XP Budget per Character" para o nível de cada
   personagem, somado para o grupo todo. Com todos no mesmo nível, isso é o valor da tabela vezes o
   número de personagens, como o SRD descreve.
3. Os monstros gastam o orçamento pelo XP do bloco de estatísticas, sem multiplicador pelo número
   de monstros.

This work includes material from the System Reference Document 5.2.1 ("SRD 5.2.1") by Wizards of
the Coast LLC, available at https://www.dndbeyond.com/srd. The SRD 5.2.1 is licensed under the
Creative Commons Attribution 4.0 International License, available at
https://creativecommons.org/licenses/by/4.0/legalcode.
"""

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from enum import StrEnum
from fractions import Fraction

MIN_LEVEL = 1
MAX_LEVEL = 20


class Difficulty(StrEnum):
    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"


class EncounterRating(StrEnum):
    """Dificuldade de um encontro pronto. ``BEYOND_HIGH`` passa do orçamento de Alta."""

    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"
    BEYOND_HIGH = "BEYOND_HIGH"


# Tabela "XP Budget per Character" do SRD 5.2.1: nível -> (Baixa, Moderada, Alta).
_BUDGET_ROWS: dict[int, tuple[int, int, int]] = {
    1: (50, 75, 100),
    2: (100, 150, 200),
    3: (150, 225, 400),
    4: (250, 375, 500),
    5: (500, 750, 1_100),
    6: (600, 1_000, 1_400),
    7: (750, 1_300, 1_700),
    8: (1_000, 1_700, 2_100),
    9: (1_300, 2_000, 2_600),
    10: (1_600, 2_300, 3_100),
    11: (1_900, 2_900, 4_100),
    12: (2_200, 3_700, 4_700),
    13: (2_600, 4_200, 5_400),
    14: (2_900, 4_900, 6_200),
    15: (3_300, 5_400, 7_800),
    16: (3_800, 6_100, 9_800),
    17: (4_500, 7_200, 11_700),
    18: (5_000, 8_700, 14_200),
    19: (5_500, 10_700, 17_200),
    20: (6_400, 13_200, 22_000),
}

XP_BUDGET_PER_CHARACTER: Mapping[int, Mapping[Difficulty, int]] = {
    level: dict(zip(Difficulty, row, strict=True)) for level, row in _BUDGET_ROWS.items()
}

# Tabela "Experience Points by Challenge Rating" (igual no SRD 5.1 e no SRD 5.2.1). Um monstro de
# CR 0 vale 10 XP, ou 0 XP quando não tem ataques eficazes.
XP_BY_CHALLENGE_RATING: Mapping[Fraction, int] = {
    Fraction(0): 10,
    Fraction(1, 8): 25,
    Fraction(1, 4): 50,
    Fraction(1, 2): 100,
    **{
        Fraction(cr): xp
        for cr, xp in {
            1: 200, 2: 450, 3: 700, 4: 1_100, 5: 1_800, 6: 2_300, 7: 2_900, 8: 3_900,
            9: 5_000, 10: 5_900, 11: 7_200, 12: 8_400, 13: 10_000, 14: 11_500, 15: 13_000,
            16: 15_000, 17: 18_000, 18: 20_000, 19: 22_000, 20: 25_000, 21: 33_000,
            22: 41_000, 23: 50_000, 24: 62_000, 25: 75_000, 26: 90_000, 27: 105_000,
            28: 120_000, 29: 135_000, 30: 155_000,
        }.items()
    },
}  # fmt: skip


def xp_for_challenge_rating(challenge_rating: Fraction) -> int:
    try:
        return XP_BY_CHALLENGE_RATING[challenge_rating]
    except KeyError:
        raise ValueError(f"CR inválido: {challenge_rating}") from None


def _check_levels(levels: Iterable[int]) -> list[int]:
    party = list(levels)
    if not party:
        raise ValueError("O grupo precisa de pelo menos um personagem.")
    invalid = [level for level in party if not MIN_LEVEL <= level <= MAX_LEVEL]
    if invalid:
        raise ValueError(f"Níveis fora de {MIN_LEVEL}-{MAX_LEVEL}: {invalid}")
    return party


def xp_budget(levels: Iterable[int], difficulty: Difficulty) -> int:
    """Orçamento de XP do grupo, com um nível por personagem."""
    return sum(XP_BUDGET_PER_CHARACTER[level][difficulty] for level in _check_levels(levels))


@dataclass(frozen=True, slots=True)
class EncounterAssessment:
    total_xp: int
    budgets: Mapping[Difficulty, int]
    rating: EncounterRating


def assess_encounter(levels: Iterable[int], monster_xp: Iterable[int]) -> EncounterAssessment:
    """Classifica um encontro pela menor dificuldade cujo orçamento cobre o XP dos monstros.

    O SRD manda gastar o orçamento "sem passar dele", então um encontro com XP igual ao orçamento
    de Moderada ainda é Moderado. Um encontro acima do orçamento de Alta é ``BEYOND_HIGH``.
    """
    party = _check_levels(levels)
    xp_values = list(monster_xp)
    if any(xp < 0 for xp in xp_values):
        raise ValueError("O XP de um monstro não pode ser negativo.")
    total = sum(xp_values)
    budgets = {difficulty: xp_budget(party, difficulty) for difficulty in Difficulty}
    rating = next(
        (EncounterRating(d) for d in Difficulty if total <= budgets[d]),
        EncounterRating.BEYOND_HIGH,
    )
    return EncounterAssessment(total, budgets, rating)
