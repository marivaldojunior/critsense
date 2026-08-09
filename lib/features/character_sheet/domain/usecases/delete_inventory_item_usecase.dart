import '../repositories/i_character_repository.dart';

/// Caso de uso responsável por remover um item do inventário de um personagem.
class DeleteInventoryItemUseCase {
  final ICharacterRepository _repository;

  const DeleteInventoryItemUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Remove o item identificado por [itemId] ou lança exceção em caso de falha.
  Future<void> call(String itemId) {
    return _repository.deleteInventoryItem(itemId);
  }
}
