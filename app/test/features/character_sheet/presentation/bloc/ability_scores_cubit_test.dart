import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/srd_rules.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/ability_scores_cubit.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/point_buy_cubit.dart';
import 'package:crit_sense/features/character_sheet/presentation/widgets/ability_scores_section.dart';

/// Testa a matriz padrão, a rolagem 4d6 e a distribuição dos valores.
void main() {
  test('4d6 descarta o menor dado', () {
    final roll = rollAbilityScore(Random(7));

    expect(roll.dice, hasLength(4));
    expect(roll.total, roll.dice[0] + roll.dice[1] + roll.dice[2]);
    expect(roll.dice[3], lessThanOrEqualTo(roll.dice[2]));
    expect(roll.total, inInclusiveRange(3, 18));
  });

  test('matriz padrão distribuída vira os atributos', () {
    final cubit = AbilityScoresCubit()
      ..selectMethod(AbilityScoreMethod.standardArray);
    for (var i = 0; i < AttributeType.values.length; i++) {
      cubit.assign(AttributeType.values[i], i);
    }

    final attributes = cubit.state.attributes!;
    expect(attributes.strength, 15);
    expect(attributes.charisma, 8);
    expect(cubit.state.isComplete, isTrue);
  });

  test('o mesmo valor não fica em dois atributos', () {
    final cubit = AbilityScoresCubit()
      ..selectMethod(AbilityScoreMethod.standardArray)
      ..assign(AttributeType.strength, 0)
      ..assign(AttributeType.dexterity, 0);

    expect(cubit.state.assignment, {AttributeType.dexterity: 0});
    expect(cubit.state.attributes, isNull);
  });

  test('a rolagem gera seis valores e rolar de novo limpa a distribuição', () {
    final cubit = AbilityScoresCubit(random: Random(42))
      ..selectMethod(AbilityScoreMethod.roll)
      ..assign(AttributeType.strength, 0);
    final first = cubit.state.pool;

    cubit.reroll();

    expect(first, hasLength(6));
    expect(cubit.state.rolls, hasLength(6));
    expect(cubit.state.assignment, isEmpty);
  });

  testWidgets('a seção desenha os três métodos sem estouro no celular', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 900);
    addTearDown(tester.view.reset);
    final cubit = AbilityScoresCubit(random: Random(1));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => PointBuyCubit()),
              BlocProvider.value(value: cubit),
            ],
            child: const SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AbilityScoresSection(),
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('Pontos Restantes'), findsOneWidget);

    await tester.tap(find.text('Matriz padrão'));
    await tester.pumpAndSettle();
    expect(find.text('15'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Rolagem 4d6'));
    await tester.pumpAndSettle();
    expect(find.text('Rolar de novo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
