import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/inventory_item.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_inventory_item_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_character_inventory_usecase.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/inventory_bloc.dart';

class _MockGetCharacterInventoryUseCase extends Mock
    implements GetCharacterInventoryUseCase {}

class _MockDeleteInventoryItemUseCase extends Mock
    implements DeleteInventoryItemUseCase {}

/// Testa a carga e a remoção de itens no [InventoryBloc].
void main() {
  late _MockGetCharacterInventoryUseCase getInventory;
  late _MockDeleteInventoryItemUseCase deleteItem;
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

  setUp(() {
    getInventory = _MockGetCharacterInventoryUseCase();
    deleteItem = _MockDeleteInventoryItemUseCase();
    bloc = InventoryBloc(getInventory, deleteItem);
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
