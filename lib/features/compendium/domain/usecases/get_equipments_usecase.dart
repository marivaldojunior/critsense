import '../entities/equipment_summary.dart';
import '../repositories/i_compendium_repository.dart';

/// Caso de uso responsável por buscar a lista de equipamentos do compêndio.
class GetEquipmentsUseCase {
  final ICompendiumRepository _repository;

  const GetEquipmentsUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// Retorna a lista de [EquipmentSummary] ou lança exceção em caso de falha.
  Future<List<EquipmentSummary>> call() {
    return _repository.getEquipments();
  }
}
