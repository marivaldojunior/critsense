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

/// Define a quantidade de [item]; 0 remove o item.
final class SetItemQuantityEvent extends InventoryEvent {
  final InventoryItem item;
  final int quantity;

  const SetItemQuantityEvent(this.item, this.quantity);
}

/// Equipa ou desequipa [item] (arma, armadura ou escudo).
final class ToggleEquippedEvent extends InventoryEvent {
  final InventoryItem item;

  const ToggleEquippedEvent(this.item);
}

/// Liga ou desliga a sintonia com [item] (no máximo 3 itens).
final class ToggleAttunedEvent extends InventoryEvent {
  final InventoryItem item;

  const ToggleAttunedEvent(this.item);
}

/// Adiciona ou atualiza [item] (ex: um item personalizado).
final class SaveInventoryItemEvent extends InventoryEvent {
  final InventoryItem item;

  const SaveInventoryItemEvent(this.item);
}
