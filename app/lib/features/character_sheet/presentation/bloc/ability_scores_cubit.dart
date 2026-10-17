import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/attribute.dart';
import '../../domain/entities/attribute_type.dart';
import '../../domain/rules/srd_rules.dart';

/// Como os atributos base são gerados na criação.
enum AbilityScoreMethod {
  /// Compra de pontos (27 pontos) — fica no `PointBuyCubit`.
  pointBuy('Compra de pontos'),

  /// Matriz padrão do SRD: 15, 14, 13, 12, 10, 8.
  standardArray('Matriz padrão'),

  /// 4d6 descartando o menor, seis vezes.
  roll('Rolagem 4d6');

  final String label;

  const AbilityScoreMethod(this.label);
}

/// Estado do [AbilityScoresCubit].
class AbilityScoresState extends Equatable {
  final AbilityScoreMethod method;

  /// Valores a distribuir (matriz padrão ou rolagem).
  final List<int> pool;

  /// Dados de cada rolagem, na mesma ordem de [pool] (vazio na matriz).
  final List<List<int>> rolls;

  /// Atributo -> posição do valor em [pool].
  final Map<AttributeType, int> assignment;

  const AbilityScoresState({
    this.method = AbilityScoreMethod.pointBuy,
    this.pool = const [],
    this.rolls = const [],
    this.assignment = const {},
  });

  /// Posições de [pool] já usadas.
  Set<int> get usedIndices => assignment.values.toSet();

  /// Todos os seis atributos receberam um valor.
  bool get isComplete =>
      AttributeType.values.every((a) => assignment.containsKey(a));

  /// Atributos distribuídos, ou `null` enquanto falta algum.
  Attribute? get attributes {
    if (!isComplete) return null;
    var result = const Attribute();
    for (final attribute in AttributeType.values) {
      result = result.withValue(attribute, pool[assignment[attribute]!]);
    }
    return result;
  }

  @override
  List<Object?> get props => [method, pool, rolls, assignment];
}

/// Gera os atributos base pela matriz padrão ou pela rolagem 4d6, e guarda
/// a distribuição dos valores entre os atributos. A compra de pontos
/// continua no `PointBuyCubit`.
class AbilityScoresCubit extends Cubit<AbilityScoresState> {
  AbilityScoresCubit({Random? random})
    : _random = random ?? Random(),
      super(const AbilityScoresState());

  final Random _random;

  void selectMethod(AbilityScoreMethod method) {
    switch (method) {
      case AbilityScoreMethod.pointBuy:
        emit(const AbilityScoresState());
      case AbilityScoreMethod.standardArray:
        emit(
          const AbilityScoresState(
            method: AbilityScoreMethod.standardArray,
            pool: standardAbilityArray,
          ),
        );
      case AbilityScoreMethod.roll:
        _roll();
    }
  }

  /// Rola de novo os seis valores (só no método de rolagem).
  void reroll() {
    if (state.method == AbilityScoreMethod.roll) _roll();
  }

  /// Dá a [attribute] o valor da posição [poolIndex]. Se outro atributo já
  /// usava esse valor, ele fica sem valor. `null` limpa o atributo.
  void assign(AttributeType attribute, int? poolIndex) {
    final assignment = Map<AttributeType, int>.of(state.assignment)
      ..remove(attribute);
    if (poolIndex != null) {
      assignment.removeWhere((_, index) => index == poolIndex);
      assignment[attribute] = poolIndex;
    }
    emit(
      AbilityScoresState(
        method: state.method,
        pool: state.pool,
        rolls: state.rolls,
        assignment: assignment,
      ),
    );
  }

  void _roll() {
    final rolls = [for (var i = 0; i < 6; i++) rollAbilityScore(_random)];
    emit(
      AbilityScoresState(
        method: AbilityScoreMethod.roll,
        pool: [for (final roll in rolls) roll.total],
        rolls: [for (final roll in rolls) roll.dice],
      ),
    );
  }
}
