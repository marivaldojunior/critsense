import 'attribute_type.dart';
import 'skill.dart';

/// Marca que o personagem é proficiente em algo do bloco de Perícias ou de
/// Testes de Resistência da ficha — os dois únicos tipos de proficiência
/// da primeira página que somam o Bônus de Proficiência a uma rolagem.
///
/// `sealed` para que o cruzamento com [Skill]/[AttributeType] no cálculo do
/// [CharacterBloc] use `switch`/[List.contains] de forma exaustiva e
/// type-safe, sem precisar de um campo `type` textual solto na entidade.
sealed class Proficiency {
  const Proficiency();
}

/// Proficiência em uma perícia específica (ex: Furtividade).
class SkillProficiency extends Proficiency {
  final Skill skill;

  const SkillProficiency(this.skill);

  @override
  bool operator ==(Object other) =>
      other is SkillProficiency && other.skill == skill;

  @override
  int get hashCode => Object.hash(SkillProficiency, skill);
}

/// Proficiência no Teste de Resistência de um atributo (ex: Destreza).
class SavingThrowProficiency extends Proficiency {
  final AttributeType attribute;

  const SavingThrowProficiency(this.attribute);

  @override
  bool operator ==(Object other) =>
      other is SavingThrowProficiency && other.attribute == attribute;

  @override
  int get hashCode => Object.hash(SavingThrowProficiency, attribute);
}
