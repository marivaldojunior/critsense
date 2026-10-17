import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/level_rules.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/srd_rules.dart';
import 'package:crit_sense/features/character_sheet/presentation/widgets/level_up_sheet.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa a tabela de XP e a subida de nível.
void main() {
  group('XP', () {
    test('tabela do SRD', () {
      expect(levelForExperience(0), 1);
      expect(levelForExperience(299), 1);
      expect(levelForExperience(300), 2);
      expect(levelForExperience(6500), 5);
      expect(levelForExperience(355000), 20);
      expect(levelForExperience(999999), 20);
      expect(experienceForNextLevel(1), 300);
      expect(experienceForNextLevel(20), isNull);
    });

    test('pronto para subir quando o XP chega ao próximo nível', () {
      final fighter = buildTestCharacter(level: 1);

      expect(fighter.isReadyToLevelUp, isFalse);
      expect(fighter.withExperienceAdded(300).isReadyToLevelUp, isTrue);
      expect(fighter.withExperienceAdded(-50).experiencePoints, 0);
    });
  });

  group('Aumento de Valor de Atributo', () {
    test('níveis comuns e os extras do Guerreiro e do Ladino', () {
      expect(
        buildTestCharacter(level: 3).nextLevelHasAbilityScoreImprovement,
        isTrue,
      );
      expect(
        buildTestCharacter(level: 5).nextLevelHasAbilityScoreImprovement,
        isTrue,
      ); // Guerreiro, 6º
      expect(
        buildTestCharacter(
          characterClass: 'Wizard',
          level: 5,
        ).nextLevelHasAbilityScoreImprovement,
        isFalse,
      );
      expect(
        buildTestCharacter(
          characterClass: 'Rogue',
          level: 9,
        ).nextLevelHasAbilityScoreImprovement,
        isTrue,
      );
    });

    test('validação: +2 num atributo ou +1 em dois, sem passar de 20', () {
      const attributes = Attribute(strength: 19);

      expect(
        isValidAbilityScoreImprovement(attributes, {
          AttributeType.dexterity: 2,
        }),
        isTrue,
      );
      expect(
        isValidAbilityScoreImprovement(attributes, {
          AttributeType.dexterity: 1,
          AttributeType.wisdom: 1,
        }),
        isTrue,
      );
      expect(
        isValidAbilityScoreImprovement(attributes, {AttributeType.strength: 2}),
        isFalse,
      );
      expect(
        isValidAbilityScoreImprovement(attributes, {
          AttributeType.dexterity: 1,
        }),
        isFalse,
      );
      expect(isValidAbilityScoreImprovement(attributes, const {}), isFalse);
    });
  });

  group('subir de nível', () {
    test('ganha o dado + CON e os PV atuais sobem junto', () {
      // Guerreiro nível 4, CON 14 (+2), 30/30 PV, 10 de dano.
      final hurt = buildTestCharacter(currentHitPoints: 20);
      final up = hurt.withLevelUp(hitDieResult: 6)!;

      expect(up.level, 5);
      expect(up.maxHitPoints, 38);
      expect(up.currentHitPoints, 28);
      expect(up.proficiencyBonus, 3);
      expect(up.hitDiceRemaining, 5);
    });

    test('o ganho de PV é no mínimo 1', () {
      final frail = buildTestCharacter(
        attributes: const Attribute(constitution: 3),
      );

      expect(frail.withLevelUp(hitDieResult: 1)!.maxHitPoints, 31);
    });

    test('CON maior no aumento de atributo vale também para os níveis '
        'anteriores', () {
      // CON 15 (+2) -> 16 (+3): 4 níveis antigos ganham +1 cada.
      final fighter = buildTestCharacter(
        level: 3,
        attributes: const Attribute(constitution: 15),
      );
      final up = fighter.withLevelUp(
        hitDieResult: 6,
        abilityIncreases: {
          AttributeType.constitution: 1,
          AttributeType.strength: 1,
        },
      )!;

      expect(up.attributes.constitution, 16);
      expect(up.attributes.strength, 9);
      // 6 + 3 (CON nova) + 1 × 3 níveis anteriores = 12.
      expect(up.maxHitPoints, 42);
    });

    test('não passa do 20º nível', () {
      expect(
        buildTestCharacter(level: 20).withLevelUp(hitDieResult: 6),
        isNull,
      );
      expect(buildTestCharacter(level: 20).canLevelUp, isFalse);
    });

    test('média do dado de vida', () {
      expect(buildTestCharacter().averageHitDieGain, 6); // d10
      expect(buildTestCharacter(characterClass: 'Wizard').averageHitDieGain, 4);
    });
  });

  testWidgets('o painel pede o aumento de atributo no nível certo', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 900);
    addTearDown(tester.view.reset);
    final character = buildTestCharacter(level: 3);
    final (:bloc, :saveCharacter) =
        await tester.runAsync(() => loadedCharacterBloc([character])) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: LevelUpSheet(character: character, random: Random(3)),
          ),
        ),
      ),
    );

    expect(find.text('Nível 3 → 4'), findsOneWidget);
    expect(find.text('Aumento de Valor de Atributo'), findsOneWidget);
    expect(find.text('Subir para o nível 4'), findsOneWidget);
    // Sem atributo escolhido, o botão principal fica desligado.
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Subir para o nível 4'),
    );
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
