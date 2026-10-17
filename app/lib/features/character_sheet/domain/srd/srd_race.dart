import '../entities/attribute.dart';
import '../entities/attribute_type.dart';

/// As 9 raças do SRD 5.1 com os dados que a ficha aplica na criação.
///
/// O personagem guarda a raça como o nome da API 5e-bits (ex: "Half-Elf");
/// [SrdRace.fromName] faz a ponte. Uma raça fora do SRD devolve `null`, e a
/// ficha não aplica bônus.
enum SrdRace {
  dragonborn(
    'dragonborn',
    abilityBonuses: {AttributeType.strength: 2, AttributeType.charisma: 1},
    speed: 30,
    languages: ['Comum', 'Dracônico'],
  ),
  dwarf(
    'dwarf',
    abilityBonuses: {AttributeType.constitution: 2},
    speed: 25,
    languages: ['Comum', 'Anão'],
  ),
  elf(
    'elf',
    abilityBonuses: {AttributeType.dexterity: 2},
    speed: 30,
    languages: ['Comum', 'Élfico'],
  ),
  gnome(
    'gnome',
    abilityBonuses: {AttributeType.intelligence: 2},
    speed: 25,
    languages: ['Comum', 'Gnômico'],
  ),
  halfElf(
    'half-elf',
    abilityBonuses: {AttributeType.charisma: 2},
    speed: 30,
    languages: ['Comum', 'Élfico'],
    extraLanguages: 1,
    chosenAbilityBonuses: 2,
  ),
  halfOrc(
    'half-orc',
    abilityBonuses: {AttributeType.strength: 2, AttributeType.constitution: 1},
    speed: 30,
    languages: ['Comum', 'Orc'],
  ),
  halfling(
    'halfling',
    abilityBonuses: {AttributeType.dexterity: 2},
    speed: 25,
    languages: ['Comum', 'Halfling'],
  ),
  human(
    'human',
    abilityBonuses: {
      AttributeType.strength: 1,
      AttributeType.dexterity: 1,
      AttributeType.constitution: 1,
      AttributeType.intelligence: 1,
      AttributeType.wisdom: 1,
      AttributeType.charisma: 1,
    },
    speed: 30,
    languages: ['Comum'],
    extraLanguages: 1,
  ),
  tiefling(
    'tiefling',
    abilityBonuses: {AttributeType.intelligence: 1, AttributeType.charisma: 2},
    speed: 30,
    languages: ['Comum', 'Infernal'],
  );

  /// Índice da raça na API 5e-bits (`/api/2014/races/{index}`).
  final String apiIndex;

  /// Bônus fixos de atributo.
  final Map<AttributeType, int> abilityBonuses;

  /// Deslocamento base em pés.
  final int speed;

  /// Idiomas que a raça já conhece.
  final List<String> languages;

  /// Idiomas extras à escolha do jogador.
  final int extraLanguages;

  /// Quantos atributos diferentes (fora os de [abilityBonuses]) recebem +1 à
  /// escolha do jogador. Só o Meio-Elfo tem: 2.
  final int chosenAbilityBonuses;

  const SrdRace(
    this.apiIndex, {
    required this.abilityBonuses,
    required this.speed,
    required this.languages,
    this.extraLanguages = 0,
    this.chosenAbilityBonuses = 0,
  });

  /// Encontra a raça pelo nome ou índice da API, sem diferenciar maiúsculas
  /// (ex: "Half-Elf", "half elf" e "half-elf").
  static SrdRace? fromName(String name) {
    final key = name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    for (final race in values) {
      if (race.apiIndex == key) return race;
    }
    return null;
  }

  /// Atributos que podem receber o +1 à escolha (os que não têm bônus fixo).
  List<AttributeType> get choosableAbilities => AttributeType.values
      .where((a) => !abilityBonuses.containsKey(a))
      .toList();
}

/// Valor máximo de um atributo para personagens jogadores.
const maxAbilityScore = 20;

/// Soma os bônus raciais de [race] em [base], mais +1 em cada atributo de
/// [chosen] (Meio-Elfo). Nenhum atributo passa de [maxAbilityScore].
Attribute applyRacialBonuses(
  Attribute base,
  SrdRace? race, {
  Set<AttributeType> chosen = const {},
}) {
  if (race == null) return base;
  var result = base;
  for (final attribute in AttributeType.values) {
    final bonus =
        (race.abilityBonuses[attribute] ?? 0) +
        (chosen.contains(attribute) &&
                race.choosableAbilities.contains(attribute)
            ? 1
            : 0);
    if (bonus == 0) continue;
    final value = (result.valueOf(attribute) + bonus).clamp(1, maxAbilityScore);
    result = result.withValue(attribute, value);
  }
  return result;
}
