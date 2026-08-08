import 'attribute.dart';
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

  /// Classe de Armadura (CA).
  final int armorClass;

  /// Modificador de iniciativa somado à rolagem de d20 no início do combate.
  final int initiative;

  /// Deslocamento em pés por turno.
  final int speed;

  /// Total máximo de pontos de vida.
  final int maxHitPoints;

  /// Pontos de vida atuais do personagem.
  final int currentHitPoints;

  /// Pontos de vida temporários, absorvidos antes dos PV atuais.
  final int temporaryHitPoints;

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

  /// Bônus de proficiência aplicado a testes, ataques e resistências.
  final int proficiencyBonus;

  /// Perícias e Testes de Resistência em que o personagem é proficiente —
  /// une os dois blocos "TESTES DE RESISTÊNCIA" e "PERÍCIAS" da ficha, já
  /// que ambos aplicam a mesma regra (soma o [proficiencyBonus] quando
  /// presentes). Vazia por padrão: nenhum personagem existente antes deste
  /// campo tinha proficiências registradas.
  final List<Proficiency> proficiencies;

  /// Caminho local para a imagem de avatar; nulo quando nenhum avatar foi definido.
  final String? avatarPath;

  /// Cria um [Character] com todos os campos obrigatórios.
  const Character({
    required this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    required this.level,
    required this.armorClass,
    required this.initiative,
    required this.speed,
    required this.maxHitPoints,
    required this.currentHitPoints,
    required this.temporaryHitPoints,
    required this.attributes,
    required this.alignment,
    required this.background,
    required this.personalityTraits,
    required this.ideals,
    required this.bonds,
    required this.flaws,
    required this.experiencePoints,
    required this.proficiencyBonus,
    this.proficiencies = const [],
    this.avatarPath,
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
    int? armorClass,
    int? initiative,
    int? speed,
    int? maxHitPoints,
    int? currentHitPoints,
    int? temporaryHitPoints,
    Attribute? attributes,
    String? alignment,
    String? background,
    String? personalityTraits,
    String? ideals,
    String? bonds,
    String? flaws,
    int? experiencePoints,
    int? proficiencyBonus,
    List<Proficiency>? proficiencies,
    String? avatarPath,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      armorClass: armorClass ?? this.armorClass,
      initiative: initiative ?? this.initiative,
      speed: speed ?? this.speed,
      maxHitPoints: maxHitPoints ?? this.maxHitPoints,
      currentHitPoints: currentHitPoints ?? this.currentHitPoints,
      temporaryHitPoints: temporaryHitPoints ?? this.temporaryHitPoints,
      attributes: attributes ?? this.attributes,
      alignment: alignment ?? this.alignment,
      background: background ?? this.background,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      ideals: ideals ?? this.ideals,
      bonds: bonds ?? this.bonds,
      flaws: flaws ?? this.flaws,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      proficiencyBonus: proficiencyBonus ?? this.proficiencyBonus,
      proficiencies: proficiencies ?? this.proficiencies,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
