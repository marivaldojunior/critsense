import '../entities/inventory_item.dart';
import '../repositories/i_character_repository.dart';

/// Caso de uso responsável por recuperar o inventário de um personagem.
class GetCharacterInventoryUseCase {
  final ICharacterRepository _repository;

  const GetCharacterInventoryUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Retorna todos os itens do personagem identificado por [characterId].
  Future<List<InventoryItem>> call(String characterId) {
    return _repository.getCharacterInventory(characterId);
  }
}
