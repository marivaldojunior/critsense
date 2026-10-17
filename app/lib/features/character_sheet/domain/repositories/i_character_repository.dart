import '../entities/character.dart';
import '../entities/character_spell.dart';
import '../entities/inventory_item.dart';
import '../entities/session_note.dart';

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

  /// Remove o item de inventário identificado por [itemId] do repositório.
  Future<void> deleteInventoryItem(String itemId);

  /// Retorna as notas de sessão do personagem identificado por [characterId],
  /// ordenadas da mais recente para a mais antiga.
  Future<List<SessionNote>> getSessionNotes(String characterId);

  /// Persiste [note] vinculada ao personagem referenciado em [SessionNote.characterId].
  Future<void> addSessionNote(SessionNote note);

  /// Remove a nota identificada por [noteId] do repositório.
  Future<void> deleteSessionNote(String noteId);

  /// Magias do grimório do personagem [characterId], por nível e nome.
  Future<List<CharacterSpell>> getCharacterSpells(String characterId);

  /// Salva [spell] (insere ou atualiza). Se o personagem já tem uma magia
  /// com o mesmo `spellIndex`, a existente é atualizada em vez de duplicar.
  Future<void> saveCharacterSpell(CharacterSpell spell);

  /// Remove a magia [spellId] do grimório.
  Future<void> deleteCharacterSpell(String spellId);

  /// Backup em JSON do personagem [characterId], com inventário, grimório e
  /// diário de campanha.
  Future<String> exportCharacter(String characterId);

  /// Importa um backup em JSON como um personagem novo (ids novos) e o
  /// devolve. Lança [FormatException] se o arquivo não é um backup válido.
  Future<Character> importCharacter(String json);
}
