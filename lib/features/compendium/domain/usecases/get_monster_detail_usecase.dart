import '../entities/monster_detail.dart';
import '../repositories/i_compendium_repository.dart';

/// Caso de uso responsável por buscar os detalhes de um monstro pelo índice.
class GetMonsterDetailUseCase {
  final ICompendiumRepository _repository;

  const GetMonsterDetailUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// Retorna os detalhes do monstro identificado por [index] ou lança exceção.
  Future<MonsterDetail> call(String index) {
    return _repository.getMonsterDetail(index);
  }
}
