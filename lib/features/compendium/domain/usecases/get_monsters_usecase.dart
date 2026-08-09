import '../entities/monster_summary.dart';
import '../repositories/i_compendium_repository.dart';

/// Caso de uso responsável por buscar uma página de monstros do compêndio.
///
/// Recebe [offset] e [limit] para paginar a coleção, delegando ao repositório
/// a decisão de buscar novos dados ou servir de um cache já preenchido.
class GetMonstersUseCase {
  final ICompendiumRepository _repository;

  const GetMonstersUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// Retorna a fatia de [MonsterSummary] correspondente à página solicitada,
  /// dentre os monstros que casam com [name]/[challengeRating] quando
  /// informados.
  ///
  /// [offset] — índice do primeiro item desejado.
  /// [limit]  — quantidade máxima de itens a retornar.
  Future<List<MonsterSummary>> call({
    required int offset,
    required int limit,
    String? name,
    num? challengeRating,
  }) {
    return _repository.getMonsters(
      offset: offset,
      limit: limit,
      name: name,
      challengeRating: challengeRating,
    );
  }
}
