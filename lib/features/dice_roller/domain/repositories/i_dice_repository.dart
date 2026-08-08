import '../entities/d20_roll_mode.dart';
import '../entities/dice_result.dart';
import '../entities/dice_type.dart';

/// Contrato (interface) que define as operações de lançamento de dados.
///
/// Em Clean Architecture, o repositório pertence à camada de domínio como
/// abstração: o domínio declara o que precisa, mas não sabe como será
/// implementado (gerador aleatório, feedback de hardware etc.).
abstract interface class IDiceRepository {
  /// Rola cada dado do [pool] (chave: tipo, valor: quantidade) e soma o
  /// [modifier] ao total. [d20Mode] aplica vantagem/desvantagem a cada d20
  /// do pool; ignorado para os demais tipos de dado.
  DiceRollResult rollPool(
    Map<DiceType, int> pool,
    int modifier,
    D20RollMode d20Mode,
  );
}
