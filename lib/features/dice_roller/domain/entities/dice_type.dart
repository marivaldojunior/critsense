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

  /// Caminho do SVG temático deste dado em `assets/icons/dice/`, para uso
  /// com o widget `DnDIcon`.
  ///
  /// O d100 (percentual) não possui ícone dedicado no pacote e é rolado com
  /// um d10 na mesa, por isso reutiliza o mesmo asset.
  String get iconAsset => switch (this) {
    DiceType.d100 => 'assets/icons/dice/d10.svg',
    _ => 'assets/icons/dice/$label.svg',
  };
}
