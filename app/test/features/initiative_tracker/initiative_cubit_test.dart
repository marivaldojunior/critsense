import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/initiative_tracker/presentation/cubit/initiative_cubit.dart';
import 'package:crit_sense/features/initiative_tracker/presentation/pages/initiative_tracker_screen.dart';

import '../../helpers/character_test_helpers.dart';

/// Random que devolve sempre o mesmo d20.
class _FixedRandom implements Random {
  _FixedRandom(this.d20);

  final int d20;

  @override
  int nextInt(int max) => d20 - 1;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

/// Testa o rastreador de iniciativa.
void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  InitiativeCubit newCubit({int d20 = 10}) =>
      InitiativeCubit(preferences, random: _FixedRandom(d20));

  test('ordena pela iniciativa e desempata pelo modificador', () {
    final cubit = newCubit()
      ..add(name: 'Goblin', initiativeBonus: 2)
      ..add(name: 'Thorin', initiativeBonus: 0)
      ..add(name: 'Elfa', initiativeBonus: 4);
    addTearDown(cubit.close);

    final ids = {for (final c in cubit.state.combatants) c.name: c.id};
    cubit
      ..setInitiative(ids['Goblin']!, 15)
      ..setInitiative(ids['Thorin']!, 18)
      ..setInitiative(ids['Elfa']!, 15);

    expect(cubit.state.combatants.map((c) => c.name), [
      'Thorin',
      'Elfa',
      'Goblin',
    ]);
  });

  test('nomes repetidos ganham número; um personagem entra uma vez só', () {
    final cubit = newCubit()
      ..add(name: 'Goblin')
      ..add(name: 'Goblin')
      ..add(name: 'Thorin', characterId: 'c1')
      ..add(name: 'Thorin', characterId: 'c1');
    addTearDown(cubit.close);

    expect(cubit.state.combatants.map((c) => c.name).toSet(), {
      'Goblin',
      'Goblin 2',
      'Thorin',
    });
  });

  test('começar rola quem falta; o turno passa e a rodada avança', () {
    final cubit = newCubit(d20: 12)
      ..add(name: 'A', initiativeBonus: 3)
      ..add(name: 'B', initiativeBonus: 1);
    addTearDown(cubit.close);

    cubit.start();
    expect(cubit.state.round, 1);
    expect(cubit.state.current!.name, 'A');
    expect(cubit.state.combatants.first.initiative, 15);

    cubit.nextTurn();
    expect(cubit.state.current!.name, 'B');
    cubit.nextTurn();
    expect(cubit.state.round, 2);
    expect(cubit.state.current!.name, 'A');
    cubit.previousTurn();
    expect(cubit.state.round, 1);
    expect(cubit.state.current!.name, 'B');
  });

  test('tirar alguém mantém o turno de quem joga agora', () {
    final cubit = newCubit()
      ..add(name: 'A', initiativeBonus: 3)
      ..add(name: 'B', initiativeBonus: 2)
      ..add(name: 'C', initiativeBonus: 1);
    addTearDown(cubit.close);
    cubit
      ..start()
      ..nextTurn()
      ..nextTurn();
    expect(cubit.state.current!.name, 'C');

    cubit.remove(cubit.state.combatants.first.id);

    expect(cubit.state.current!.name, 'C');
  });

  test('PV de monstro ficam entre 0 e o máximo', () {
    final cubit = newCubit()..add(name: 'Goblin', hitPoints: 7);
    addTearDown(cubit.close);
    final id = cubit.state.combatants.single.id;

    cubit.changeHitPoints(id, -10);
    expect(cubit.state.combatants.single.hitPoints, 0);
    expect(cubit.state.combatants.single.isDown, isTrue);
    cubit.changeHitPoints(id, 20);
    expect(cubit.state.combatants.single.hitPoints, 7);
  });

  test('o combate continua depois de fechar o app', () {
    final cubit = newCubit()
      ..add(name: 'Goblin', hitPoints: 7, armorClass: 15)
      ..start();
    addTearDown(cubit.close);

    final reopened = newCubit();
    addTearDown(reopened.close);

    expect(reopened.state.round, 1);
    expect(reopened.state.combatants.single.name, 'Goblin');
    expect(reopened.state.combatants.single.armorClass, 15);
  });

  testWidgets('a tela adiciona um personagem, começa e passa o turno', (
    tester,
  ) async {
    final cubit = newCubit();
    sl.registerSingleton<InitiativeCubit>(cubit);
    addTearDown(sl.reset);
    final (:bloc, saveCharacter: _) =
        await tester.runAsync(
          () => loadedCharacterBloc([buildTestCharacter()]),
        ) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CharacterBloc>.value(
          value: bloc,
          child: const InitiativeTrackerScreen(),
        ),
      ),
    );
    expect(find.textContaining('Toque no botão de adicionar'), findsOneWidget);

    await tester.tap(find.byTooltip('Adicionar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personagem'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thorin'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Adicionar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Outra criatura'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Lobo');
    await tester.tap(find.text('Adicionar').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Começar combate'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciativa — rodada 1'), findsOneWidget);
    // Thorin: d20 10 + 2 (DES 14).
    expect(find.text('12'), findsOneWidget);

    await tester.tap(find.text('Próximo turno'));
    await tester.tap(find.text('Próximo turno'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciativa — rodada 2'), findsOneWidget);
  });
}
