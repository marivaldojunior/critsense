import '../entities/character.dart';
import '../srd/spell_slots.dart';

/// Regras dos espaços de magia como transformações puras de [Character].
/// Um método que devolve `null` não muda nada (ex: gastar um espaço que não
/// existe).
extension SpellRules on Character {
  /// Gasta um espaço do nível de magia [spellLevel] (1 a 9).
  Character? withSpellSlotUsed(int spellLevel) {
    if (spellLevel < 1 || spellLevel > spellSlotLevels) return null;
    if (availableSpellSlots(spellLevel) == 0) return null;
    final used = _normalizedSlots()..[spellLevel - 1] += 1;
    return copyWith(spellSlotsUsed: used);
  }

  /// Devolve um espaço gasto do nível [spellLevel] (correção manual).
  Character? withSpellSlotRestored(int spellLevel) {
    if (spellLevel < 1 || spellLevel > spellSlotLevels) return null;
    final used = _normalizedSlots();
    if (used[spellLevel - 1] == 0) return null;
    used[spellLevel - 1] -= 1;
    return copyWith(spellSlotsUsed: used);
  }

  /// Gasta um espaço da Magia de Pacto.
  Character? withPactSlotUsed() {
    final pact = pactMagic;
    if (pact == null || pactSlotsUsed >= pact.slots) return null;
    return copyWith(pactSlotsUsed: pactSlotsUsed + 1);
  }

  /// Devolve um espaço gasto da Magia de Pacto.
  Character? withPactSlotRestored() {
    if (pactSlotsUsed == 0) return null;
    return copyWith(pactSlotsUsed: pactSlotsUsed - 1);
  }

  /// Fim do Descanso Curto: a Magia de Pacto volta inteira.
  Character? afterShortRest() {
    if (pactSlotsUsed == 0) return null;
    return copyWith(pactSlotsUsed: 0);
  }

  /// Todos os espaços (comuns e de pacto) cheios de novo. Usado no Descanso
  /// Longo.
  Character withAllSpellSlotsRestored() => copyWith(
    spellSlotsUsed: List.filled(spellSlotLevels, 0),
    pactSlotsUsed: 0,
  );

  /// Lista com 9 posições, mesmo que o banco tenha salvo menos.
  List<int> _normalizedSlots() => List.generate(
    spellSlotLevels,
    (i) => i < spellSlotsUsed.length ? spellSlotsUsed[i] : 0,
  );
}
