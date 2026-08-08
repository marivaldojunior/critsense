import 'dart:async';
import 'dart:math';

import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_result.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';
import 'package:crit_sense/features/dice_roller/domain/repositories/i_dice_repository.dart';
import '../datasources/sensor_datasource.dart';

/// Implementação concreta de [IDiceRepository]: gera os valores aleatórios
/// de cada dado do pool e aciona feedback de hardware em resultados críticos.
class DiceRepositoryImpl implements IDiceRepository {
  final ISensorDataSource _sensorDataSource;

  /// [Random] é instanciado uma vez e reutilizado para melhor distribuição
  /// pseudo-aleatória entre rolagens sucessivas.
  final Random _random;

  DiceRepositoryImpl(this._sensorDataSource, {Random? random})
    : _random = random ?? Random();

  @override
  DiceRollResult rollPool(
    Map<DiceType, int> pool,
    int modifier,
    D20RollMode d20Mode,
  ) {
    final rolls = <SingleDieResult>[
      for (final entry in pool.entries)
        for (var i = 0; i < entry.value; i++)
          if (entry.key == DiceType.d20 && d20Mode != D20RollMode.normal)
            _rollD20WithMode(d20Mode)
          else
            SingleDieResult(
              type: entry.key,
              value: _random.nextInt(entry.key.sides) + 1,
            ),
    ];

    final result = DiceRollResult(rolls: rolls, modifier: modifier);

    // Feedback de hardware considera o pool inteiro: qualquer d20 crítico
    // entre os dados rolados dispara a vibração correspondente.
    if (result.hasCriticalSuccess) {
      unawaited(_sensorDataSource.triggerCriticalSuccess());
    } else if (result.hasCriticalFailure) {
      unawaited(_sensorDataSource.triggerCriticalFailure());
    }

    return result;
  }

  /// Rola dois d20 e mantém o maior ([D20RollMode.advantage]) ou o menor
  /// ([D20RollMode.disadvantage]); o outro valor fica em [SingleDieResult.discardedValue]
  /// apenas para exibição.
  SingleDieResult _rollD20WithMode(D20RollMode mode) {
    final rollA = _random.nextInt(20) + 1;
    final rollB = _random.nextInt(20) + 1;

    final kept = mode == D20RollMode.advantage
        ? max(rollA, rollB)
        : min(rollA, rollB);
    final discarded = kept == rollA ? rollB : rollA;

    return SingleDieResult(
      type: DiceType.d20,
      value: kept,
      discardedValue: discarded,
    );
  }
}
