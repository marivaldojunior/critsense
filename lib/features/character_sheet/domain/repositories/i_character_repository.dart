import '../entities/character.dart';
import '../entities/inventory_item.dart';

/// Contrato para persistência e recuperação de personagens.
abstract interface class ICharacterRepository {
  /// Persiste ou atualiza um [character] no repositório.
  Future<void> saveCharacter(Character character);

  /// Retorna todos os personagens armazenados.
  Future<List<Character>> getAllCharacters();

  /// Remove o personagem identificado por [id] do repositório.
  Future<void> deleteCharacter(String id);

  /// Adiciona [item] ao inventário do personagem referenciado.
  Future<void> addInventoryItem(InventoryItem item);

  /// Retorna todos os itens do personagem identificado por [characterId].
  Future<List<InventoryItem>> getCharacterInventory(String characterId);
}
