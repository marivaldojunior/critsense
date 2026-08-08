part of 'dice_bloc.dart';

enum DiceRollStatus { idle, rolling }

/// Estado único do [DiceBloc], atualizado via [copyWith].
///
/// Uma única classe (em vez de hierarquia `sealed`) porque o pool e o
/// modificador precisam persistir através das transições de rolagem —
/// mesmo padrão adotado em [MonsterState] para estado acumulativo.
class DiceState {
  /// Quantidade de cada tipo de dado selecionado para a próxima rolagem.
  final Map<DiceType, int> pool;

  final int modifier;

  final DiceRollStatus status;

  /// Resultado da última rolagem concluída, ou `null` antes da primeira.
  final DiceRollResult? lastResult;

  /// Modo de vantagem/desvantagem aplicado aos d20 do pool na próxima rolagem.
  final D20RollMode d20Mode;

  const DiceState({
    this.pool = const {},
    this.modifier = 0,
    this.status = DiceRollStatus.idle,
    this.lastResult,
    this.d20Mode = D20RollMode.normal,
  });

  int get totalDiceCount =>
      pool.values.fold(0, (sum, quantity) => sum + quantity);

  DiceState copyWith({
    Map<DiceType, int>? pool,
    int? modifier,
    DiceRollStatus? status,
    DiceRollResult? lastResult,
    D20RollMode? d20Mode,
  }) {
    return DiceState(
      pool: pool ?? this.pool,
      modifier: modifier ?? this.modifier,
      status: status ?? this.status,
      lastResult: lastResult ?? this.lastResult,
      d20Mode: d20Mode ?? this.d20Mode,
    );
  }
}
