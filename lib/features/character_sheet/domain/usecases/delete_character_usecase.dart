import '../repositories/i_character_repository.dart';

/// Caso de uso responsável por remover um personagem pelo seu identificador.
class DeleteCharacterUseCase {
  final ICharacterRepository _repository;

  /// Injeta o [repository] via construtor.
  const DeleteCharacterUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Remove o personagem com o [id] fornecido ou lança exceção em caso de falha.
  Future<void> call(String id) {
    return _repository.deleteCharacter(id);
  }
}
