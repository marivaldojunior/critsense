import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/delete_inventory_item_usecase.dart';
import '../../domain/usecases/get_character_inventory_usecase.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

/// BLoC do inventário de um personagem (aba "Inventário & Magias").
///
/// Os itens vivem numa tabela própria, separada do [Character] — por isso
/// não ficam no `CharacterBloc`. Itens adicionados pelo Compêndio entram
/// pelo `CharacterBloc` e aparecem aqui na próxima carga da aba.
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetCharacterInventoryUseCase _getInventory;
  final DeleteInventoryItemUseCase _deleteItem;

  /// Personagem dono do inventário, definido pelo último [LoadInventoryEvent].
  String? _characterId;

  /// Injeta os use cases e registra os handlers de eventos.
  InventoryBloc(
    GetCharacterInventoryUseCase getInventory,
    DeleteInventoryItemUseCase deleteItem,
  ) : _getInventory = getInventory,
      _deleteItem = deleteItem,
      super(const InventoryState()) {
    on<LoadInventoryEvent>(_onLoad);
    on<DeleteInventoryItemEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadInventoryEvent event,
    Emitter<InventoryState> emit,
  ) async {
    _characterId = event.characterId;
    emit(state.copyWith(status: InventoryStatus.loading));
    await _reload(emit);
  }

  Future<void> _onDelete(
    DeleteInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _deleteItem(event.item.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Não foi possível remover o item.'));
      return;
    }
    await _reload(emit);
  }

  Future<void> _reload(Emitter<InventoryState> emit) async {
    final characterId = _characterId;
    if (characterId == null) return;

    try {
      final items = await _getInventory(characterId);
      emit(state.copyWith(status: InventoryStatus.success, items: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryStatus.failure,
          errorMessage: 'Não foi possível carregar o inventário.',
        ),
      );
    }
  }
}
