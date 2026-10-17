import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/dice_roller/data/datasources/sensor_datasource.dart';
import 'package:crit_sense/features/dice_roller/data/repositories/dice_repository_impl.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';

class _MockSensorDataSource extends Mock implements ISensorDataSource {}

/// [Random] que devolve os valores de face de [faces], em ordem. Como o
/// repositório usa `nextInt(sides) + 1`, cada face vira `face - 1`.
class _FixedRandom implements Random {
  _FixedRandom(List<int> faces) : _faces = faces.iterator;

  final Iterator<int> _faces;

  @override
  int nextInt(int max) {
    if (!_faces.moveNext()) throw StateError('Sem faces para rolar');
    final face = _faces.current;
    if (face < 1 || face > max) throw RangeError.range(face, 1, max);
    return face - 1;
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

/// Testa as regras de rolagem do [DiceRepositoryImpl]: soma do pool,
/// vantagem/desvantagem do d20 e o feedback de hardware nos críticos.
void main() {
  late _MockSensorDataSource sensor;

  setUp(() {
    sensor = _MockSensorDataSource();
    when(() => sensor.triggerCriticalSuccess()).thenAnswer((_) async {});
    when(() => sensor.triggerCriticalFailure()).thenAnswer((_) async {});
  });

  DiceRepositoryImpl repositoryWith(List<int> faces) =>
      DiceRepositoryImpl(sensor, random: _FixedRandom(faces));

  test('soma os dados do pool e o modificador', () {
    final result = repositoryWith([
      3,
      5,
      2,
    ]).rollPool({DiceType.d6: 2, DiceType.d4: 1}, 2, D20RollMode.normal);

    expect(result.rolls.map((r) => r.value), [3, 5, 2]);
    expect(result.diceTotal, 10);
    expect(result.total, 12);
  });

  test('vantagem mantém o maior de dois d20 e guarda o outro', () {
    final result = repositoryWith([
      7,
      15,
    ]).rollPool({DiceType.d20: 1}, 0, D20RollMode.advantage);

    expect(result.rolls.single.value, 15);
    expect(result.rolls.single.discardedValue, 7);
  });

  test('desvantagem mantém o menor de dois d20 e guarda o outro', () {
    final result = repositoryWith([
      7,
      15,
    ]).rollPool({DiceType.d20: 1}, 0, D20RollMode.disadvantage);

    expect(result.rolls.single.value, 7);
    expect(result.rolls.single.discardedValue, 15);
  });

  test('vantagem só afeta o d20, não os outros dados', () {
    final result = repositoryWith([
      4,
      10,
      18,
    ]).rollPool({DiceType.d6: 1, DiceType.d20: 1}, 0, D20RollMode.advantage);

    expect(result.rolls.map((r) => r.value), [4, 18]);
    expect(result.rolls.first.discardedValue, isNull);
  });

  test('um 20 natural mantido dispara o feedback de crítico', () {
    repositoryWith([20]).rollPool({DiceType.d20: 1}, 0, D20RollMode.normal);

    verify(() => sensor.triggerCriticalSuccess()).called(1);
    verifyNever(() => sensor.triggerCriticalFailure());
  });

  test('um 1 natural mantido dispara o feedback de falha crítica', () {
    repositoryWith([1]).rollPool({DiceType.d20: 1}, 0, D20RollMode.normal);

    verify(() => sensor.triggerCriticalFailure()).called(1);
    verifyNever(() => sensor.triggerCriticalSuccess());
  });

  test('um 20 descartado pela desvantagem não conta como crítico', () {
    repositoryWith([
      20,
      9,
    ]).rollPool({DiceType.d20: 1}, 0, D20RollMode.disadvantage);

    verifyNever(() => sensor.triggerCriticalSuccess());
  });
}
