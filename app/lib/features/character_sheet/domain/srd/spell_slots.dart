import 'srd_class.dart';

/// Tabelas de espaços de magia do SRD 5.1.
///
/// Cada linha tem 9 posições: a quantidade de espaços do 1º ao 9º nível de
/// magia. O índice da lista externa é o nível do personagem menos 1.

/// Níveis de magia (1º a 9º).
const spellSlotLevels = 9;

const List<int> _noSlots = [0, 0, 0, 0, 0, 0, 0, 0, 0];

/// Bardo, Clérigo, Druida, Feiticeiro e Mago.
const _fullCasterSlots = <List<int>>[
  [2, 0, 0, 0, 0, 0, 0, 0, 0],
  [3, 0, 0, 0, 0, 0, 0, 0, 0],
  [4, 2, 0, 0, 0, 0, 0, 0, 0],
  [4, 3, 0, 0, 0, 0, 0, 0, 0],
  [4, 3, 2, 0, 0, 0, 0, 0, 0],
  [4, 3, 3, 0, 0, 0, 0, 0, 0],
  [4, 3, 3, 1, 0, 0, 0, 0, 0],
  [4, 3, 3, 2, 0, 0, 0, 0, 0],
  [4, 3, 3, 3, 1, 0, 0, 0, 0],
  [4, 3, 3, 3, 2, 0, 0, 0, 0],
  [4, 3, 3, 3, 2, 1, 0, 0, 0],
  [4, 3, 3, 3, 2, 1, 0, 0, 0],
  [4, 3, 3, 3, 2, 1, 1, 0, 0],
  [4, 3, 3, 3, 2, 1, 1, 0, 0],
  [4, 3, 3, 3, 2, 1, 1, 1, 0],
  [4, 3, 3, 3, 2, 1, 1, 1, 0],
  [4, 3, 3, 3, 2, 1, 1, 1, 1],
  [4, 3, 3, 3, 3, 1, 1, 1, 1],
  [4, 3, 3, 3, 3, 2, 1, 1, 1],
  [4, 3, 3, 3, 3, 2, 2, 1, 1],
];

/// Paladino e Patrulheiro: sem magia no 1º nível, até o 5º nível de magia.
const _halfCasterSlots = <List<int>>[
  [0, 0, 0, 0, 0, 0, 0, 0, 0],
  [2, 0, 0, 0, 0, 0, 0, 0, 0],
  [3, 0, 0, 0, 0, 0, 0, 0, 0],
  [3, 0, 0, 0, 0, 0, 0, 0, 0],
  [4, 2, 0, 0, 0, 0, 0, 0, 0],
  [4, 2, 0, 0, 0, 0, 0, 0, 0],
  [4, 3, 0, 0, 0, 0, 0, 0, 0],
  [4, 3, 0, 0, 0, 0, 0, 0, 0],
  [4, 3, 2, 0, 0, 0, 0, 0, 0],
  [4, 3, 2, 0, 0, 0, 0, 0, 0],
  [4, 3, 3, 0, 0, 0, 0, 0, 0],
  [4, 3, 3, 0, 0, 0, 0, 0, 0],
  [4, 3, 3, 1, 0, 0, 0, 0, 0],
  [4, 3, 3, 1, 0, 0, 0, 0, 0],
  [4, 3, 3, 2, 0, 0, 0, 0, 0],
  [4, 3, 3, 2, 0, 0, 0, 0, 0],
  [4, 3, 3, 3, 1, 0, 0, 0, 0],
  [4, 3, 3, 3, 1, 0, 0, 0, 0],
  [4, 3, 3, 3, 2, 0, 0, 0, 0],
  [4, 3, 3, 3, 2, 0, 0, 0, 0],
];

/// Espaços de magia comuns (não de pacto) da classe no nível do personagem.
List<int> spellSlotsFor(SrdClass? srdClass, int level) {
  final row = level.clamp(1, 20) - 1;
  return switch (srdClass?.spellcasting) {
    Spellcasting.full => _fullCasterSlots[row],
    Spellcasting.half => _halfCasterSlots[row],
    _ => _noSlots,
  };
}

/// Magia de Pacto do Bruxo: [slots] espaços, todos do [slotLevel].
typedef PactMagic = ({int slots, int slotLevel});

/// Magia de Pacto do Bruxo no nível [level], ou `null` para outras classes.
PactMagic? pactMagicFor(SrdClass? srdClass, int level) {
  if (srdClass?.spellcasting != Spellcasting.pact) return null;
  final lvl = level.clamp(1, 20);
  final slots = switch (lvl) {
    1 => 1,
    <= 10 => 2,
    <= 16 => 3,
    _ => 4,
  };
  final slotLevel = switch (lvl) {
    <= 2 => 1,
    <= 4 => 2,
    <= 6 => 3,
    <= 8 => 4,
    _ => 5,
  };
  return (slots: slots, slotLevel: slotLevel);
}
