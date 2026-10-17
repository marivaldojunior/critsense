import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/compendium/domain/usecases/get_equipment_detail_usecase.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/mappers/equipment_mapper.dart';
import '../../domain/rules/equipment_rules.dart';
import '../../domain/usecases/add_inventory_item_usecase.dart';
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
  final AddInventoryItemUseCase _saveItem;
  final GetEquipmentDetailUseCase _getEquipmentDetail;

  /// Personagem dono do inventário, definido pelo último [LoadInventoryEvent].
  String? _characterId;

  /// Injeta os use cases e registra os handlers de eventos.
  InventoryBloc(
    GetCharacterInventoryUseCase getInventory,
    DeleteInventoryItemUseCase deleteItem,
    AddInventoryItemUseCase saveItem,
    GetEquipmentDetailUseCase getEquipmentDetail,
  ) : _getInventory = getInventory,
      _deleteItem = deleteItem,
      _saveItem = saveItem,
      _getEquipmentDetail = getEquipmentDetail,
      super(const InventoryState()) {
    on<LoadInventoryEvent>(_onLoad);
    on<DeleteInventoryItemEvent>(_onDelete);
    on<SetItemQuantityEvent>(_onSetQuantity);
    on<ToggleEquippedEvent>(
      (event, emit) => _saveAll(emit, toggleEquipped(event.item, state.items)),
    );
    on<ToggleAttunedEvent>(_onToggleAttuned);
    on<SaveInventoryItemEvent>((event, emit) => _saveAll(emit, [event.item]));
  }

  Future<void> _onSetQuantity(
    SetItemQuantityEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (event.quantity <= 0) {
      add(DeleteInventoryItemEvent(event.item));
      return;
    }
    await _saveAll(emit, [event.item.copyWith(quantity: event.quantity)]);
  }

  Future<void> _onToggleAttuned(
    ToggleAttunedEvent event,
    Emitter<InventoryState> emit,
  ) async {
    final item = event.item;
    if (!item.attuned && attunedCount(state.items) >= maxAttunedItems) {
      emit(
        state.copyWith(
          errorMessage:
              'Limite de $maxAttunedItems itens sintonizados. Desfaça a '
              'sintonia com outro item primeiro.',
        ),
      );
      return;
    }
    await _saveAll(emit, [item.copyWith(attuned: !item.attuned)]);
  }

  Future<void> _saveAll(
    Emitter<InventoryState> emit,
    List<InventoryItem> items,
  ) async {
    try {
      for (final item in items) {
        await _saveItem(item);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Não foi possível salvar o item.'));
      return;
    }
    await _reload(emit);
  }

  /// Completa pelo compêndio os itens antigos, que só tinham nome e
  /// categoria. Sem internet, eles ficam como estão até a próxima abertura.
  Future<void> _completeDetails(Emitter<InventoryState> emit) async {
    final incomplete = state.items.where(
      (i) => !i.detailsLoaded && !i.isCustom,
    );
    var changed = false;
    for (final item in incomplete) {
      try {
        final detail = await _getEquipmentDetail(item.itemIndex);
        await _saveItem(withEquipmentDetails(item, detail));
        changed = true;
      } catch (_) {
        // Tenta de novo na próxima carga.
      }
    }
    if (changed) await _reload(emit);
  }

  Future<void> _onLoad(
    LoadInventoryEvent event,
    Emitter<InventoryState> emit,
  ) async {
    _characterId = event.characterId;
    emit(state.copyWith(status: InventoryStatus.loading));
    await _reload(emit);
    await _completeDetails(emit);
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
