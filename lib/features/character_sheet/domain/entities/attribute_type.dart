/// Identifica um dos seis atributos base para operações genéricas (ex: o
/// Point Buy incrementa/decrementa por tipo sem precisar de um switch por
/// atributo em cada chamador).
enum AttributeType {
  strength,
  dexterity,
  constitution,
  intelligence,
  wisdom,
  charisma;

  String get label => switch (this) {
    AttributeType.strength => 'Força',
    AttributeType.dexterity => 'Destreza',
    AttributeType.constitution => 'Constituição',
    AttributeType.intelligence => 'Inteligência',
    AttributeType.wisdom => 'Sabedoria',
    AttributeType.charisma => 'Carisma',
  };
}
