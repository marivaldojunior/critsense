import '../entities/character_spell.dart';
import '../repositories/i_character_repository.dart';

/// Caso de uso que adiciona uma magia ao grimório ou atualiza uma magia dele
/// (nível, preparada).
class SaveCharacterSpellUseCase {
  final ICharacterRepository _repository;

  const SaveCharacterSpellUseCase(ICharacterRepository repository)
    : _repository = repository;

  Future<void> call(CharacterSpell spell) {
    return _repository.saveCharacterSpell(spell);
  }
}
