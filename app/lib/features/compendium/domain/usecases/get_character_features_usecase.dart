import '../entities/api_reference.dart';
import '../entities/rule_feature.dart';
import '../repositories/i_compendium_repository.dart';

/// Características de classe (até o nível do personagem) e traços raciais.
typedef CharacterFeatures = ({
  List<ClassLevelFeatures> classFeatures,
  List<ApiReference> racialTraits,
});

/// Caso de uso que busca no compêndio as características de classe e os
/// traços raciais de um personagem.
class GetCharacterFeaturesUseCase {
  final ICompendiumRepository _repository;

  const GetCharacterFeaturesUseCase(ICompendiumRepository repository)
    : _repository = repository;

  /// [classIndex] e [raceIndex] são índices da API; `null` pula a parte
  /// correspondente (classe ou raça fora do SRD).
  Future<CharacterFeatures> call({
    required String? classIndex,
    required String? raceIndex,
    required int level,
  }) async {
    final classFeatures = classIndex == null
        ? Future.value(const <ClassLevelFeatures>[])
        : _repository.getClassFeatures(classIndex, upToLevel: level);
    final racialTraits = raceIndex == null
        ? Future.value(const <ApiReference>[])
        : _repository.getRaceTraits(raceIndex);
    return (
      classFeatures: await classFeatures,
      racialTraits: await racialTraits,
    );
  }
}
