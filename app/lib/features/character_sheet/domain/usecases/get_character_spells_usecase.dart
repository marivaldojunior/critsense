import '../entities/character_spell.dart';
import '../repositories/i_character_repository.dart';

/// Caso de uso que lê o grimório de um personagem.
class GetCharacterSpellsUseCase {
  final ICharacterRepository _repository;

  const GetCharacterSpellsUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Magias do personagem [characterId], por nível e nome.
  Future<List<CharacterSpell>> call(String characterId) {
    return _repository.getCharacterSpells(characterId);
  }
}
