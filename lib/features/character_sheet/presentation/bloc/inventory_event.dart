part of 'inventory_bloc.dart';

/// Base selada para todos os eventos do [InventoryBloc].
sealed class InventoryEvent {
  const InventoryEvent();
}

/// Carrega o inventário do personagem [characterId].
final class LoadInventoryEvent extends InventoryEvent {
  final String characterId;

  const LoadInventoryEvent(this.characterId);
}

/// Remove [item] do inventário e recarrega a lista.
final class DeleteInventoryItemEvent extends InventoryEvent {
  final InventoryItem item;

  const DeleteInventoryItemEvent(this.item);
}
