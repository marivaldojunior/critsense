"""Cálculo de dificuldade, com os exemplos e as tabelas do SRD 5.2.1.

Os exemplos vêm da seção "Combat Encounter Difficulty".
"""

import csv
from fractions import Fraction
from pathlib import Path

import pytest

from critsense.encounters.rules import (
    XP_BUDGET_PER_CHARACTER,
    Difficulty,
    EncounterRating,
    assess_encounter,
    xp_budget,
    xp_for_challenge_rating,
)

MONSTERS_CSV = Path(__file__).resolve().parents[1] / "migrations" / "data" / "srd_5_1_monsters.csv"

LOW, MODERATE, HIGH = Difficulty.LOW, Difficulty.MODERATE, Difficulty.HIGH


# ── Orçamento ────────────────────────────────────────────────────────────


@pytest.mark.parametrize(
    ("level", "low", "moderate", "high"),
    [
        (1, 50, 75, 100),
        (3, 150, 225, 400),
        (5, 500, 750, 1_100),
        (10, 1_600, 2_300, 3_100),
        (17, 4_500, 7_200, 11_700),
        (20, 6_400, 13_200, 22_000),
    ],
)
def test_budget_per_character_matches_the_srd_table(
    level: int, low: int, moderate: int, high: int
) -> None:
    assert xp_budget([level], LOW) == low
    assert xp_budget([level], MODERATE) == moderate
    assert xp_budget([level], HIGH) == high


def test_budget_table_covers_every_level_and_grows() -> None:
    assert sorted(XP_BUDGET_PER_CHARACTER) == list(range(1, 21))
    for row in XP_BUDGET_PER_CHARACTER.values():
        assert row[LOW] < row[MODERATE] < row[HIGH]
    for difficulty in Difficulty:
        values = [XP_BUDGET_PER_CHARACTER[level][difficulty] for level in range(1, 21)]
        assert values == sorted(values)


def test_srd_example_1_low_for_four_level_1_characters() -> None:
    # "A low-difficulty encounter for four level 1 characters has an XP budget of 50 x 4".
    assert xp_budget([1, 1, 1, 1], LOW) == 200


def test_srd_example_2_moderate_for_five_level_3_characters() -> None:
    # "A moderate-difficulty encounter for five level 3 characters has an XP budget of 225 x 5".
    assert xp_budget([3] * 5, MODERATE) == 1_125


def test_mixed_levels_add_each_character() -> None:
    assert xp_budget([1, 2, 3], HIGH) == 100 + 200 + 400


@pytest.mark.parametrize("levels", [[], [0], [21], [5, -1]])
def test_invalid_party(levels: list[int]) -> None:
    with pytest.raises(ValueError, match=r"grupo|Níveis"):
        xp_budget(levels, LOW)


# ── Classificação de um encontro pronto ──────────────────────────────────


@pytest.mark.parametrize(
    "monster_xp",
    [
        [200],  # 1 Bugbear Warrior
        [100, 100],  # 2 Giant Wasps
        [25] * 6,  # 6 Giant Rats
    ],
    ids=["bugbear", "vespas", "ratos"],
)
def test_srd_example_1_encounters_are_low(monster_xp: list[int]) -> None:
    assessment = assess_encounter([1] * 4, monster_xp)

    assert assessment.rating is EncounterRating.LOW
    assert assessment.budgets == {LOW: 200, MODERATE: 300, HIGH: 400}


@pytest.mark.parametrize(
    ("monster_xp", "total"),
    [
        ([450, 450, *[25] * 9], 1_125),  # 2 Druids e 9 Stirges
        ([700, 100, *[50] * 6], 1_100),  # 1 Wight, 1 Warhorse Skeleton e 6 Skeletons
    ],
    ids=["druidas", "wight"],
)
def test_srd_example_2_encounters_are_moderate(monster_xp: list[int], total: int) -> None:
    assessment = assess_encounter([3] * 5, monster_xp)

    assert assessment.total_xp == total
    assert assessment.rating is EncounterRating.MODERATE


@pytest.mark.parametrize(
    ("total", "rating"),
    [
        (0, EncounterRating.LOW),
        (200, EncounterRating.LOW),  # igual ao orçamento ainda cabe
        (201, EncounterRating.MODERATE),
        (300, EncounterRating.MODERATE),
        (301, EncounterRating.HIGH),
        (400, EncounterRating.HIGH),
        (401, EncounterRating.BEYOND_HIGH),
    ],
)
def test_rating_limits(total: int, rating: EncounterRating) -> None:
    assert assess_encounter([1] * 4, [total]).rating is rating


def test_negative_xp_is_invalid() -> None:
    with pytest.raises(ValueError, match="negativo"):
        assess_encounter([1], [-10])


# ── XP por CR e os dados importados ──────────────────────────────────────


@pytest.mark.parametrize(
    ("cr", "xp"),
    [(Fraction(0), 10), (Fraction(1, 8), 25), (Fraction(1, 2), 100), (Fraction(5), 1_800)],
)
def test_xp_for_challenge_rating(cr: Fraction, xp: int) -> None:
    assert xp_for_challenge_rating(cr) == xp


def test_unknown_challenge_rating() -> None:
    with pytest.raises(ValueError, match="CR"):
        xp_for_challenge_rating(Fraction(1, 3))


def test_imported_monsters_follow_the_xp_table() -> None:
    with MONSTERS_CSV.open(encoding="utf-8", newline="") as file:
        rows = list(csv.DictReader(file))

    assert len(rows) == 334
    assert len({row["index"] for row in rows}) == len(rows)
    for row in rows:
        cr = Fraction(row["challenge_rating"])
        # CR 0 vale 10 XP, ou 0 XP para monstros sem ataques eficazes.
        allowed = {0, 10} if cr == 0 else {xp_for_challenge_rating(cr)}
        assert int(row["xp"]) in allowed, row
