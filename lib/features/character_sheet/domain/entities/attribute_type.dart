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

  /// Nome do arquivo (sem extensão) em `assets/icons/ability/`.
  String get _iconSlug => switch (this) {
    AttributeType.strength => 'strength',
    AttributeType.dexterity => 'dexterity',
    AttributeType.constitution => 'constitution',
    AttributeType.intelligence => 'intelligence',
    AttributeType.wisdom => 'wisdom',
    AttributeType.charisma => 'charisma',
  };

  /// Caminho do SVG temático deste atributo, para uso com o widget `DnDIcon`.
  String get iconAsset => 'assets/icons/ability/$_iconSlug.svg';
}
