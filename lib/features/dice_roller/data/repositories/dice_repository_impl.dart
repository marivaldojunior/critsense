import 'dart:async';
import 'dart:math';

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
  DiceRollResult rollPool(Map<DiceType, int> pool, int modifier) {
    final rolls = <SingleDieResult>[
      for (final entry in pool.entries)
        for (var i = 0; i < entry.value; i++)
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
}
