import '../entities/d20_roll_mode.dart';
import '../entities/dice_result.dart';
import '../entities/dice_type.dart';
import '../repositories/i_dice_repository.dart';

/// Caso de uso responsável por orquestrar o lançamento de um pool de dados.
class RollDiceUseCase {
  final IDiceRepository _repository;

  const RollDiceUseCase(this._repository);

  /// Rola todos os dados descritos em [pool] e soma [modifier] ao total.
  /// [d20Mode] aplica vantagem/desvantagem apenas aos d20 do pool.
  DiceRollResult call({
    required Map<DiceType, int> pool,
    required int modifier,
    D20RollMode d20Mode = D20RollMode.normal,
  }) {
    return _repository.rollPool(pool, modifier, d20Mode);
  }
}
