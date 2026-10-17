import '../repositories/i_character_repository.dart';

/// Caso de uso que remove uma magia do grimório.
class DeleteCharacterSpellUseCase {
  final ICharacterRepository _repository;

  const DeleteCharacterSpellUseCase(ICharacterRepository repository)
    : _repository = repository;

  Future<void> call(String spellId) {
    return _repository.deleteCharacterSpell(spellId);
  }
}
