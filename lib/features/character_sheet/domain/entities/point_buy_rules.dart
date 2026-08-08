/// Regras de "Compra de Pontos" (Point Buy) para atributos base, D&D 5e.
class PointBuyRules {
  PointBuyRules._();

  static const int totalPoints = 27;
  static const int baseScore = 8;
  static const int maxScore = 15;

  /// Custo para elevar um atributo de [score] para `score + 1`.
  ///
  /// De 8 a 13, cada ponto custa 1; de 13 em diante (13→14, 14→15), cada
  /// ponto custa 2 — a progressão de custo do Point Buy oficial.
  static int costOfNextPoint(int score) => score < 13 ? 1 : 2;

  /// Custo cumulativo para alcançar [score] partindo de [baseScore].
  static int costToReach(int score) {
    var cost = 0;
    for (var s = baseScore; s < score; s++) {
      cost += costOfNextPoint(s);
    }
    return cost;
  }
}
