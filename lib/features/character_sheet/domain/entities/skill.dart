import 'attribute_type.dart';

/// As 18 perícias da primeira página da ficha oficial de personagem do
/// D&D 5e, na mesma ordem em que aparecem no bloco "PERÍCIAS".
///
/// Cada perícia é regida por um [AttributeType] fixo — é esse atributo que
/// fornece o modificador base somado ao bônus de proficiência.
enum Skill {
  acrobatics(AttributeType.dexterity, 'Acrobacia', 'acrobatics'),
  animalHandling(
    AttributeType.wisdom,
    'Adestrar Animais',
    'animal-handling',
  ),
  arcana(AttributeType.intelligence, 'Arcanismo', 'arcana'),
  athletics(AttributeType.strength, 'Atletismo', 'athletics'),
  deception(AttributeType.charisma, 'Enganação', 'deception'),
  stealth(AttributeType.dexterity, 'Furtividade', 'stealth'),
  history(AttributeType.intelligence, 'História', 'history'),
  intimidation(AttributeType.charisma, 'Intimidação', 'intimidation'),
  insight(AttributeType.wisdom, 'Intuição', 'insight'),
  investigation(AttributeType.intelligence, 'Investigação', 'investigation'),
  medicine(AttributeType.wisdom, 'Medicina', 'medicine'),
  nature(AttributeType.intelligence, 'Natureza', 'nature'),
  perception(AttributeType.wisdom, 'Percepção', 'perception'),
  performance(AttributeType.charisma, 'Performance', 'performance'),
  persuasion(AttributeType.charisma, 'Persuasão', 'persuasion'),
  sleightOfHand(
    AttributeType.dexterity,
    'Prestidigitação',
    'sleight-of-hand',
  ),
  religion(AttributeType.intelligence, 'Religião', 'religion'),
  survival(AttributeType.wisdom, 'Sobrevivência', 'survival');

  /// Atributo base que rege esta perícia (ex: Furtividade → Destreza).
  final AttributeType attribute;

  /// Rótulo de exibição, igual ao texto da ficha oficial.
  final String label;

  /// Nome do arquivo (sem extensão) em `assets/icons/skill/`.
  final String _iconSlug;

  const Skill(this.attribute, this.label, this._iconSlug);

  /// Caminho do SVG temático desta perícia, para uso com o widget `DnDIcon`.
  String get iconAsset => 'assets/icons/skill/$_iconSlug.svg';
}
