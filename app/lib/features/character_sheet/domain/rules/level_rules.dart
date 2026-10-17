import '../entities/attribute.dart';
import '../entities/attribute_type.dart';
import '../entities/character.dart';
import '../srd/srd_class.dart';
import '../srd/srd_race.dart';
import 'srd_rules.dart';

/// Regras de evolução do SRD 5.1 como transformações puras de [Character].
extension LevelRules on Character {
  /// O personagem ainda pode subir de nível (o máximo é o 20º).
  bool get canLevelUp => level < maxCharacterLevel;

  /// O XP já chega ao próximo nível.
  bool get isReadyToLevelUp {
    final next = experienceForNextLevel(level);
    return next != null && experiencePoints >= next;
  }

  /// O próximo nível dá um Aumento de Valor de Atributo.
  bool get nextLevelHasAbilityScoreImprovement =>
      SrdClass.abilityScoreImprovementLevelsFor(srdClass).contains(level + 1);

  /// Valor fixo (média) do dado de vida no próximo nível, sem a CON.
  int get averageHitDieGain => hitDie ~/ 2 + 1;

  /// Soma [amount] de XP (nunca abaixo de 0).
  Character withExperienceAdded(int amount) {
    final total = experiencePoints + amount;
    return copyWith(experiencePoints: total < 0 ? 0 : total);
  }

  /// Sobe um nível.
  ///
  /// - [hitDieResult]: o valor do dado de vida (rolado ou a média), sem a
  ///   CON. O ganho de PV do nível é esse valor + o modificador de CON novo,
  ///   no mínimo 1.
  /// - [abilityIncreases]: pontos do Aumento de Valor de Atributo (+2 num
  ///   atributo ou +1 em dois). Nenhum atributo passa de 20.
  /// - Se a CON sobe e o modificador muda, os níveis anteriores também
  ///   ganham a diferença (regra do SRD).
  ///
  /// Os PV atuais sobem junto com o máximo. Devolve `null` no 20º nível.
  Character? withLevelUp({
    required int hitDieResult,
    Map<AttributeType, int> abilityIncreases = const {},
  }) {
    if (!canLevelUp) return null;
    final oldConModifier = modifierOf(AttributeType.constitution);

    var newAttributes = attributes;
    abilityIncreases.forEach((attribute, increase) {
      final value = (newAttributes.valueOf(attribute) + increase).clamp(
        1,
        maxAbilityScore,
      );
      newAttributes = newAttributes.withValue(attribute, value);
    });
    final newConModifier = attributeModifier(newAttributes.constitution);

    final levelGain = hitDieResult + newConModifier;
    final retroactive = (newConModifier - oldConModifier) * level;
    final hitPointGain = (levelGain < 1 ? 1 : levelGain) + retroactive;

    return copyWith(
      level: level + 1,
      attributes: newAttributes,
      maxHitPoints: maxHitPoints + hitPointGain,
      currentHitPoints: (currentHitPoints + hitPointGain).clamp(
        0,
        maxHitPoints + hitPointGain,
      ),
    );
  }
}

/// O Aumento de Valor de Atributo é válido: +2 num atributo ou +1 em dois
/// diferentes, sem passar de 20.
bool isValidAbilityScoreImprovement(
  Attribute attributes,
  Map<AttributeType, int> increases,
) {
  final total = increases.values.fold(0, (sum, v) => sum + v);
  if (total != 2) return false;
  if (increases.values.any((v) => v < 1 || v > 2)) return false;
  return increases.entries.every(
    (e) => attributes.valueOf(e.key) + e.value <= maxAbilityScore,
  );
}
