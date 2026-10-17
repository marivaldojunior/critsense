import '../rules/srd_rules.dart';
import '../srd/srd_class.dart';
import 'attribute.dart';
import 'attribute_type.dart';
import 'condition.dart';
import 'proficiency.dart';

/// Representa um personagem de RPG dentro do domínio da aplicação.
///
/// Os campos abaixo estão agrupados pelos mesmos blocos da primeira página
/// da ficha oficial de personagem do D&D 5e: cabeçalho, bloco central de
/// Status de Combate, bloco lateral de Traços de Personalidade e o bloco
/// de Evolução (experiência/proficiência).
class Character {
  /// Identificador único do personagem.
  final String id;

  /// Nome do personagem.
  final String name;

  /// Raça do personagem (ex: Humano, Elfo, Anão).
  final String race;

  /// Classe do personagem (ex: Guerreiro, Mago, Ladino).
  final String characterClass;

  /// Nível atual do personagem.
  final int level;

  // ── Status de Combate ─────────────────────────────────────────────────
  // Bloco central da primeira página da ficha oficial: CA, iniciativa,
  // deslocamento e a caixa de pontos de vida (máximo, atual e temporário).
  // A CA e a iniciativa são calculadas (ver os getters abaixo); só os
  // bônus extras ficam salvos.

  /// Bônus extra de CA que a ficha não calcula sozinha (ex: anel de
  /// proteção, magia ativa). Pode ser negativo.
  final int armorClassBonus;

  /// Deslocamento base em pés por turno (vem da raça). O deslocamento
  /// efetivo, com condições e exaustão, é [effectiveSpeed].
  final int speed;

  /// Total máximo de pontos de vida.
  final int maxHitPoints;

  /// Pontos de vida atuais do personagem.
  final int currentHitPoints;

  /// Pontos de vida temporários, absorvidos antes dos PV atuais.
  final int temporaryHitPoints;

  /// Dados de vida já gastos em Descansos Curtos. O total é igual ao nível.
  final int hitDiceUsed;

  /// Sucessos nas salvaguardas contra a morte (0 a 3), só com PV 0.
  final int deathSaveSuccesses;

  /// Falhas nas salvaguardas contra a morte (0 a 3); 3 falhas = morte.
  final int deathSaveFailures;

  /// Condições ativas (Envenenado, Caído...).
  final List<Condition> conditions;

  /// Nível de exaustão, de 0 a [maxExhaustionLevel].
  final int exhaustionLevel;

  /// Inspiração concedida pelo mestre (tem ou não tem).
  final bool inspiration;

  /// Conjunto de atributos base do personagem.
  final Attribute attributes;

  /// Tendência (alinhamento), ex: "Leal e Bom".
  final String alignment;

  /// Antecedente (background) do personagem.
  final String background;

  // ── Traços de Personalidade ───────────────────────────────────────────
  // Bloco lateral esquerdo da primeira página da ficha oficial.

  /// Traços de personalidade do personagem.
  final String personalityTraits;

  /// Ideais que guiam as ações do personagem.
  final String ideals;

  /// Vínculos (pessoas, lugares ou causas importantes) do personagem.
  final String bonds;

  /// Defeitos ou fraquezas de personalidade do personagem.
  final String flaws;

  // ── Evolução ───────────────────────────────────────────────────────────
  // Bloco de progressão da ficha oficial, junto da caixa de nível/classe.

  /// Pontos de experiência acumulados.
  final int experiencePoints;

  /// Perícias e Testes de Resistência em que o personagem é proficiente —
  /// une os dois blocos "TESTES DE RESISTÊNCIA" e "PERÍCIAS" da ficha, já
  /// que ambos aplicam a mesma regra (soma o [proficiencyBonus] quando
  /// presentes). Vazia por padrão: nenhum personagem existente antes deste
  /// campo tinha proficiências registradas.
  final List<Proficiency> proficiencies;

  /// Caminho local para a imagem de avatar; nulo quando nenhum avatar foi definido.
  final String? avatarPath;

  /// Magias conhecidas/vinculadas ao personagem (índice ou nome da magia no
  /// compêndio). Vazia por padrão: nenhum personagem existente antes deste
  /// campo tinha magias registradas.
  ///
  /// Diferente do inventário (ver [InventoryItem], persistido em sua própria
  /// tabela relacional `InventoryItems` por ter atributos próprios como
  /// categoria), uma magia registrada aqui não carrega dado adicional além
  /// do identificador — uma lista simples já é suficiente, sem precisar de
  /// uma tabela dedicada.
  final List<String> spells;

  /// Monstros/chefes derrotados pelo personagem (índice ou nome no
  /// compêndio). Mesma justificativa de [spells] para ser uma lista simples
  /// em vez de uma tabela relacional.
  final List<String> defeatedBosses;

  /// Cria um [Character] com todos os campos obrigatórios.
  const Character({
    required this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    required this.level,
    this.armorClassBonus = 0,
    required this.speed,
    required this.maxHitPoints,
    required this.currentHitPoints,
    required this.temporaryHitPoints,
    this.hitDiceUsed = 0,
    this.deathSaveSuccesses = 0,
    this.deathSaveFailures = 0,
    this.conditions = const [],
    this.exhaustionLevel = 0,
    this.inspiration = false,
    required this.attributes,
    required this.alignment,
    required this.background,
    required this.personalityTraits,
    required this.ideals,
    required this.bonds,
    required this.flaws,
    required this.experiencePoints,
    this.proficiencies = const [],
    this.avatarPath,
    this.spells = const [],
    this.defeatedBosses = const [],
  });

  /// Retorna uma cópia com os campos informados substituídos.
  ///
  /// Usada pelo [CharacterBloc] para produzir a nova versão do personagem
  /// antes de persistir — seja ao marcar/desmarcar uma proficiência, seja
  /// ao editar um dos campos de texto do bloco de Traços de Personalidade.
  Character copyWith({
    String? name,
    String? race,
    String? characterClass,
    int? level,
    int? armorClassBonus,
    int? speed,
    int? maxHitPoints,
    int? currentHitPoints,
    int? temporaryHitPoints,
    int? hitDiceUsed,
    int? deathSaveSuccesses,
    int? deathSaveFailures,
    List<Condition>? conditions,
    int? exhaustionLevel,
    bool? inspiration,
    Attribute? attributes,
    String? alignment,
    String? background,
    String? personalityTraits,
    String? ideals,
    String? bonds,
    String? flaws,
    int? experiencePoints,
    List<Proficiency>? proficiencies,
    String? avatarPath,
    List<String>? spells,
    List<String>? defeatedBosses,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      armorClassBonus: armorClassBonus ?? this.armorClassBonus,
      speed: speed ?? this.speed,
      maxHitPoints: maxHitPoints ?? this.maxHitPoints,
      currentHitPoints: currentHitPoints ?? this.currentHitPoints,
      temporaryHitPoints: temporaryHitPoints ?? this.temporaryHitPoints,
      hitDiceUsed: hitDiceUsed ?? this.hitDiceUsed,
      deathSaveSuccesses: deathSaveSuccesses ?? this.deathSaveSuccesses,
      deathSaveFailures: deathSaveFailures ?? this.deathSaveFailures,
      conditions: conditions ?? this.conditions,
      exhaustionLevel: exhaustionLevel ?? this.exhaustionLevel,
      inspiration: inspiration ?? this.inspiration,
      attributes: attributes ?? this.attributes,
      alignment: alignment ?? this.alignment,
      background: background ?? this.background,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      ideals: ideals ?? this.ideals,
      bonds: bonds ?? this.bonds,
      flaws: flaws ?? this.flaws,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      proficiencies: proficiencies ?? this.proficiencies,
      avatarPath: avatarPath ?? this.avatarPath,
      spells: spells ?? this.spells,
      defeatedBosses: defeatedBosses ?? this.defeatedBosses,
    );
  }

  // ---------------------------------------------------------------------
  // Valores derivados — regras do SRD 5.1. Nada disto fica salvo: a ficha
  // recalcula a partir dos dados acima, então nunca fica desatualizada.
  // ---------------------------------------------------------------------

  /// Classe do SRD do personagem, ou `null` se a classe não é do SRD.
  SrdClass? get srdClass => SrdClass.fromName(characterClass);

  /// Modificador do atributo [type].
  int modifierOf(AttributeType type) =>
      attributeModifier(attributes.valueOf(type));

  /// Bônus de proficiência pelo nível (+2 no 1º, +6 no 17º).
  int get proficiencyBonus => proficiencyBonusForLevel(level);

  /// Iniciativa: o modificador de Destreza.
  int get initiative => modifierOf(AttributeType.dexterity);

  /// CA sem armadura, com a Defesa sem Armadura do Bárbaro (DES + CON) e do
  /// Monge (DES + SAB), mais [armorClassBonus].
  int get armorClass =>
      unarmoredArmorClass(
        srdClass: srdClass,
        dexterityModifier: modifierOf(AttributeType.dexterity),
        constitutionModifier: modifierOf(AttributeType.constitution),
        wisdomModifier: modifierOf(AttributeType.wisdom),
      ) +
      armorClassBonus;

  /// Faces do dado de vida da classe.
  int get hitDie => srdClass?.hitDie ?? SrdClass.defaultHitDie;

  /// Dados de vida disponíveis (o total é igual ao nível).
  int get hitDiceRemaining => (level - hitDiceUsed).clamp(0, level);

  /// Deslocamento com os efeitos das condições e da exaustão.
  int get effectiveSpeed => speedWithPenalties(
    baseSpeed: speed,
    conditions: conditions,
    exhaustionLevel: exhaustionLevel,
  );

  /// Com PV 0 e sem estar estável nem morto: rola salvaguardas contra a morte.
  bool get isDying =>
      currentHitPoints == 0 && !isStable && !isDead && maxHitPoints > 0;

  /// Estável: 3 sucessos com PV 0. Não rola mais salvaguardas.
  bool get isStable =>
      currentHitPoints == 0 && deathSaveSuccesses >= deathSavesToResolve;

  /// Morto: 3 falhas nas salvaguardas, dano massivo ou exaustão 6.
  bool get isDead =>
      deathSaveFailures >= deathSavesToResolve ||
      exhaustionLevel >= maxExhaustionLevel;
}
