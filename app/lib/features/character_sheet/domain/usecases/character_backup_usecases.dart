import '../entities/character.dart';
import '../repositories/i_character_repository.dart';

/// Caso de uso que gera o backup em JSON de um personagem.
class ExportCharacterUseCase {
  final ICharacterRepository _repository;

  const ExportCharacterUseCase(ICharacterRepository repository)
    : _repository = repository;

  Future<String> call(String characterId) =>
      _repository.exportCharacter(characterId);
}

/// Caso de uso que importa um backup em JSON como um personagem novo.
class ImportCharacterUseCase {
  final ICharacterRepository _repository;

  const ImportCharacterUseCase(ICharacterRepository repository)
    : _repository = repository;

  /// Lança [FormatException] se [json] não é um backup válido.
  Future<Character> call(String json) => _repository.importCharacter(json);
}
