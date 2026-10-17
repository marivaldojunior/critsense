import 'api_reference.dart';

/// Características de classe ganhas num nível (sem as de subclasse).
class ClassLevelFeatures {
  final int level;
  final List<ApiReference> features;

  const ClassLevelFeatures({required this.level, required this.features});
}

/// Texto de uma característica de classe ou de um traço racial do SRD.
class RuleFeatureDetail {
  final String index;
  final String name;
  final List<String> desc;

  const RuleFeatureDetail({
    required this.index,
    required this.name,
    required this.desc,
  });
}

/// De onde vem a característica: da classe (`/features`) ou da raça
/// (`/traits`).
enum RuleFeatureKind { classFeature, racialTrait }
