import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/class_resource_rules.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/hit_point_rules.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa os recursos de classe do SRD 5.1 e os usos de cada um.
void main() {
  Map<String, int> maxByKey(String characterClass, int level, {int cha = 10}) {
    final c = buildTestCharacter(
      characterClass: characterClass,
      level: level,
      attributes: Attribute(charisma: cha),
    );
    return {for (final r in c.classResources) r.key: r.max};
  }

  test('usos pela classe e pelo nível', () {
    expect(maxByKey('Barbarian', 1), {'rage': 2});
    expect(maxByKey('Barbarian', 6), {'rage': 4});
    expect(maxByKey('Fighter', 1), {'second-wind': 1});
    expect(maxByKey('Fighter', 17), {
      'second-wind': 1,
      'action-surge': 2,
      'indomitable': 3,
    });
    expect(maxByKey('Monk', 1), isEmpty);
    expect(maxByKey('Monk', 5), {'ki': 5});
    expect(maxByKey('Bard', 1, cha: 16), {'bardic-inspiration': 3});
    expect(maxByKey('Bard', 1, cha: 8), {'bardic-inspiration': 1});
    expect(maxByKey('Paladin', 3, cha: 14), {
      'divine-sense': 3,
      'lay-on-hands': 15,
      'channel-divinity': 1,
    });
    expect(maxByKey('Warlock', 13), {
      'mystic-arcanum-6': 1,
      'mystic-arcanum-7': 1,
    });
    expect(maxByKey('Ranger', 10), isEmpty);
    expect(maxByKey('Artesão', 10), isEmpty);
  });

  test('a Fúria não tem limite no 20º nível', () {
    final rage = buildTestCharacter(
      characterClass: 'Barbarian',
      level: 20,
    ).classResources.single;

    expect(rage.unlimited, isTrue);
  });

  test('a Inspiração de Bardo volta no Descanso Curto a partir do 5º', () {
    ResourceRecharge rechargeAt(int level) => buildTestCharacter(
      characterClass: 'Bard',
      level: level,
    ).classResources.single.recharge;

    expect(rechargeAt(4), ResourceRecharge.longRest);
    expect(rechargeAt(5), ResourceRecharge.shortRest);
  });

  test('gastar e devolver usos, sem passar dos limites', () {
    final fighter = buildTestCharacter(level: 2);

    final used = fighter.withResourceUsed('action-surge')!;
    expect(used.resourcesUsed, {'action-surge': 1});
    expect(used.withResourceUsed('action-surge'), isNull);
    expect(used.withResourceRestored('action-surge')!.resourcesUsed, isEmpty);
    expect(fighter.withResourceRestored('action-surge'), isNull);
    expect(fighter.withResourceUsed('rage'), isNull);
  });

  test('definir os usos restantes de um recurso grande', () {
    final paladin = buildTestCharacter(characterClass: 'Paladin', level: 4);

    final c = paladin.withResourceRemaining('lay-on-hands', 12)!;
    expect(c.resourcesUsed, {'lay-on-hands': 8});
    expect(c.withResourceRemaining('lay-on-hands', 99)!.resourcesUsed, isEmpty);
  });

  test('o Descanso Curto devolve só os recursos de Descanso Curto', () {
    final fighter = buildTestCharacter(
      level: 9,
    ).withResourceUsed('action-surge')!.withResourceUsed('indomitable')!;

    final rested = fighter.withShortRestResourcesRestored()!;
    expect(rested.resourcesUsed, {'indomitable': 1});
    expect(rested.withShortRestResourcesRestored(), isNull);
  });

  test('o Descanso Longo devolve todos os recursos', () {
    final fighter = buildTestCharacter(
      level: 9,
    ).withResourceUsed('indomitable')!;

    expect(fighter.afterLongRest()!.resourcesUsed, isEmpty);
  });
}
