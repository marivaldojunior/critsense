import '../entities/inventory_item.dart';
import '../repositories/i_character_repository.dart';

/// Caso de uso responsável por adicionar um item ao inventário de um personagem.
class AddInventoryItemUseCase {
  final ICharacterRepository _repository;

  const AddInventoryItemUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Persiste [item] no inventário ou lança exceção em caso de falha.
  Future<void> call(InventoryItem item) {
    return _repository.addInventoryItem(item);
  }
}
