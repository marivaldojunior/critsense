import 'srd_class.dart';

/// Truques conhecidos por classe: valores no 1º, no 4º e no 10º nível
/// (tabelas das classes do SRD 5.1).
const _cantripsKnown = {
  SrdClass.bard: (2, 3, 4),
  SrdClass.cleric: (3, 4, 5),
  SrdClass.druid: (2, 3, 4),
  SrdClass.sorcerer: (4, 5, 6),
  SrdClass.warlock: (2, 3, 4),
  SrdClass.wizard: (3, 4, 5),
};

/// Magias conhecidas do 1º ao 20º nível, nas classes que não preparam
/// magias (tabelas das classes do SRD 5.1).
const _spellsKnown = {
  SrdClass.bard: [
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    14,
    15,
    15,
    16,
    18,
    19,
    19,
    20,
    22,
    22,
    22,
  ],
  SrdClass.ranger: [
    0,
    2,
    3,
    3,
    4,
    4,
    5,
    5,
    6,
    6,
    7,
    7,
    8,
    8,
    9,
    9,
    10,
    10,
    11,
    11,
  ],
  SrdClass.sorcerer: [
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    12,
    13,
    13,
    14,
    14,
    15,
    15,
    15,
    15,
  ],
  SrdClass.warlock: [
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    10,
    11,
    11,
    12,
    12,
    13,
    13,
    14,
    14,
    15,
    15,
  ],
};

/// Quantos truques a classe conhece no [level], ou `null` se a classe não
/// tem truques.
int? cantripsKnownFor(SrdClass? srdClass, int level) {
  final table = _cantripsKnown[srdClass];
  if (table == null) return null;
  final (first, fourth, tenth) = table;
  if (level >= 10) return tenth;
  if (level >= 4) return fourth;
  return first;
}

/// Quantas magias (sem contar truques) a classe conhece no [level], ou
/// `null` nas classes que preparam magias ou que não conjuram.
int? spellsKnownFor(SrdClass? srdClass, int level) {
  final table = _spellsKnown[srdClass];
  if (table == null) return null;
  return table[(level.clamp(1, 20)) - 1];
}
