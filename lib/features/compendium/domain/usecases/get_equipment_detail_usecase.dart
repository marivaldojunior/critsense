import '../entities/equipment_detail.dart';
import '../repositories/i_compendium_repository.dart';

/// Caso de uso responsável por buscar os detalhes de um equipamento pelo índice.
class GetEquipmentDetailUseCase {
  final ICompendiumRepository _repository;

  const GetEquipmentDetailUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// Retorna os detalhes do equipamento identificado por [index] ou lança exceção.
  Future<EquipmentDetail> call(String index) {
    return _repository.getEquipmentDetail(index);
  }
}
