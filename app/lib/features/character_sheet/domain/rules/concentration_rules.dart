import 'dart:math';

import '../entities/character.dart';

/// CD do teste de Constituição para manter a concentração depois de
/// [damage] de dano: 10 ou metade do dano, o que for maior.
int concentrationSaveDc(int damage) => max(10, damage ~/ 2);

/// Regras de concentração do SRD 5.1.
extension ConcentrationRules on Character {
  bool get isConcentrating => concentrationSpell != null;

  /// Começa a concentração em [spell]. Uma concentração nova termina a
  /// anterior. Um nome vazio devolve `null`.
  Character? withConcentration(String spell) {
    final name = spell.trim();
    if (name.isEmpty || name == concentrationSpell) return null;
    return copyWith(concentrationSpell: name);
  }

  /// Termina a concentração.
  Character? withConcentrationEnded() {
    if (!isConcentrating) return null;
    return copyWith(clearConcentration: true);
  }

  /// Termina a concentração quando o personagem cai a 0 PV, morre ou fica
  /// incapacitado. Senão, devolve o mesmo personagem.
  Character withConcentrationChecked() {
    if (!isConcentrating) return this;
    final incapacitated = conditions.any((c) => c.incapacitates);
    if (currentHitPoints == 0 || isDead || incapacitated) {
      return copyWith(clearConcentration: true);
    }
    return this;
  }
}
