import '../entities/character.dart';
import '../repositories/i_character_repository.dart';

/// Caso de uso responsável por recuperar todos os personagens persistidos.
class GetAllCharactersUseCase {
  final ICharacterRepository _repository;

  /// Injeta o [repository] via construtor.
  const GetAllCharactersUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Retorna a lista completa de personagens ou lança exceção em caso de falha.
  Future<List<Character>> call() {
    return _repository.getAllCharacters();
  }
}
