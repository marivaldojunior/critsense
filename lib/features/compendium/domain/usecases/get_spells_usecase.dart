import '../entities/spell_summary.dart';
import '../repositories/i_compendium_repository.dart';

/// Caso de uso responsável por buscar a lista de magias do compêndio.
class GetSpellsUseCase {
  final ICompendiumRepository _repository;

  const GetSpellsUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// Retorna a lista de [SpellSummary] ou lança exceção em caso de falha.
  Future<List<SpellSummary>> call() {
    return _repository.getSpells();
  }
}
