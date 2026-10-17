import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/condition.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/roll_rules.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa a vantagem e a desvantagem sugeridas pelas condições.
void main() {
  test('sem condições a rolagem é normal', () {
    final suggestion = suggestedRollMode(buildTestCharacter(), RollKind.attack);

    expect(suggestion.mode, D20RollMode.normal);
    expect(rollSuggestionNote(suggestion), isNull);
  });

  test('envenenado: desvantagem em ataques e testes, não em resistência', () {
    final poisoned = buildTestCharacter(conditions: const [Condition.poisoned]);

    expect(
      suggestedRollMode(poisoned, RollKind.attack).mode,
      D20RollMode.disadvantage,
    );
    expect(
      suggestedRollMode(poisoned, RollKind.abilityCheck).mode,
      D20RollMode.disadvantage,
    );
    expect(
      suggestedRollMode(poisoned, RollKind.savingThrow).mode,
      D20RollMode.normal,
    );
  });

  test('exaustão 1 afeta testes; exaustão 3 também ataques e resistências', () {
    final tired = buildTestCharacter(exhaustionLevel: 1);
    final exhausted = buildTestCharacter(exhaustionLevel: 3);

    expect(
      suggestedRollMode(tired, RollKind.abilityCheck).mode,
      D20RollMode.disadvantage,
    );
    expect(suggestedRollMode(tired, RollKind.attack).mode, D20RollMode.normal);
    expect(
      suggestedRollMode(exhausted, RollKind.savingThrow).mode,
      D20RollMode.disadvantage,
    );
  });

  test('impedido: desvantagem só na resistência de DES', () {
    final restrained = buildTestCharacter(
      conditions: const [Condition.restrained],
    );

    expect(
      suggestedRollMode(
        restrained,
        RollKind.savingThrow,
        attribute: AttributeType.dexterity,
      ).mode,
      D20RollMode.disadvantage,
    );
    expect(
      suggestedRollMode(
        restrained,
        RollKind.savingThrow,
        attribute: AttributeType.wisdom,
      ).mode,
      D20RollMode.normal,
    );
  });

  test('invisível dá vantagem; com desvantagem, as duas se anulam', () {
    final invisible = buildTestCharacter(
      conditions: const [Condition.invisible],
    );
    final both = buildTestCharacter(
      conditions: const [Condition.invisible, Condition.prone],
    );

    expect(
      suggestedRollMode(invisible, RollKind.attack).mode,
      D20RollMode.advantage,
    );
    final suggestion = suggestedRollMode(both, RollKind.attack);
    expect(suggestion.mode, D20RollMode.normal);
    expect(suggestion.reasons, hasLength(2));
  });
}
