import '../entities/dice_result.dart';
import '../entities/dice_type.dart';
import '../repositories/i_dice_repository.dart';

/// Caso de uso responsável por orquestrar o lançamento de um pool de dados.
class RollDiceUseCase {
  final IDiceRepository _repository;

  const RollDiceUseCase(this._repository);

  /// Rola todos os dados descritos em [pool] e soma [modifier] ao total.
  DiceRollResult call({
    required Map<DiceType, int> pool,
    required int modifier,
  }) {
    return _repository.rollPool(pool, modifier);
  }
}
