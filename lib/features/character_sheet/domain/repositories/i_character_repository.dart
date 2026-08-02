import '../entities/character.dart';

/// Contrato para persistência e recuperação de personagens.
abstract interface class ICharacterRepository {
  /// Persiste ou atualiza um [character] no repositório.
  Future<void> saveCharacter(Character character);

  /// Retorna todos os personagens armazenados.
  Future<List<Character>> getAllCharacters();

  /// Remove o personagem identificado por [id] do repositório.
  Future<void> deleteCharacter(String id);
}
