import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/condition.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/pages/character_sheet_tabs/status_combat_tab.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa a aba Status & Combate: valores derivados, dados de vida,
/// salvaguardas contra a morte, condições e inspiração.
void main() {
  /// Desenha a aba numa tela de celular (400 × 860), ou numa tela larga
  /// (layout de duas colunas) com [wide].
  Future<CharacterBloc> pumpTab(
    WidgetTester tester,
    Character character, {
    bool wide = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = wide
        ? const Size(1000, 800)
        : const Size(400, 860);
    addTearDown(tester.view.reset);

    final (:bloc, saveCharacter: _) =
        await tester.runAsync(() => loadedCharacterBloc([character])) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: StatusCombatTab(character: character),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('mostra CA, iniciativa, proficiência e dados de vida '
      'calculados', (tester) async {
    await pumpTab(tester, buildTestCharacter());

    expect(find.text('12'), findsOneWidget); // CA: 10 + DES 2
    expect(find.text('+2'), findsWidgets); // iniciativa e proficiência
    expect(find.text('Dados de vida: 4/4 (d10)'), findsOneWidget);
    expect(find.text('Salvaguardas contra a morte'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('com 0 PV mostra as salvaguardas contra a morte', (tester) async {
    await pumpTab(tester, buildTestCharacter(currentHitPoints: 0));

    expect(find.text('Salvaguardas contra a morte'), findsOneWidget);
    expect(find.text('Morrendo'), findsOneWidget);
    expect(find.text('Rolar salvaguarda (d20)'), findsOneWidget);
  });

  testWidgets('condições ativas e exaustão aparecem com o efeito', (
    tester,
  ) async {
    await pumpTab(
      tester,
      buildTestCharacter(
        conditions: const [Condition.poisoned, Condition.grappled],
        exhaustionLevel: 2,
      ),
    );

    expect(find.text('Envenenado'), findsOneWidget);
    expect(find.text('Agarrado'), findsOneWidget);
    expect(find.text('2. Deslocamento reduzido à metade.'), findsOneWidget);
    // Agarrado zera o deslocamento.
    expect(find.text('0 pés (base 25)'), findsOneWidget);
  });

  testWidgets('o layout largo (duas colunas) desenha sem estouro', (
    tester,
  ) async {
    await pumpTab(
      tester,
      buildTestCharacter(
        currentHitPoints: 0,
        conditions: const [Condition.poisoned],
        exhaustionLevel: 1,
      ),
      wide: true,
    );

    expect(find.text('Salvaguardas contra a morte'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar na inspiração liga o marcador', (tester) async {
    final bloc = await pumpTab(tester, buildTestCharacter());

    await tester.tap(find.text('Sem inspiração'));
    await tester.runAsync(
      () => bloc.stream.firstWhere(
        (s) => s.findCharacter('c1')?.inspiration ?? false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Com inspiração'), findsOneWidget);
  });
}
