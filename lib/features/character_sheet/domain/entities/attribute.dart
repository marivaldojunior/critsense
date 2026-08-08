import 'attribute_type.dart';
import 'point_buy_rules.dart';

/// Modificador de D&D 5e para um valor de atributo: `(valor - 10) / 2`,
/// arredondado para baixo (ex: 8 = -1, 10 = 0, 14 = +2).
int attributeModifier(int score) => ((score - 10) / 2).floor();

/// Representa os seis atributos base de um personagem de RPG.
///
/// Todos começam em [PointBuyRules.baseScore] por padrão, refletindo o
/// ponto de partida do sistema de Compra de Pontos.
class Attribute {
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  const Attribute({
    this.strength = PointBuyRules.baseScore,
    this.dexterity = PointBuyRules.baseScore,
    this.constitution = PointBuyRules.baseScore,
    this.intelligence = PointBuyRules.baseScore,
    this.wisdom = PointBuyRules.baseScore,
    this.charisma = PointBuyRules.baseScore,
  });

  /// Lê o valor do atributo identificado por [type], evitando um switch
  /// repetido em cada chamador que precise operar genericamente por tipo.
  int valueOf(AttributeType type) => switch (type) {
    AttributeType.strength => strength,
    AttributeType.dexterity => dexterity,
    AttributeType.constitution => constitution,
    AttributeType.intelligence => intelligence,
    AttributeType.wisdom => wisdom,
    AttributeType.charisma => charisma,
  };

  /// Retorna uma cópia com o atributo [type] substituído por [value].
  Attribute withValue(AttributeType type, int value) => switch (type) {
    AttributeType.strength => copyWith(strength: value),
    AttributeType.dexterity => copyWith(dexterity: value),
    AttributeType.constitution => copyWith(constitution: value),
    AttributeType.intelligence => copyWith(intelligence: value),
    AttributeType.wisdom => copyWith(wisdom: value),
    AttributeType.charisma => copyWith(charisma: value),
  };

  Attribute copyWith({
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
  }) {
    return Attribute(
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
    );
  }
}
