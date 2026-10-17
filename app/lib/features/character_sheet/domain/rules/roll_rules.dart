import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';

import '../entities/attribute_type.dart';
import '../entities/character.dart';
import '../entities/condition.dart';

/// Tipo de rolagem de d20 feita pela ficha.
enum RollKind {
  /// Teste de habilidade ou de perícia (inclui a iniciativa).
  abilityCheck,

  /// Teste de resistência.
  savingThrow,

  /// Jogada de ataque (arma ou magia).
  attack,
}

/// Modo sugerido para a rolagem e os motivos, para a ficha mostrar.
typedef RollSuggestion = ({D20RollMode mode, List<String> reasons});

/// Vantagem ou desvantagem que as condições e a exaustão do [character]
/// impõem numa rolagem do tipo [kind] ([attribute] = atributo do teste de
/// resistência). Pelo SRD, vantagem e desvantagem juntas se anulam.
RollSuggestion suggestedRollMode(
  Character character,
  RollKind kind, {
  AttributeType? attribute,
}) {
  final disadvantages = <String>[];
  final advantages = <String>[];
  final conditions = character.conditions;
  final exhaustion = character.exhaustionLevel;

  switch (kind) {
    case RollKind.abilityCheck:
      if (exhaustion >= 1) disadvantages.add('Exaustão');
      if (conditions.contains(Condition.poisoned)) {
        disadvantages.add(Condition.poisoned.label);
      }
      if (conditions.contains(Condition.frightened)) {
        disadvantages.add(Condition.frightened.label);
      }
    case RollKind.savingThrow:
      if (exhaustion >= 3) disadvantages.add('Exaustão');
      if (attribute == AttributeType.dexterity &&
          conditions.contains(Condition.restrained)) {
        disadvantages.add(Condition.restrained.label);
      }
    case RollKind.attack:
      if (exhaustion >= 3) disadvantages.add('Exaustão');
      for (final condition in const [
        Condition.poisoned,
        Condition.frightened,
        Condition.prone,
        Condition.restrained,
        Condition.blinded,
      ]) {
        if (conditions.contains(condition)) disadvantages.add(condition.label);
      }
      if (conditions.contains(Condition.invisible)) {
        advantages.add(Condition.invisible.label);
      }
  }

  final mode = disadvantages.isNotEmpty && advantages.isNotEmpty
      ? D20RollMode.normal
      : disadvantages.isNotEmpty
      ? D20RollMode.disadvantage
      : advantages.isNotEmpty
      ? D20RollMode.advantage
      : D20RollMode.normal;
  return (
    mode: mode,
    reasons: [
      for (final reason in disadvantages) 'Desvantagem: $reason',
      for (final reason in advantages) 'Vantagem: $reason',
    ],
  );
}

/// Texto curto dos motivos, ou `null` sem motivos.
String? rollSuggestionNote(RollSuggestion suggestion) =>
    suggestion.reasons.isEmpty ? null : suggestion.reasons.join(' · ');
