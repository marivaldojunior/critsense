import '../../domain/entities/attribute_type.dart';
import '../../domain/entities/proficiency.dart';
import '../../domain/entities/skill.dart';

// Chaves das proficiências no banco e no arquivo de backup — usam o `name`
// dos enums, então renomear um valor de [Skill] ou [AttributeType] exige uma
// migração dos dados salvos.
const _skillKeyPrefix = 'skill:';
const _savingThrowKeyPrefix = 'save:';

/// Chave de [proficiency], ex: `skill:stealth` ou `save:dexterity`.
String proficiencyToKey(Proficiency proficiency) => switch (proficiency) {
  SkillProficiency(:final skill) => '$_skillKeyPrefix${skill.name}',
  SavingThrowProficiency(:final attribute) =>
    '$_savingThrowKeyPrefix${attribute.name}',
};

/// Converte a chave salva de volta para a [Proficiency]. Uma chave
/// desconhecida (ex: valor de enum removido) vira `null` e é ignorada, em
/// vez de impedir a carga do personagem.
Proficiency? proficiencyFromKey(String key) {
  if (key.startsWith(_skillKeyPrefix)) {
    final name = key.substring(_skillKeyPrefix.length);
    final skill = Skill.values.where((s) => s.name == name).firstOrNull;
    return skill == null ? null : SkillProficiency(skill);
  }
  if (key.startsWith(_savingThrowKeyPrefix)) {
    final name = key.substring(_savingThrowKeyPrefix.length);
    final attribute = AttributeType.values
        .where((a) => a.name == name)
        .firstOrNull;
    return attribute == null ? null : SavingThrowProficiency(attribute);
  }
  return null;
}
