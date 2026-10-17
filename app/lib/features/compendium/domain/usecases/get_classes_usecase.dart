import '../entities/api_reference.dart';
import '../repositories/i_compendium_repository.dart';

/// Caso de uso responsável por buscar a lista de classes jogáveis do D&D 5e.
class GetClassesUseCase {
  final ICompendiumRepository _repository;

  const GetClassesUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// Retorna a lista de [ApiReference] de classes ou lança exceção em caso de falha.
  Future<List<ApiReference>> call() {
    return _repository.getClasses();
  }
}
