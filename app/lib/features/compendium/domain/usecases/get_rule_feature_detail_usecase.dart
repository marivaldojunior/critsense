import '../entities/rule_feature.dart';
import '../repositories/i_compendium_repository.dart';

/// Caso de uso que busca o texto de uma característica de classe ou de um
/// traço racial.
class GetRuleFeatureDetailUseCase {
  final ICompendiumRepository _repository;

  const GetRuleFeatureDetailUseCase(ICompendiumRepository repository)
    : _repository = repository;

  Future<RuleFeatureDetail> call(String index, RuleFeatureKind kind) {
    return _repository.getRuleFeatureDetail(index, kind);
  }
}
