import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/condition.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/concentration_rules.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/hit_point_rules.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa as regras de concentração do SRD 5.1.
void main() {
  final concentrating = buildTestCharacter().withConcentration('Bless')!;

  test('CD 10 ou metade do dano, o que for maior', () {
    expect(concentrationSaveDc(7), 10);
    expect(concentrationSaveDc(21), 10);
    expect(concentrationSaveDc(22), 11);
    expect(concentrationSaveDc(45), 22);
  });

  test('começar, trocar e terminar a concentração', () {
    expect(concentrating.concentrationSpell, 'Bless');
    expect(
      concentrating.withConcentration('Haste')!.concentrationSpell,
      'Haste',
    );
    expect(concentrating.withConcentration('Bless'), isNull);
    expect(concentrating.withConcentration('  '), isNull);
    expect(concentrating.withConcentrationEnded()!.isConcentrating, isFalse);
    expect(buildTestCharacter().withConcentrationEnded(), isNull);
  });

  test('dano que deixa PV mantém a concentração', () {
    final hit = concentrating.withDamage(10).withConcentrationChecked();

    expect(hit.concentrationSpell, 'Bless');
  });

  test('cair a 0 PV termina a concentração', () {
    final down = concentrating.withDamage(30).withConcentrationChecked();

    expect(down.isConcentrating, isFalse);
  });

  test('uma condição que incapacita termina a concentração', () {
    final stunned = concentrating
        .withConditionToggled(Condition.stunned)
        .withConcentrationChecked();
    final prone = concentrating
        .withConditionToggled(Condition.prone)
        .withConcentrationChecked();

    expect(stunned.isConcentrating, isFalse);
    expect(prone.isConcentrating, isTrue);
  });
}
