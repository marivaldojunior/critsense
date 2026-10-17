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
  ),
  bard(
    'bard',
    hitDie: 8,
    savingThrows: {AttributeType.dexterity, AttributeType.charisma},
    spellcasting: Spellcasting.full,
    spellcastingAbility: AttributeType.charisma,
  ),
  cleric(
    'cleric',
    hitDie: 8,
    savingThrows: {AttributeType.wisdom, AttributeType.charisma},
    spellcasting: Spellcasting.full,
    spellcastingAbility: AttributeType.wisdom,
    preparesSpells: true,
  ),
  druid(
    'druid',
    hitDie: 8,
    savingThrows: {AttributeType.intelligence, AttributeType.wisdom},
    spellcasting: Spellcasting.full,
    spellcastingAbility: AttributeType.wisdom,
    preparesSpells: true,
  ),
  fighter(
    'fighter',
    hitDie: 10,
    savingThrows: {AttributeType.strength, AttributeType.constitution},
  ),
  monk(
    'monk',
    hitDie: 8,
    savingThrows: {AttributeType.strength, AttributeType.dexterity},
  ),
  paladin(
    'paladin',
    hitDie: 10,
    savingThrows: {AttributeType.wisdom, AttributeType.charisma},
    spellcasting: Spellcasting.half,
    spellcastingAbility: AttributeType.charisma,
    preparesSpells: true,
  ),
  ranger(
    'ranger',
    hitDie: 10,
    savingThrows: {AttributeType.strength, AttributeType.dexterity},
    spellcasting: Spellcasting.half,
    spellcastingAbility: AttributeType.wisdom,
  ),
  rogue(
    'rogue',
    hitDie: 8,
    savingThrows: {AttributeType.dexterity, AttributeType.intelligence},
  ),
  sorcerer(
    'sorcerer',
    hitDie: 6,
    savingThrows: {AttributeType.constitution, AttributeType.charisma},
    spellcasting: Spellcasting.full,
    spellcastingAbility: AttributeType.charisma,
  ),
  warlock(
    'warlock',
    hitDie: 8,
    savingThrows: {AttributeType.wisdom, AttributeType.charisma},
    spellcasting: Spellcasting.pact,
    spellcastingAbility: AttributeType.charisma,
  ),
  wizard(
    'wizard',
    hitDie: 6,
    savingThrows: {AttributeType.intelligence, AttributeType.wisdom},
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
    this.spellcasting = Spellcasting.none,
    this.spellcastingAbility,
    this.preparesSpells = false,
  });

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
