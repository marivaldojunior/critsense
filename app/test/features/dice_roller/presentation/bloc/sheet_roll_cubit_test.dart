import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/dice_roller/data/datasources/sensor_datasource.dart';
import 'package:crit_sense/features/dice_roller/data/repositories/dice_repository_impl.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_notation.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';
import 'package:crit_sense/features/dice_roller/domain/usecases/roll_dice_usecase.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/sheet_roll_cubit.dart';

class _MockSensor extends Mock implements ISensorDataSource {}

/// Testa a notação de dano e a rolagem feita a partir da ficha.
void main() {
  group('notação de dados', () {
    test('lê dados, modificador e valor fixo', () {
      final sword = DiceNotation.tryParse('1d8+3')!;
      expect(sword.pool, {DiceType.d8: 1});
      expect(sword.modifier, 3);

      final weak = DiceNotation.tryParse('2d6-1')!;
      expect(weak.pool, {DiceType.d6: 2});
      expect(weak.modifier, -1);

      expect(DiceNotation.tryParse('d20')!.pool, {DiceType.d20: 1});

      final fixed = DiceNotation.tryParse('1')!;
      expect(fixed.hasDice, isFalse);
      expect(fixed.modifier, 1);
    });

    test('recusa texto inválido e dados que não existem', () {
      expect(DiceNotation.tryParse('abc'), isNull);
      expect(DiceNotation.tryParse('1d7'), isNull);
      expect(DiceNotation.tryParse(''), isNull);
      expect(DiceNotation.tryParse('0d6'), isNull);
    });
  });

  group('SheetRollCubit', () {
    late _MockSensor sensor;

    setUp(() {
      sensor = _MockSensor();
      when(() => sensor.triggerCriticalSuccess()).thenAnswer((_) async {});
      when(() => sensor.triggerCriticalFailure()).thenAnswer((_) async {});
    });

    SheetRollCubit cubitWith(
      int seed, {
      D20RollMode mode = D20RollMode.normal,
    }) => SheetRollCubit(
      RollDiceUseCase(DiceRepositoryImpl(sensor, random: Random(seed))),
      initialMode: mode,
    );

    test('rola d20 + modificador no modo inicial', () {
      final cubit = cubitWith(1, mode: D20RollMode.advantage)..rollD20(5);

      final result = cubit.state.d20Result!;
      expect(result.modifier, 5);
      expect(result.rolls.single.type, DiceType.d20);
      expect(result.rolls.single.discardedValue, isNotNull); // vantagem
      expect(result.total, result.rolls.single.value + 5);
    });

    test('rola o dano e dobra os dados no crítico', () {
      final cubit = cubitWith(2)..rollDamage('1d8+3', critical: true);

      final damage = cubit.state.damageResult!;
      expect(damage.rolls, hasLength(2));
      expect(damage.modifier, 3); // o modificador não dobra
    });

    test('dano fixo vira um resultado sem dados', () {
      final cubit = cubitWith(3)..rollDamage('1');

      expect(cubit.state.damageResult!.rolls, isEmpty);
      expect(cubit.state.damageResult!.total, 1);
    });

    test('nova rolagem de d20 limpa o dano anterior', () {
      final cubit = cubitWith(4)
        ..rollD20(0)
        ..rollDamage('1d6')
        ..rollD20(0);

      expect(cubit.state.damageResult, isNull);
    });
  });
}
