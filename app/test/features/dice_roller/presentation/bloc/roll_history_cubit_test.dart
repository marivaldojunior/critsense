import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_result.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/roll_history_cubit.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/roll_history_sheet.dart';

/// Testa o histórico de rolagens.
void main() {
  late SharedPreferences preferences;
  final now = DateTime(2026, 10, 17, 21, 5);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  RollHistoryCubit newCubit() =>
      RollHistoryCubit(preferences, clock: () => now);

  const advantage = DiceRollResult(
    rolls: [SingleDieResult(type: DiceType.d20, value: 20, discardedValue: 6)],
    modifier: 3,
  );
  const damage = DiceRollResult(
    rolls: [
      SingleDieResult(type: DiceType.d6, value: 2),
      SingleDieResult(type: DiceType.d6, value: 5),
    ],
    modifier: -1,
  );

  test('descreve os dados e o modificador', () {
    expect(describeRoll(advantage), 'd20: 20 (6 descartado) + 3');
    expect(describeRoll(damage), 'd6: 2, d6: 5 - 1');
    expect(describeRoll(const DiceRollResult(rolls: [], modifier: 1)), '1');
    expect(poolLabel({DiceType.d6: 2, DiceType.d20: 1}, 3), '2d6 + 1d20 + 3');
  });

  test('guarda a mais nova primeiro, com o crítico, e salva no aparelho', () {
    final cubit = newCubit()
      ..record('Espada — dano', damage)
      ..record('Ataque', advantage);
    addTearDown(cubit.close);

    expect(cubit.state.map((e) => e.label), ['Ataque', 'Espada — dano']);
    expect(cubit.state.first.critical, isTrue);
    expect(cubit.state.first.total, 23);
    expect(cubit.state.last.critical, isNull);

    final reopened = newCubit();
    addTearDown(reopened.close);
    expect(reopened.state, cubit.state);
  });

  test('guarda no máximo 50 rolagens e limpa', () {
    final cubit = newCubit();
    addTearDown(cubit.close);
    for (var i = 0; i < 60; i++) {
      cubit.record('R$i', damage);
    }

    expect(cubit.state, hasLength(RollHistoryCubit.maxEntries));
    expect(cubit.state.first.label, 'R59');

    cubit.clear();
    expect(newCubit().state, isEmpty);
  });

  testWidgets('a folha mostra as rolagens', (tester) async {
    final cubit = newCubit()..record('Ataque', advantage);
    sl.registerSingleton<RollHistoryCubit>(cubit);
    addTearDown(sl.reset);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(appBar: _Bar())));
    await tester.tap(find.byTooltip('Histórico de rolagens'));
    await tester.pumpAndSettle();

    expect(find.text('Ataque'), findsOneWidget);
    expect(find.text('21:05 · d20: 20 (6 descartado) + 3'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);

    await tester.tap(find.text('Limpar'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma rolagem ainda.'), findsOneWidget);
  });
}

class _Bar extends StatelessWidget implements PreferredSizeWidget {
  const _Bar();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) =>
      AppBar(actions: const [RollHistoryButton()]);
}
