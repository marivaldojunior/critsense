import 'dice_type.dart';

/// Resultado de um único dado dentro de uma rolagem de pool.
///
/// Crítico é regra exclusiva do d20: outros dados não têm o conceito de
/// acerto/falha crítica, então os getters checam explicitamente o [type].
class SingleDieResult {
  final DiceType type;
  final int value;

  const SingleDieResult({required this.type, required this.value});

  bool get isCriticalSuccess => type == DiceType.d20 && value == 20;
  bool get isCriticalFailure => type == DiceType.d20 && value == 1;

  @override
  String toString() => 'SingleDieResult(${type.label}: $value)';
}

/// Resultado agregado de uma rolagem de pool: todos os dados lançados de
/// uma vez, mais o modificador global somado ao final.
class DiceRollResult {
  /// Um item por dado lançado, na ordem em que os tipos foram adicionados
  /// ao pool — permite reconstruir o detalhamento por tipo na UI.
  final List<SingleDieResult> rolls;

  final int modifier;

  const DiceRollResult({required this.rolls, this.modifier = 0});

  int get diceTotal => rolls.fold(0, (sum, roll) => sum + roll.value);

  int get total => diceTotal + modifier;

  bool get hasCriticalSuccess => rolls.any((roll) => roll.isCriticalSuccess);

  bool get hasCriticalFailure => rolls.any((roll) => roll.isCriticalFailure);

  @override
  String toString() =>
      'DiceRollResult(rolls: $rolls, modifier: $modifier, total: $total)';
}
