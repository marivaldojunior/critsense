/// Representa os seis atributos base de um personagem de RPG.
class Attribute {
  /// Força: capacidade física bruta.
  final int strength;

  /// Destreza: agilidade, reflexos e coordenação motora.
  final int dexterity;

  /// Constituição: resistência e vigor físico.
  final int constitution;

  /// Inteligência: raciocínio e memória.
  final int intelligence;

  /// Sabedoria: percepção e intuição.
  final int wisdom;

  /// Carisma: força de personalidade e capacidade de liderança.
  final int charisma;

  /// Cria um conjunto de atributos com todos os valores obrigatórios.
  const Attribute({
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  });
}
