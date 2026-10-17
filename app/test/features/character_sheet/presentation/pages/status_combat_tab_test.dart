import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/condition.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/inventory_item.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/pages/character_sheet_tabs/status_combat_tab.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/dice_roller/data/datasources/sensor_datasource.dart';
import 'package:crit_sense/features/dice_roller/data/repositories/dice_repository_impl.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/usecases/roll_dice_usecase.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/sheet_roll_cubit.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Sensor sem hardware para os testes.
class _SilentSensor implements ISensorDataSource {
  @override
  Future<void> triggerCriticalSuccess() async {}

  @override
  Future<void> triggerCriticalFailure() async {}

  @override
  Stream<void> get onShakeDetected => const Stream.empty();
}

/// Testa a aba Status & Combate: valores derivados, dados de vida,
/// salvaguardas contra a morte, condições e inspiração.
void main() {
  setUp(() {
    sl.registerFactoryParam<SheetRollCubit, D20RollMode, void>(
      (mode, _) => SheetRollCubit(
        RollDiceUseCase(DiceRepositoryImpl(_SilentSensor())),
        initialMode: mode,
      ),
    );
  });

  tearDown(() => sl.reset());

  /// Desenha a aba numa tela de celular (400 × 860), ou numa tela larga
  /// (layout de duas colunas) com [wide].
  Future<CharacterBloc> pumpTab(
    WidgetTester tester,
    Character character, {
    bool wide = false,
    List<InventoryItem> items = const [],
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
    final inventory =
        await tester.runAsync(() => loadedInventoryBloc(items)) ??
        (throw StateError('inventário não carregou'));
    addTearDown(inventory.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: bloc),
              BlocProvider.value(value: inventory),
            ],
            child: StatusCombatTab(character: character),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return bloc;
  }

  /// Rola a lista até [finder] aparecer (o ListView só constrói o que está
  /// perto da tela).
  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );

  testWidgets('mostra CA, iniciativa, proficiência e dados de vida '
      'calculados', (tester) async {
    await pumpTab(tester, buildTestCharacter());

    expect(find.text('12'), findsOneWidget); // CA: 10 + DES 2
    expect(find.text('+2'), findsWidgets); // iniciativa e proficiência
    expect(find.text('Dados de vida: 4/4 (d10)'), findsOneWidget);
    expect(find.text('Salvaguardas contra a morte'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a CA conta a armadura equipada e a arma aparece nos ataques', (
    tester,
  ) async {
    await pumpTab(
      tester,
      buildTestCharacter(),
      items: const [
        InventoryItem(
          id: 'chain',
          characterId: 'c1',
          itemIndex: 'chain-mail',
          name: 'Chain Mail',
          equipmentCategory: 'Armor',
          armorCategory: 'Heavy',
          armorBase: 16,
          equipped: true,
        ),
        InventoryItem(
          id: 'sword',
          characterId: 'c1',
          itemIndex: 'longsword',
          name: 'Longsword',
          equipmentCategory: 'Weapon',
          weaponCategory: 'Martial',
          weaponRange: 'Melee',
          damageDice: '1d8',
          damageType: 'Slashing',
          equipped: true,
        ),
      ],
    );

    expect(find.text('16'), findsOneWidget); // CA da cota de malha
    expect(find.text('Longsword'), findsOneWidget);
    expect(find.text('1d8-1 cortante'), findsOneWidget); // FOR 8 (-1)
    expect(find.text('Ataque desarmado'), findsOneWidget);
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

    await scrollTo(tester, find.text('Envenenado'));
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

  testWidgets('o botão PV máximo troca o máximo e sobe os PV atuais', (
    tester,
  ) async {
    final bloc = await pumpTab(
      tester,
      buildTestCharacter(currentHitPoints: 20),
    );

    await scrollTo(tester, find.text('PV máximo'));
    await tester.tap(find.text('PV máximo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '38');
    await tester.tap(find.text('Salvar'));
    final state = await tester.runAsync(
      () => bloc.stream
          .firstWhere((s) => s.findCharacter('c1')?.maxHitPoints == 38)
          .timeout(const Duration(seconds: 5)),
    );

    expect(state!.findCharacter('c1')!.currentHitPoints, 28);
  });

  testWidgets('o cartão de recursos gasta um uso do Surto de Ação', (
    tester,
  ) async {
    final bloc = await pumpTab(tester, buildTestCharacter());

    await scrollTo(tester, find.text('Surto de Ação'));
    expect(find.text('Retomar o Fôlego'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Gastar Surto de Ação'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Gastar Surto de Ação'));
    await tester.runAsync(
      () => bloc.stream
          .firstWhere(
            (s) => s.findCharacter('c1')?.resourcesUsed['action-surge'] == 1,
          )
          .timeout(const Duration(seconds: 5)),
    );
    await tester.pumpAndSettle();

    expect(find.text('0/1'), findsOneWidget);
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

  testWidgets('tocar numa perícia rola o teste; a caixa marca a proficiência', (
    tester,
  ) async {
    final bloc = await pumpTab(
      tester,
      buildTestCharacter(conditions: const [Condition.poisoned]),
    );

    await scrollTo(tester, find.text('Atletismo'));
    await tester.ensureVisible(find.text('Atletismo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atletismo'));
    await tester.pumpAndSettle();

    expect(find.text('Atletismo (-1)'), findsOneWidget); // FOR 8
    expect(find.text('Desvantagem: Envenenado'), findsOneWidget);
    await tester.tap(find.text('Rolar d20'));
    await tester.pumpAndSettle();
    expect(find.textContaining('d20: '), findsOneWidget);
    expect(find.textContaining('descartado'), findsOneWidget);
    expect(bloc.state.findCharacter('c1')!.proficiencies, isEmpty);
  });
}
