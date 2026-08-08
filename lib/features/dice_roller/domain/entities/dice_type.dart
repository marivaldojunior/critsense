/// Tipos de dado poliédrico suportados pelo rolador, padrão de RPG de mesa.
enum DiceType {
  d4(4),
  d6(6),
  d8(8),
  d10(10),
  d12(12),
  d20(20),
  d100(100);

  /// Número de faces do dado.
  final int sides;

  const DiceType(this.sides);

  /// Rótulo de exibição, ex: `d20`.
  String get label => 'd$sides';
}
