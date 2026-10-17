import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/coins.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/inventory_item.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/inventory_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/pages/character_sheet_tabs/inventory_tab.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa a aba Inventário: carga, moedas, itens e as ações de um item.
void main() {
  const sword = InventoryItem(
    id: 'sword',
    characterId: 'c1',
    itemIndex: 'longsword',
    name: 'Longsword',
    equipmentCategory: 'Weapon',
    weight: 3,
    weaponCategory: 'Martial',
    weaponRange: 'Melee',
    damageDice: '1d8',
    damageType: 'Slashing',
  );
  const torches = InventoryItem(
    id: 'torch',
    characterId: 'c1',
    itemIndex: 'torch',
    name: 'Torch',
    equipmentCategory: 'Adventuring Gear',
    quantity: 10,
    weight: 1,
  );

  Future<InventoryBloc> pumpTab(
    WidgetTester tester,
    Character character,
    List<InventoryItem> items,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 860);
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
            child: InventoryTab(character: character),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return inventory;
  }

  testWidgets('mostra carga, moedas e itens', (tester) async {
    final character = buildTestCharacter(
      attributes: const Attribute(strength: 10),
    ).copyWith(coins: const Coins().withAmount(Coin.gold, 50));

    await pumpTab(tester, character, [sword, torches]);

    // 3 + 10 × 1 + 50 moedas (1 lb) = 14 lb; capacidade 10 × 15 = 150.
    expect(find.text('14 lb / 150 lb'), findsOneWidget);
    expect(find.text('50 PO'), findsOneWidget);
    expect(find.text('Total: 50 PO'), findsOneWidget);
    expect(find.text('Longsword'), findsOneWidget);
    expect(find.text('×10 · 10 lb'), findsOneWidget);
    expect(find.text('Sintonia: 0/3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('equipar uma arma pelas ações do item', (tester) async {
    final inventory = await pumpTab(tester, buildTestCharacter(), [sword]);

    await tester.tap(find.text('Longsword'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Equipar'));
    await tester.runAsync(
      () => inventory.stream.firstWhere((s) => s.items.any((i) => i.equipped)),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Equipado'), findsOneWidget);
  });
}
