import '../entities/api_reference.dart';
import '../entities/rule_feature.dart';
import '../repositories/i_compendium_repository.dart';

/// Características de classe e de subclasse (até o nível do personagem) e
/// traços raciais.
typedef CharacterFeatures = ({
  List<ClassLevelFeatures> classFeatures,
  List<ClassLevelFeatures> subclassFeatures,
  List<ApiReference> racialTraits,
});

/// Caso de uso que busca no compêndio as características de classe e os
/// traços raciais de um personagem.
class GetCharacterFeaturesUseCase {
  final ICompendiumRepository _repository;

  const GetCharacterFeaturesUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// [classIndex], [subclassIndex] e [raceIndex] são índices da API; `null`
  /// pula a parte correspondente (fora do SRD ou ainda sem subclasse).
  Future<CharacterFeatures> call({
    required String? classIndex,
    required String? raceIndex,
    required int level,
    String? subclassIndex,
  }) async {
    final classFeatures = classIndex == null
        ? Future.value(const <ClassLevelFeatures>[])
        : _repository.getClassFeatures(classIndex, upToLevel: level);
    final subclassFeatures = subclassIndex == null
        ? Future.value(const <ClassLevelFeatures>[])
        : _repository.getSubclassFeatures(subclassIndex, upToLevel: level);
    final racialTraits = raceIndex == null
        ? Future.value(const <ApiReference>[])
        : _repository.getRaceTraits(raceIndex);
    return (
      classFeatures: await classFeatures,
      subclassFeatures: await subclassFeatures,
      racialTraits: await racialTraits,
    );
  }
}
