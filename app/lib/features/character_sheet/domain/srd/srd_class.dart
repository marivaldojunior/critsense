import '../entities/attribute_type.dart';

/// Progressão de espaços de magia de uma classe (tabelas do SRD 5.1).
enum Spellcasting {
  /// Sem espaços de magia.
  none,

  /// Conjurador completo: Bardo, Clérigo, Druida, Feiticeiro e Mago.
  full,

  /// Meio-conjurador: Paladino e Patrulheiro (magia a partir do 2º nível).
  half,

  /// Magia de Pacto do Bruxo: poucos espaços, todos do mesmo nível, que
  /// voltam no Descanso Curto.
  pact,
}

/// As 12 classes do SRD 5.1 com os dados de regra que a ficha calcula
/// sozinha (dado de vida, testes de resistência...).
///
/// O personagem guarda a classe como o nome vindo da API 5e-bits (ex:
/// "Fighter"); [SrdClass.fromName] faz a ponte. Uma classe fora do SRD
/// devolve `null`, e a ficha usa valores neutros (d8, sem magia).
enum SrdClass {
  barbarian(
    'barbarian',
    hitDie: 12,
    savingThrows: {AttributeType.strength, AttributeType.constitution},
    armorTraining: {'light', 'medium', 'shield'},
    weaponCategories: {'simple', 'martial'},
  ),
  bard(
    'bard',
    hitDie: 8,
    savingThrows: {AttributeType.dexterity, AttributeType.charisma},
    armorTraining: {'light'},
    weaponCategories: {'simple'},
    weaponIndices: {'crossbow-hand', 'longsword', 'rapier', 'shortsword'},
    spellcasting: Spellcasting.full,
    spellcastingAbility: AttributeType.charisma,
  ),
  cleric(
    'cleric',
    hitDie: 8,
    savingThrows: {AttributeType.wisdom, AttributeType.charisma},
    armorTraining: {'light', 'medium', 'shield'},
    weaponCategories: {'simple'},
    spellcasting: Spellcasting.full,
    spellcastingAbility: AttributeType.wisdom,
    preparesSpells: true,
  ),
  druid(
    'druid',
    hitDie: 8,
    savingThrows: {AttributeType.intelligence, AttributeType.wisdom},
    armorTraining: {'light', 'medium', 'shield'},
    weaponCategories: {},
    weaponIndices: {
      'club',
      'dagger',
      'dart',
      'javelin',
      'mace',
      'quarterstaff',
      'scimitar',
      'sickle',
      'sling',
      'spear',
    },
    spellcasting: Spellcasting.full,
    spellcastingAbility: AttributeType.wisdom,
    preparesSpells: true,
  ),
  fighter(
    'fighter',
    hitDie: 10,
    savingThrows: {AttributeType.strength, AttributeType.constitution},
    armorTraining: {'light', 'medium', 'heavy', 'shield'},
    weaponCategories: {'simple', 'martial'},
  ),
  monk(
    'monk',
    hitDie: 8,
    savingThrows: {AttributeType.strength, AttributeType.dexterity},
    armorTraining: {},
    weaponCategories: {'simple'},
    weaponIndices: {'shortsword'},
  ),
  paladin(
    'paladin',
    hitDie: 10,
    savingThrows: {AttributeType.wisdom, AttributeType.charisma},
    armorTraining: {'light', 'medium', 'heavy', 'shield'},
    weaponCategories: {'simple', 'martial'},
    spellcasting: Spellcasting.half,
    spellcastingAbility: AttributeType.charisma,
    preparesSpells: true,
  ),
  ranger(
    'ranger',
    hitDie: 10,
    savingThrows: {AttributeType.strength, AttributeType.dexterity},
    armorTraining: {'light', 'medium', 'shield'},
    weaponCategories: {'simple', 'martial'},
    spellcasting: Spellcasting.half,
    spellcastingAbility: AttributeType.wisdom,
  ),
  rogue(
    'rogue',
    hitDie: 8,
    savingThrows: {AttributeType.dexterity, AttributeType.intelligence},
    armorTraining: {'light'},
    weaponCategories: {'simple'},
    weaponIndices: {'crossbow-hand', 'longsword', 'rapier', 'shortsword'},
  ),
  sorcerer(
    'sorcerer',
    hitDie: 6,
    savingThrows: {AttributeType.constitution, AttributeType.charisma},
    armorTraining: {},
    weaponCategories: {},
    weaponIndices: {
      'dagger',
      'dart',
      'sling',
      'quarterstaff',
      'crossbow-light',
    },
    spellcasting: Spellcasting.full,
    spellcastingAbility: AttributeType.charisma,
  ),
  warlock(
    'warlock',
    hitDie: 8,
    savingThrows: {AttributeType.wisdom, AttributeType.charisma},
    armorTraining: {'light'},
    weaponCategories: {'simple'},
    spellcasting: Spellcasting.pact,
    spellcastingAbility: AttributeType.charisma,
  ),
  wizard(
    'wizard',
    hitDie: 6,
    savingThrows: {AttributeType.intelligence, AttributeType.wisdom},
    armorTraining: {},
    weaponCategories: {},
    weaponIndices: {
      'dagger',
      'dart',
      'sling',
      'quarterstaff',
      'crossbow-light',
    },
    spellcasting: Spellcasting.full,
    spellcastingAbility: AttributeType.intelligence,
    preparesSpells: true,
  );

  /// Índice da classe na API 5e-bits (`/api/classes/{index}`).
  final String apiIndex;

  /// Faces do dado de vida (d6, d8, d10 ou d12).
  final int hitDie;

  /// Testes de resistência em que a classe é proficiente.
  final Set<AttributeType> savingThrows;

  /// Armaduras em que a classe é proficiente: `light`, `medium`, `heavy` e
  /// `shield`.
  final Set<String> armorTraining;

  /// Categorias de arma em que a classe é proficiente: `simple`, `martial`.
  final Set<String> weaponCategories;

  /// Armas específicas (índices da API) fora das categorias acima, ex: o
  /// Ladino com `rapier`.
  final Set<String> weaponIndices;

  /// Como a classe ganha espaços de magia.
  final Spellcasting spellcasting;

  /// Atributo de conjuração, ou `null` em classes sem magia.
  final AttributeType? spellcastingAbility;

  /// `true` nas classes que preparam magias a cada dia (Clérigo, Druida,
  /// Mago e Paladino); as outras só conhecem uma lista fixa.
  final bool preparesSpells;

  const SrdClass(
    this.apiIndex, {
    required this.hitDie,
    required this.savingThrows,
    required this.armorTraining,
    required this.weaponCategories,
    this.weaponIndices = const {},
    this.spellcasting = Spellcasting.none,
    this.spellcastingAbility,
    this.preparesSpells = false,
  });

  /// A classe é proficiente com a arma de índice [weaponIndex] e categoria
  /// [weaponCategory] ("Simple" ou "Martial").
  bool isProficientWithWeapon(String weaponIndex, String? weaponCategory) {
    final category = weaponCategory?.toLowerCase();
    return (category != null && weaponCategories.contains(category)) ||
        weaponIndices.contains(weaponIndex);
  }

  /// Níveis com Aumento de Valor de Atributo: 4, 8, 12, 16 e 19 em todas as
  /// classes, mais 6 e 14 no Guerreiro e 10 no Ladino.
  Set<int> get abilityScoreImprovementLevels => {
    4,
    8,
    12,
    16,
    19,
    if (this == fighter) ...{6, 14},
    if (this == rogue) 10,
  };

  /// Níveis de Aumento de Valor de Atributo de uma classe que pode não ser
  /// do SRD (fora do SRD, vale a tabela comum).
  static Set<int> abilityScoreImprovementLevelsFor(SrdClass? srdClass) =>
      srdClass?.abilityScoreImprovementLevels ?? {4, 8, 12, 16, 19};

  /// Dado de vida usado quando a classe não é do SRD.
  static const int defaultHitDie = 8;

  /// Encontra a classe pelo nome ou índice da API (sem diferenciar
  /// maiúsculas). Devolve `null` para classes fora do SRD.
  static SrdClass? fromName(String name) {
    final key = name.trim().toLowerCase();
    for (final srdClass in values) {
      if (srdClass.apiIndex == key) return srdClass;
    }
    return null;
  }
}
