import '../entities/session_note.dart';
import '../repositories/i_character_repository.dart';

/// Caso de uso responsável por recuperar as notas de sessão de um personagem.
class GetSessionNotesUseCase {
  final ICharacterRepository _repository;

  /// Injeta o [repository] via construtor.
  const GetSessionNotesUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Retorna as notas do personagem identificado por [characterId],
  /// ordenadas da mais recente para a mais antiga.
  Future<List<SessionNote>> call(String characterId) {
    return _repository.getSessionNotes(characterId);
  }
}
