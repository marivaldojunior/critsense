import 'attribute.dart';

/// Representa um personagem de RPG dentro do domínio da aplicação.
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

  /// Total máximo de pontos de vida.
  final int maxHp;

  /// Pontos de vida atuais do personagem.
  final int currentHp;

  /// Conjunto de atributos base do personagem.
  final Attribute attributes;

  /// Caminho local para a imagem de avatar; nulo quando nenhum avatar foi definido.
  final String? avatarPath;

  /// Cria um [Character] com todos os campos obrigatórios.
  const Character({
    required this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    required this.level,
    required this.maxHp,
    required this.currentHp,
    required this.attributes,
    this.avatarPath,
  });
}
