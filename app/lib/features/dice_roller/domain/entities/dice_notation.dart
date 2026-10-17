import 'dice_type.dart';

/// Uma expressão de dados lida de um texto como `2d6+3`.
class DiceNotation {
  /// Dados a rolar (tipo -> quantidade). Vazio num valor fixo (ex: `1`).
  final Map<DiceType, int> pool;

  /// Valor somado ao total (pode ser negativo).
  final int modifier;

  const DiceNotation({required this.pool, required this.modifier});

  bool get hasDice => pool.isNotEmpty;

  static final _pattern = RegExp(
    r'^\s*(?:(\d*)d(\d+))?\s*([+-]\s*\d+|\d+)?\s*$',
  );

  /// Lê `NdM`, `NdM+K`, `NdM-K` ou um valor fixo `K`. Devolve `null` se o
  /// texto não está nesse formato ou o dado não existe no app (ex: d7).
  static DiceNotation? tryParse(String text) {
    final match = _pattern.firstMatch(text.toLowerCase());
    if (match == null || (match.group(2) == null && match.group(3) == null)) {
      return null;
    }
    final pool = <DiceType, int>{};
    if (match.group(2) != null) {
      final sides = int.parse(match.group(2)!);
      final type = DiceType.values.where((t) => t.sides == sides).firstOrNull;
      if (type == null) return null;
      final count = match.group(1)!.isEmpty ? 1 : int.parse(match.group(1)!);
      if (count < 1) return null;
      pool[type] = count;
    }
    final modifierText = match.group(3)?.replaceAll(' ', '');
    final modifier = modifierText == null ? 0 : int.parse(modifierText);
    return DiceNotation(pool: pool, modifier: modifier);
  }
}
