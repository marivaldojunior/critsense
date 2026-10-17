import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/condition.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/hit_point_rules.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/srd_rules.dart';

/// Testa as regras de PV, morte, descanso e valores derivados do SRD 5.1.
void main() {
  /// Guerreiro (d10) nível 4, CON 14 (+2), DES 14 (+2), 30 PV máximos.
  Character fighter({
    int current = 30,
    int temp = 0,
    int hitDiceUsed = 0,
    int successes = 0,
    int failures = 0,
    int exhaustion = 0,
    String characterClass = 'Fighter',
    Attribute attributes = const Attribute(constitution: 14, dexterity: 14),
    List<Condition> conditions = const [],
  }) => Character(
    id: 'c1',
    name: 'Teste',
    race: 'Human',
    characterClass: characterClass,
    level: 4,
    speed: 30,
    maxHitPoints: 30,
    currentHitPoints: current,
    temporaryHitPoints: temp,
    hitDiceUsed: hitDiceUsed,
    deathSaveSuccesses: successes,
    deathSaveFailures: failures,
    exhaustionLevel: exhaustion,
    conditions: conditions,
    attributes: attributes,
    alignment: '',
    background: '',
    personalityTraits: '',
    ideals: '',
    bonds: '',
    flaws: '',
    experiencePoints: 0,
  );

  group('valores derivados', () {
    test('bônus de proficiência segue o nível', () {
      expect(proficiencyBonusForLevel(1), 2);
      expect(proficiencyBonusForLevel(4), 2);
      expect(proficiencyBonusForLevel(5), 3);
      expect(proficiencyBonusForLevel(9), 4);
      expect(proficiencyBonusForLevel(13), 5);
      expect(proficiencyBonusForLevel(17), 6);
      expect(proficiencyBonusForLevel(20), 6);
    });

    test('iniciativa é o modificador de DES', () {
      expect(fighter().initiative, 2);
    });

    test('CA sem armadura é 10 + DES, mais o bônus manual', () {
      expect(fighter().armorClass, 12);
      expect(fighter().copyWith(armorClassBonus: 1).armorClass, 13);
    });

    test('Defesa sem Armadura do Bárbaro soma CON e a do Monge soma SAB', () {
      expect(fighter(characterClass: 'Barbarian').armorClass, 14);
      expect(
        fighter(
          characterClass: 'Monk',
          attributes: const Attribute(dexterity: 16, wisdom: 14),
        ).armorClass,
        15,
      );
    });

    test('dado de vida vem da classe, com d8 para classes fora do SRD', () {
      expect(fighter().hitDie, 10);
      expect(fighter(characterClass: 'Wizard').hitDie, 6);
      expect(fighter(characterClass: 'Artificer').hitDie, 8);
    });

    test('condições que prendem e exaustão mudam o deslocamento', () {
      expect(fighter().effectiveSpeed, 30);
      expect(fighter(exhaustion: 2).effectiveSpeed, 15);
      expect(fighter(exhaustion: 5).effectiveSpeed, 0);
      expect(fighter(conditions: const [Condition.grappled]).effectiveSpeed, 0);
      expect(
        fighter(conditions: const [Condition.poisoned]).effectiveSpeed,
        30,
      );
    });

    test('PV inicial: dado máximo no 1º nível e a média depois', () {
      // d10, CON +2: 12 no 1º nível + 3 × (6 + 2) = 36.
      expect(
        startingMaxHitPoints(hitDie: 10, constitutionModifier: 2, level: 4),
        36,
      );
      // CON muito baixa nunca dá menos de 1 PV por nível.
      expect(
        startingMaxHitPoints(hitDie: 6, constitutionModifier: -5, level: 3),
        3,
      );
    });
  });

  group('dano', () {
    test('sai primeiro do PV temporário', () {
      final hit = fighter(temp: 5).withDamage(8);

      expect(hit.temporaryHitPoints, 0);
      expect(hit.currentHitPoints, 27);
    });

    test('cair a 0 PV deixa o personagem morrendo', () {
      final down = fighter(current: 5).withDamage(10);

      expect(down.currentHitPoints, 0);
      expect(down.isDying, isTrue);
      expect(down.deathSaveFailures, 0);
    });

    test('dano massivo (o que sobra >= PV máximo) mata na hora', () {
      final dead = fighter(current: 5).withDamage(35);

      expect(dead.isDead, isTrue);
    });

    test('dano com 0 PV conta uma falha', () {
      final hit = fighter(current: 0, failures: 1).withDamage(3);

      expect(hit.deathSaveFailures, 2);
    });

    test('dano com 0 PV maior ou igual ao PV máximo mata', () {
      expect(fighter(current: 0).withDamage(30).isDead, isTrue);
    });

    test('dano num personagem estável o faz voltar a morrer', () {
      final hit = fighter(current: 0, successes: 3).withDamage(1);

      expect(hit.isStable, isFalse);
      expect(hit.isDying, isTrue);
      expect(hit.deathSaveFailures, 1);
    });
  });

  group('cura', () {
    test('não passa do PV máximo', () {
      expect(fighter(current: 25).withHealing(10)!.currentHitPoints, 30);
    });

    test('sair de 0 PV zera as salvaguardas', () {
      final healed = fighter(
        current: 0,
        successes: 2,
        failures: 1,
      ).withHealing(4)!;

      expect(healed.currentHitPoints, 4);
      expect(healed.deathSaveSuccesses, 0);
      expect(healed.deathSaveFailures, 0);
    });

    test('personagem morto não recebe cura', () {
      expect(fighter(current: 0, failures: 3).withHealing(10), isNull);
    });
  });

  group('salvaguardas contra a morte', () {
    test('10 ou mais é sucesso, menos é falha', () {
      final dying = fighter(current: 0);

      expect(dying.withDeathSave(10)!.deathSaveSuccesses, 1);
      expect(dying.withDeathSave(9)!.deathSaveFailures, 1);
    });

    test('1 natural conta duas falhas', () {
      expect(fighter(current: 0).withDeathSave(1)!.deathSaveFailures, 2);
    });

    test('20 natural volta com 1 PV', () {
      final up = fighter(current: 0, failures: 2).withDeathSave(20)!;

      expect(up.currentHitPoints, 1);
      expect(up.deathSaveFailures, 0);
      expect(up.isDying, isFalse);
    });

    test('3 sucessos estabilizam e 3 falhas matam', () {
      final stable = fighter(current: 0, successes: 2).withDeathSave(15)!;
      final dead = fighter(current: 0, failures: 2).withDeathSave(5)!;

      expect(stable.isStable, isTrue);
      expect(stable.isDying, isFalse);
      expect(dead.isDead, isTrue);
    });

    test('com PV acima de 0 a salvaguarda não se aplica', () {
      expect(fighter().withDeathSave(15), isNull);
    });
  });

  group('descansos', () {
    test('dado de vida cura o valor rolado + CON e gasta um dado', () {
      final rested = fighter(current: 10).withHitDieSpent(6)!;

      expect(rested.currentHitPoints, 18);
      expect(rested.hitDiceUsed, 1);
      expect(rested.hitDiceRemaining, 3);
    });

    test('sem dados de vida disponíveis nada muda', () {
      expect(fighter(hitDiceUsed: 4).withHitDieSpent(6), isNull);
    });

    test('cura do dado de vida nunca é negativa', () {
      expect(hitDieHealing(roll: 1, constitutionModifier: -3), 0);
    });

    test('descanso longo: PV cheio, metade dos dados de volta, uma exaustão '
        'a menos', () {
      final rested = fighter(
        current: 3,
        temp: 4,
        hitDiceUsed: 4,
        exhaustion: 2,
      ).afterLongRest()!;

      expect(rested.currentHitPoints, 30);
      expect(rested.temporaryHitPoints, 0);
      expect(rested.hitDiceUsed, 2); // 4 gastos - 2 recuperados (nível 4)
      expect(rested.exhaustionLevel, 1);
    });

    test('nível 1 recupera ao menos um dado de vida', () {
      expect(hitDiceRecoveredOnLongRest(1), 1);
    });
  });

  group('condições e exaustão', () {
    test('liga e desliga uma condição', () {
      final poisoned = fighter().withConditionToggled(Condition.poisoned);
      final cured = poisoned.withConditionToggled(Condition.poisoned);

      expect(poisoned.conditions, [Condition.poisoned]);
      expect(cured.conditions, isEmpty);
    });

    test('exaustão fica entre 0 e 6, e 6 é morte', () {
      expect(fighter().withExhaustion(9).exhaustionLevel, 6);
      expect(fighter().withExhaustion(-1).exhaustionLevel, 0);
      expect(fighter(exhaustion: 6).isDead, isTrue);
    });
  });

  group('PV máximo manual', () {
    test('subir o máximo sobe os PV atuais pela mesma diferença', () {
      final c = fighter(current: 20).withMaxHitPoints(38)!;
      expect(c.maxHitPoints, 38);
      expect(c.currentHitPoints, 28);
    });

    test('baixar o máximo só corta o que passa do novo máximo', () {
      expect(fighter(current: 30).withMaxHitPoints(25)!.currentHitPoints, 25);
      expect(fighter(current: 10).withMaxHitPoints(25)!.currentHitPoints, 10);
    });

    test('valor menor que 1 ou igual ao atual não muda nada', () {
      expect(fighter().withMaxHitPoints(0), isNull);
      expect(fighter().withMaxHitPoints(30), isNull);
    });
  });
}
