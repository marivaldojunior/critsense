import '../entities/attribute_type.dart';
import '../entities/character.dart';
import '../entities/condition.dart';
import 'srd_rules.dart';

/// Regras de PV, morte e descanso do SRD 5.1 como transformações puras de
/// [Character]: cada método devolve o personagem novo, sem salvar nada.
///
/// O `CharacterBloc` só chama estes métodos e persiste o resultado. Quando
/// um método devolve `null`, a ação não muda nada (ex: gastar um dado de
/// vida sem nenhum disponível).
extension HitPointRules on Character {
  /// Dano: primeiro sai dos PV temporários, depois dos PV atuais (nunca
  /// abaixo de 0).
  ///
  /// - Cair a 0 PV zera as salvaguardas contra a morte.
  /// - Dano que sobra depois de zerar os PV e é maior ou igual ao PV máximo
  ///   mata na hora (dano massivo).
  /// - Dano com o personagem já em 0 PV conta uma falha; se o dano for maior
  ///   ou igual ao PV máximo, ele morre.
  Character withDamage(int amount) {
    if (amount <= 0) return this;
    final absorbedByTemp = amount < temporaryHitPoints
        ? amount
        : temporaryHitPoints;
    final remaining = amount - absorbedByTemp;
    final newTemp = temporaryHitPoints - absorbedByTemp;

    if (remaining == 0) return copyWith(temporaryHitPoints: newTemp);

    if (currentHitPoints == 0) {
      final failures = remaining >= maxHitPoints
          ? deathSavesToResolve
          : deathSaveFailures + 1;
      return copyWith(
        temporaryHitPoints: newTemp,
        // Um personagem estável que sofre dano volta a morrer.
        deathSaveSuccesses: 0,
        deathSaveFailures: failures.clamp(0, deathSavesToResolve),
      );
    }

    final overflow = remaining - currentHitPoints;
    if (overflow < 0) {
      return copyWith(
        temporaryHitPoints: newTemp,
        currentHitPoints: currentHitPoints - remaining,
      );
    }
    return copyWith(
      temporaryHitPoints: newTemp,
      currentHitPoints: 0,
      deathSaveSuccesses: 0,
      deathSaveFailures: overflow >= maxHitPoints ? deathSavesToResolve : 0,
    );
  }

  /// Cura até o PV máximo. Sair de 0 PV zera as salvaguardas. Um personagem
  /// morto não recebe cura (só magia de ressurreição, fora da ficha).
  Character? withHealing(int amount) {
    if (amount <= 0 || isDead) return null;
    final healed = (currentHitPoints + amount).clamp(0, maxHitPoints);
    if (healed == currentHitPoints) return null;
    return copyWith(
      currentHitPoints: healed,
      deathSaveSuccesses: 0,
      deathSaveFailures: 0,
    );
  }

  /// PV temporário não acumula: só vale se for maior que o atual.
  Character? withTemporaryHitPoints(int amount) {
    if (amount <= temporaryHitPoints) return null;
    return copyWith(temporaryHitPoints: amount);
  }

  /// Gasta um dado de vida no Descanso Curto: cura [roll] + mod. de CON.
  /// Devolve `null` sem dados disponíveis ou com o personagem morto.
  Character? withHitDieSpent(int roll) {
    if (hitDiceRemaining == 0 || isDead) return null;
    final healing = hitDieHealing(
      roll: roll,
      constitutionModifier: modifierOf(AttributeType.constitution),
    );
    final healed = (currentHitPoints + healing).clamp(0, maxHitPoints);
    return copyWith(
      hitDiceUsed: hitDiceUsed + 1,
      currentHitPoints: healed,
      deathSaveSuccesses: healed > 0 ? 0 : deathSaveSuccesses,
      deathSaveFailures: healed > 0 ? 0 : deathSaveFailures,
    );
  }

  /// Descanso Longo: PV no máximo, PV temporário zerado, metade dos dados de
  /// vida de volta, salvaguardas zeradas e um nível de exaustão a menos.
  Character? afterLongRest() {
    if (isDead) return null;
    final recovered = hitDiceRecoveredOnLongRest(level);
    return copyWith(
      currentHitPoints: maxHitPoints,
      temporaryHitPoints: 0,
      hitDiceUsed: (hitDiceUsed - recovered).clamp(0, level),
      deathSaveSuccesses: 0,
      deathSaveFailures: 0,
      exhaustionLevel: (exhaustionLevel - 1).clamp(0, maxExhaustionLevel),
    );
  }

  /// Aplica uma salvaguarda contra a morte com o d20 [roll]. Só vale com o
  /// personagem morrendo ([Character.isDying]).
  Character? withDeathSave(int roll) {
    if (!isDying) return null;
    return switch (deathSaveOutcome(roll)) {
      DeathSaveOutcome.criticalSuccess => copyWith(
        currentHitPoints: 1,
        deathSaveSuccesses: 0,
        deathSaveFailures: 0,
      ),
      DeathSaveOutcome.success => copyWith(
        deathSaveSuccesses: deathSaveSuccesses + 1,
      ),
      DeathSaveOutcome.failure => copyWith(
        deathSaveFailures: deathSaveFailures + 1,
      ),
      DeathSaveOutcome.criticalFailure => copyWith(
        deathSaveFailures: (deathSaveFailures + 2).clamp(
          0,
          deathSavesToResolve,
        ),
      ),
    };
  }

  /// Ajuste manual das salvaguardas (o jogador marca as bolinhas na ficha).
  Character withDeathSaves({required int successes, required int failures}) {
    return copyWith(
      deathSaveSuccesses: successes.clamp(0, deathSavesToResolve),
      deathSaveFailures: failures.clamp(0, deathSavesToResolve),
    );
  }

  /// Liga ou desliga a condição [condition].
  Character withConditionToggled(Condition condition) {
    final updated = conditions.contains(condition)
        ? (conditions.toList()..remove(condition))
        : [...conditions, condition];
    return copyWith(conditions: updated);
  }

  Character withExhaustion(int level) =>
      copyWith(exhaustionLevel: level.clamp(0, maxExhaustionLevel));
}
