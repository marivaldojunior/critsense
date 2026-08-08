part of 'point_buy_cubit.dart';

/// Estado único do [PointBuyCubit].
///
/// Pontos gastos/restantes são sempre derivados de [attributes] — nunca
/// armazenados separadamente — para que não exista a possibilidade de os
/// dois ficarem dessincronizados.
class PointBuyState {
  final Attribute attributes;

  const PointBuyState({this.attributes = const Attribute()});

  int get pointsSpent => AttributeType.values
      .map((type) => PointBuyRules.costToReach(attributes.valueOf(type)))
      .fold(0, (sum, cost) => sum + cost);

  int get pointsRemaining => PointBuyRules.totalPoints - pointsSpent;

  bool canIncrement(AttributeType type) {
    final current = attributes.valueOf(type);
    if (current >= PointBuyRules.maxScore) return false;
    return pointsRemaining >= PointBuyRules.costOfNextPoint(current);
  }

  bool canDecrement(AttributeType type) =>
      attributes.valueOf(type) > PointBuyRules.baseScore;

  PointBuyState copyWith({Attribute? attributes}) {
    return PointBuyState(attributes: attributes ?? this.attributes);
  }
}
