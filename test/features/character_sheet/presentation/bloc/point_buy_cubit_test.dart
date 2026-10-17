import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/point_buy_rules.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/point_buy_cubit.dart';

/// Testa a Compra de Pontos (27 pontos, atributos de 8 a 15) no
/// [PointBuyCubit] e na tabela de custo de [PointBuyRules].
void main() {
  late PointBuyCubit cubit;

  setUp(() => cubit = PointBuyCubit());
  tearDown(() => cubit.close());

  /// Chama [PointBuyCubit.increment] [times] vezes em [type].
  void incrementTimes(AttributeType type, int times) {
    for (var i = 0; i < times; i++) {
      cubit.increment(type);
    }
  }

  group('PointBuyRules.costToReach', () {
    test('segue a tabela de custo do SRD', () {
      const expected = {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9};

      expected.forEach((score, cost) {
        expect(PointBuyRules.costToReach(score), cost, reason: 'valor $score');
      });
    });
  });

  test('começa com todos os atributos em 8 e 27 pontos livres', () {
    for (final type in AttributeType.values) {
      expect(cubit.state.attributes.valueOf(type), 8);
    }
    expect(cubit.state.pointsSpent, 0);
    expect(cubit.state.pointsRemaining, 27);
  });

  test('levar um atributo de 8 a 15 custa 9 pontos', () {
    incrementTimes(AttributeType.strength, 7);

    expect(cubit.state.attributes.valueOf(AttributeType.strength), 15);
    expect(cubit.state.pointsSpent, 9);
    expect(cubit.state.pointsRemaining, 18);
  });

  test('não passa de 15', () {
    incrementTimes(AttributeType.dexterity, 10);

    expect(cubit.state.attributes.valueOf(AttributeType.dexterity), 15);
    expect(cubit.state.canIncrement(AttributeType.dexterity), isFalse);
  });

  test('não desce abaixo de 8', () {
    cubit.decrement(AttributeType.wisdom);

    expect(cubit.state.attributes.valueOf(AttributeType.wisdom), 8);
    expect(cubit.state.canDecrement(AttributeType.wisdom), isFalse);
  });

  test('decrementar devolve os pontos gastos', () {
    incrementTimes(AttributeType.charisma, 7);
    cubit.decrement(AttributeType.charisma);

    expect(cubit.state.attributes.valueOf(AttributeType.charisma), 14);
    expect(cubit.state.pointsSpent, 7);
  });

  test('não gasta mais que 27 pontos', () {
    incrementTimes(AttributeType.strength, 7);
    incrementTimes(AttributeType.dexterity, 7);
    incrementTimes(AttributeType.constitution, 7);

    expect(cubit.state.pointsRemaining, 0);

    cubit.increment(AttributeType.intelligence);
    expect(cubit.state.attributes.valueOf(AttributeType.intelligence), 8);
    expect(cubit.state.pointsSpent, 27);
  });

  test('com só 1 ponto livre, não sobe de 13 para 14 (custo 2)', () {
    // 15, 15, 13 e 11 custam 9 + 9 + 5 + 3 = 26 pontos: sobra 1.
    incrementTimes(AttributeType.strength, 7);
    incrementTimes(AttributeType.dexterity, 7);
    incrementTimes(AttributeType.constitution, 5);
    incrementTimes(AttributeType.wisdom, 3);
    expect(cubit.state.pointsRemaining, 1);

    cubit.increment(AttributeType.constitution);
    expect(cubit.state.attributes.valueOf(AttributeType.constitution), 13);

    // Já de 11 para 12 custa só 1, então ainda é permitido.
    cubit.increment(AttributeType.wisdom);
    expect(cubit.state.attributes.valueOf(AttributeType.wisdom), 12);
    expect(cubit.state.pointsRemaining, 0);
  });

  test('reset devolve todos os atributos a 8', () {
    incrementTimes(AttributeType.strength, 5);
    cubit.reset();

    expect(cubit.state.attributes.valueOf(AttributeType.strength), 8);
    expect(cubit.state.pointsRemaining, 27);
  });
}
