import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/inventory_item.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/add_inventory_item_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_inventory_item_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_character_inventory_usecase.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/inventory_bloc.dart';
import 'package:crit_sense/features/compendium/domain/entities/equipment_detail.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_equipment_detail_usecase.dart';

class _MockGetCharacterInventoryUseCase extends Mock
    implements GetCharacterInventoryUseCase {}

class _MockDeleteInventoryItemUseCase extends Mock
    implements DeleteInventoryItemUseCase {}

class _MockSaveItem extends Mock implements AddInventoryItemUseCase {}

class _MockGetEquipmentDetail extends Mock
    implements GetEquipmentDetailUseCase {}

/// Testa a carga e a remoção de itens no [InventoryBloc].
void main() {
  late _MockGetCharacterInventoryUseCase getInventory;
  late _MockDeleteInventoryItemUseCase deleteItem;
  late _MockSaveItem saveItem;
  late _MockGetEquipmentDetail getDetail;
  late InventoryBloc bloc;

  const characterId = 'char-1';

  InventoryItem buildItem(String id) => InventoryItem(
    id: id,
    characterId: characterId,
    itemIndex: id,
    name: 'Item $id',
    equipmentCategory: 'Weapon',
  );

  final sword = buildItem('sword');
  final shield = buildItem('shield');

  setUpAll(() => registerFallbackValue(buildItem('fallback')));

  setUp(() {
    getInventory = _MockGetCharacterInventoryUseCase();
    deleteItem = _MockDeleteInventoryItemUseCase();
    saveItem = _MockSaveItem();
    getDetail = _MockGetEquipmentDetail();
    when(() => saveItem(any())).thenAnswer((_) async {});
    bloc = InventoryBloc(getInventory, deleteItem, saveItem, getDetail);
  });

  /// Carrega [items] e espera o estado de sucesso.
  Future<void> load(List<InventoryItem> items) async {
    when(() => getInventory(characterId)).thenAnswer((_) async => items);
    bloc.add(const LoadInventoryEvent(characterId));
    await bloc.stream.firstWhere((s) => s.status == InventoryStatus.success);
  }

  /// Espera o bloc processar os eventos já enfileirados.
  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  List<InventoryItem> saved() =>
      verify(() => saveItem(captureAny())).captured.cast<InventoryItem>();

  InventoryItem armor(String id, String category, {bool equipped = false}) =>
      buildItem(id).copyWith(
        equipmentCategory: 'Armor',
        armorCategory: category,
        armorBase: 14,
        equipped: equipped,
      );

  group('equipamento', () {
    test('equipar armadura troca a armadura equipada antes', () async {
      final old = armor('scale', 'Medium', equipped: true);
      final plate = armor('plate', 'Heavy');
      await load([old, plate]);

      bloc.add(ToggleEquippedEvent(plate));
      await settle();

      expect(saved().map((i) => (i.id, i.equipped)), [
        ('plate', true),
        ('scale', false),
      ]);
    });

    test('não sintoniza mais de 3 itens', () async {
      final ring = buildItem('ring').copyWith(requiresAttunement: true);
      await load([
        for (final id in ['a', 'b', 'c'])
          buildItem(id).copyWith(requiresAttunement: true, attuned: true),
        ring,
      ]);

      bloc.add(ToggleAttunedEvent(ring));
      final state = await bloc.stream.firstWhere((s) => s.errorMessage != null);

      expect(state.errorMessage, contains('3'));
      verifyNever(() => saveItem(any()));
    });

    test('quantidade 0 remove o item', () async {
      when(() => deleteItem('sword')).thenAnswer((_) async {});
      await load([sword]);

      bloc.add(SetItemQuantityEvent(sword, 0));
      await settle();

      verify(() => deleteItem('sword')).called(1);
    });

    test('quantidade maior salva o item com a quantidade nova', () async {
      await load([sword]);

      bloc.add(SetItemQuantityEvent(sword, 3));
      await settle();

      expect(saved().single.quantity, 3);
    });

    test('itens antigos são completados pelo compêndio', () async {
      final oldItem = buildItem('longsword').copyWith(detailsLoaded: false);
      when(() => getDetail('longsword')).thenAnswer(
        (_) async => const EquipmentDetail(
          index: 'longsword',
          name: 'Longsword',
          equipmentCategory: 'Weapon',
          cost: EquipmentCost(quantity: 15, unit: 'gp'),
          weight: 3,
          desc: [],
          damage: EquipmentDamage(
            dice: '1d8',
            damageTypeIndex: 'slashing',
            damageTypeName: 'Slashing',
          ),
          weaponCategory: 'Martial',
          weaponRange: 'Melee',
          properties: ['versatile'],
        ),
      );

      await load([oldItem]);
      await settle();

      final completed = saved().single;
      expect(completed.detailsLoaded, isTrue);
      expect(completed.weight, 3);
      expect(completed.damageDice, '1d8');
      expect(completed.weaponCategory, 'Martial');
    });
  });

  tearDown(() => bloc.close());

  test('LoadInventoryEvent carrega os itens do personagem', () async {
    when(() => getInventory(characterId)).thenAnswer((_) async => [sword]);

    bloc.add(const LoadInventoryEvent(characterId));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == InventoryStatus.success,
    );

    expect(state.items, [sword]);
  });

  test('falha na carga emite o status failure', () async {
    when(() => getInventory(characterId)).thenThrow(Exception('db'));

    bloc.add(const LoadInventoryEvent(characterId));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == InventoryStatus.failure,
    );

    expect(state.errorMessage, isNotNull);
  });

  test('DeleteInventoryItemEvent remove o item e recarrega a lista', () async {
    when(
      () => getInventory(characterId),
    ).thenAnswer((_) async => [sword, shield]);
    when(() => deleteItem('sword')).thenAnswer((_) async {});

    bloc.add(const LoadInventoryEvent(characterId));
    await bloc.stream.firstWhere((s) => s.items.length == 2);

    when(() => getInventory(characterId)).thenAnswer((_) async => [shield]);
    bloc.add(DeleteInventoryItemEvent(sword));
    final state = await bloc.stream.firstWhere((s) => s.items.length == 1);

    verify(() => deleteItem('sword')).called(1);
    expect(state.items, [shield]);
  });

  test('falha na remoção mantém os itens e informa o erro', () async {
    when(() => getInventory(characterId)).thenAnswer((_) async => [sword]);
    when(() => deleteItem('sword')).thenThrow(Exception('db'));

    bloc.add(const LoadInventoryEvent(characterId));
    await bloc.stream.firstWhere((s) => s.status == InventoryStatus.success);

    bloc.add(DeleteInventoryItemEvent(sword));
    final state = await bloc.stream.firstWhere((s) => s.errorMessage != null);

    expect(state.items, [sword]);
    expect(state.status, InventoryStatus.success);
  });
}
