import '../entities/api_reference.dart';
import '../repositories/i_compendium_repository.dart';

/// Caso de uso responsável por buscar a lista de raças jogáveis do D&D 5e.
class GetRacesUseCase {
  final ICompendiumRepository _repository;

  const GetRacesUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// Retorna a lista de [ApiReference] de raças ou lança exceção em caso de falha.
  Future<List<ApiReference>> call() {
    return _repository.getRaces();
  }
}
