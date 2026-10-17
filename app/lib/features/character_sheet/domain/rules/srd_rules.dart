import 'dart:math';

import '../entities/condition.dart';
import '../srd/srd_class.dart';

/// Regras de cálculo do SRD 5.1 usadas pela ficha. São funções puras: sem
/// estado e sem acesso a banco, então ficam fáceis de testar.

/// Sucessos ou falhas necessários para resolver as salvaguardas contra a morte.
const deathSavesToResolve = 3;

/// Bônus de proficiência pelo nível: +2 do 1º ao 4º, +3 do 5º ao 8º, e assim
/// por diante até +6 no 17º.
int proficiencyBonusForLevel(int level) => 2 + (level.clamp(1, 20) - 1) ~/ 4;

/// CA sem armadura: 10 + DES. O Bárbaro soma CON e o Monge soma SAB (Defesa
/// sem Armadura).
int unarmoredArmorClass({
  required SrdClass? srdClass,
  required int dexterityModifier,
  required int constitutionModifier,
  required int wisdomModifier,
}) {
  final base = 10 + dexterityModifier;
  return switch (srdClass) {
    SrdClass.barbarian => base + constitutionModifier,
    SrdClass.monk => base + wisdomModifier,
    _ => base,
  };
}

/// Deslocamento com penalidades: condições que prendem (Agarrado, Impedido...)
/// e exaustão 5 zeram; exaustão 2 corta pela metade.
int speedWithPenalties({
  required int baseSpeed,
  required List<Condition> conditions,
  required int exhaustionLevel,
}) {
  if (exhaustionLevel >= 5 || conditions.any((c) => c.stopsMovement)) return 0;
  if (exhaustionLevel >= 2) return baseSpeed ~/ 2;
  return baseSpeed;
}

/// PV recuperados ao gastar um dado de vida: o valor rolado mais o
/// modificador de CON, nunca menos que 0.
int hitDieHealing({required int roll, required int constitutionModifier}) {
  final healing = roll + constitutionModifier;
  return healing < 0 ? 0 : healing;
}

/// Dados de vida recuperados num Descanso Longo: metade do total (o nível),
/// no mínimo 1.
int hitDiceRecoveredOnLongRest(int level) {
  final half = level ~/ 2;
  return half < 1 ? 1 : half;
}

/// Resultado de uma salvaguarda contra a morte (d20, sem modificadores).
enum DeathSaveOutcome {
  /// 20 natural: o personagem volta com 1 PV.
  criticalSuccess,

  /// 10 ou mais: um sucesso.
  success,

  /// 2 a 9: uma falha.
  failure,

  /// 1 natural: duas falhas.
  criticalFailure,
}

DeathSaveOutcome deathSaveOutcome(int roll) {
  if (roll >= 20) return DeathSaveOutcome.criticalSuccess;
  if (roll <= 1) return DeathSaveOutcome.criticalFailure;
  if (roll >= 10) return DeathSaveOutcome.success;
  return DeathSaveOutcome.failure;
}

/// PV ganhos num nível depois do 1º, pela média fixa do dado de vida do SRD
/// (metade do dado + 1) mais o modificador de CON. Mínimo de 1 PV por nível.
int averageHitPointsPerLevel({
  required int hitDie,
  required int constitutionModifier,
}) {
  final gain = hitDie ~/ 2 + 1 + constitutionModifier;
  return gain < 1 ? 1 : gain;
}

/// PV máximo de um personagem novo no [level] informado: o valor máximo do
/// dado de vida + mod. de CON no 1º nível, e a média nos níveis seguintes.
int startingMaxHitPoints({
  required int hitDie,
  required int constitutionModifier,
  required int level,
}) {
  final firstLevel = hitDie + constitutionModifier;
  final atFirstLevel = firstLevel < 1 ? 1 : firstLevel;
  final perLevel = averageHitPointsPerLevel(
    hitDie: hitDie,
    constitutionModifier: constitutionModifier,
  );
  return atFirstLevel + perLevel * (level.clamp(1, 20) - 1);
}

/// Matriz padrão de atributos do SRD.
const standardAbilityArray = [15, 14, 13, 12, 10, 8];

/// Uma rolagem de atributo: os 4 dados (do maior ao menor) e a soma dos 3
/// maiores.
typedef AbilityScoreRoll = ({List<int> dice, int total});

/// Rola 4d6 e descarta o menor dado.
AbilityScoreRoll rollAbilityScore(Random random) {
  final dice = [for (var i = 0; i < 4; i++) random.nextInt(6) + 1]
    ..sort((a, b) => b.compareTo(a));
  return (dice: dice, total: dice[0] + dice[1] + dice[2]);
}

/// XP mínimo de cada nível do SRD (posição 0 = nível 1).
const experienceThresholds = [
  0, 300, 900, 2700, 6500, 14000, 23000, 34000, 48000, 64000, //
  85000, 100000, 120000, 140000, 165000, 195000, 225000, 265000, 305000,
  355000,
];

/// Nível máximo de personagem.
const maxCharacterLevel = 20;

/// XP necessário para chegar ao nível seguinte a [level], ou `null` no 20º.
int? experienceForNextLevel(int level) =>
    level >= maxCharacterLevel ? null : experienceThresholds[level];

/// Nível que [experiencePoints] permite pela tabela do SRD.
int levelForExperience(int experiencePoints) {
  var level = 1;
  while (level < maxCharacterLevel &&
      experiencePoints >= experienceThresholds[level]) {
    level++;
  }
  return level;
}
