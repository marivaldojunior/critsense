import '../repositories/i_character_repository.dart';

/// Caso de uso responsável por remover uma nota de sessão pelo seu identificador.
class DeleteSessionNoteUseCase {
  final ICharacterRepository _repository;

  /// Injeta o [repository] via construtor.
  const DeleteSessionNoteUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Remove a nota identificada por [noteId] ou lança exceção em caso de falha.
  Future<void> call(String noteId) {
    return _repository.deleteSessionNote(noteId);
  }
}
