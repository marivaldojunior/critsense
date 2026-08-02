import '../entities/session_note.dart';
import '../repositories/i_character_repository.dart';

/// Caso de uso responsável por persistir uma nova nota de sessão.
class AddSessionNoteUseCase {
  final ICharacterRepository _repository;

  /// Injeta o [repository] via construtor.
  const AddSessionNoteUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Persiste [note] no repositório ou lança exceção em caso de falha.
  Future<void> call(SessionNote note) {
    return _repository.addSessionNote(note);
  }
}
