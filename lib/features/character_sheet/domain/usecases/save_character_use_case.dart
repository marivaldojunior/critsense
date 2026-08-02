import '../entities/character.dart';
import '../repositories/i_character_repository.dart';

/// Caso de uso responsável por persistir um personagem.
///
/// Encapsula a regra de negócio de salvar, delegando ao repositório
/// a estratégia concreta de armazenamento.
class SaveCharacterUseCase {
  /// Repositório utilizado para salvar o personagem.
  final ICharacterRepository _repository;

  /// Cria o caso de uso injetando a dependência do [repository].
  const SaveCharacterUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Executa a persistência do [character].
  ///
  /// Lança exceção propagada pelo repositório em caso de falha.
  Future<void> call(Character character) {
    return _repository.saveCharacter(character);
  }
}
