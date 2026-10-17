import '../entities/spell_detail.dart';
import '../repositories/i_compendium_repository.dart';

/// Caso de uso responsável por buscar os detalhes de uma magia pelo índice.
class GetSpellDetailUseCase {
  final ICompendiumRepository _repository;

  const GetSpellDetailUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// Retorna os detalhes da magia identificada por [index] ou lança exceção.
  Future<SpellDetail> call(String index) {
    return _repository.getSpellDetail(index);
  }
}
