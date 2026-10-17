import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/hit_point_rules.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/spell_rules.dart';
import 'package:crit_sense/features/character_sheet/domain/srd/spell_slots.dart';
import 'package:crit_sense/features/character_sheet/domain/srd/srd_class.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa as tabelas de espaços de magia, a conjuração e o gasto de espaços.
void main() {
  group('tabelas do SRD', () {
    test('conjurador completo', () {
      expect(spellSlotsFor(SrdClass.wizard, 1), [2, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(spellSlotsFor(SrdClass.wizard, 5), [4, 3, 2, 0, 0, 0, 0, 0, 0]);
      expect(spellSlotsFor(SrdClass.cleric, 20), [4, 3, 3, 3, 3, 2, 2, 1, 1]);
    });

    test('meio-conjurador começa no 2º nível', () {
      expect(spellSlotsFor(SrdClass.paladin, 1), everyElement(0));
      expect(spellSlotsFor(SrdClass.ranger, 2), [2, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(spellSlotsFor(SrdClass.paladin, 17), [4, 3, 3, 3, 1, 0, 0, 0, 0]);
    });

    test('classes sem magia e Bruxo não têm espaços comuns', () {
      expect(spellSlotsFor(SrdClass.fighter, 10), everyElement(0));
      expect(spellSlotsFor(SrdClass.warlock, 10), everyElement(0));
      expect(spellSlotsFor(null, 10), everyElement(0));
    });

    test('Magia de Pacto do Bruxo', () {
      expect(pactMagicFor(SrdClass.warlock, 1), (slots: 1, slotLevel: 1));
      expect(pactMagicFor(SrdClass.warlock, 5), (slots: 2, slotLevel: 3));
      expect(pactMagicFor(SrdClass.warlock, 11), (slots: 3, slotLevel: 5));
      expect(pactMagicFor(SrdClass.warlock, 17), (slots: 4, slotLevel: 5));
      expect(pactMagicFor(SrdClass.wizard, 5), isNull);
    });
  });

  group('conjuração', () {
    test('CD e ataque mágico usam o atributo da classe', () {
      // Mago nível 5 (proficiência +3), INT 16 (+3).
      final wizard = buildTestCharacter(
        characterClass: 'Wizard',
        level: 5,
        attributes: const Attribute(intelligence: 16),
      );

      expect(wizard.spellSaveDc, 14);
      expect(wizard.spellAttackBonus, 6);
    });

    test('classe sem magia não tem CD nem ataque mágico', () {
      expect(buildTestCharacter().spellSaveDc, isNull);
      expect(buildTestCharacter().spellAttackBonus, isNull);
    });

    test('limite de magias preparadas', () {
      final wizard = buildTestCharacter(
        characterClass: 'Wizard',
        level: 5,
        attributes: const Attribute(intelligence: 16),
      );
      final paladin = buildTestCharacter(
        characterClass: 'Paladin',
        level: 5,
        attributes: const Attribute(charisma: 14),
      );
      final sorcerer = buildTestCharacter(characterClass: 'Sorcerer');

      expect(wizard.preparedSpellLimit, 8); // 3 + 5
      expect(paladin.preparedSpellLimit, 4); // 2 + 5 ~/ 2
      expect(sorcerer.preparedSpellLimit, isNull); // conhece, não prepara
    });

    test('truques e magias conhecidas por classe e nível', () {
      int? cantrips(String c, int level) => buildTestCharacter(
        characterClass: c,
        level: level,
      ).cantripsKnownLimit;
      int? known(String c, int level) =>
          buildTestCharacter(characterClass: c, level: level).spellsKnownLimit;

      expect(cantrips('Wizard', 1), 3);
      expect(cantrips('Wizard', 4), 4);
      expect(cantrips('Sorcerer', 10), 6);
      expect(cantrips('Paladin', 10), isNull);
      expect(cantrips('Fighter', 10), isNull);
      expect(known('Bard', 1), 4);
      expect(known('Bard', 10), 14);
      expect(known('Sorcerer', 20), 15);
      expect(known('Warlock', 11), 11);
      expect(known('Ranger', 1), 0);
      expect(known('Ranger', 2), 2);
      expect(known('Wizard', 5), isNull);
    });

    test('limite de preparadas é no mínimo 1', () {
      final weakCleric = buildTestCharacter(
        characterClass: 'Cleric',
        level: 1,
        attributes: const Attribute(wisdom: 6),
      );

      expect(weakCleric.preparedSpellLimit, 1);
    });
  });

  group('gasto de espaços', () {
    final wizard = buildTestCharacter(characterClass: 'Wizard', level: 3);

    test('gastar e devolver um espaço', () {
      final used = wizard.withSpellSlotUsed(1)!;

      expect(used.availableSpellSlots(1), 3);
      expect(used.withSpellSlotRestored(1)!.availableSpellSlots(1), 4);
    });

    test('não gasta além do máximo nem num nível sem espaços', () {
      var character = wizard;
      for (var i = 0; i < 4; i++) {
        character = character.withSpellSlotUsed(1)!;
      }

      expect(character.withSpellSlotUsed(1), isNull);
      expect(wizard.withSpellSlotUsed(3), isNull);
      expect(wizard.withSpellSlotRestored(1), isNull);
    });

    test('Descanso Longo devolve todos os espaços', () {
      final rested = wizard
          .withSpellSlotUsed(1)!
          .withSpellSlotUsed(2)!
          .afterLongRest()!;

      expect(rested.availableSpellSlots(1), 4);
      expect(rested.availableSpellSlots(2), 2);
    });

    test('Magia de Pacto volta no Descanso Curto', () {
      final warlock = buildTestCharacter(characterClass: 'Warlock', level: 3);
      final used = warlock.withPactSlotUsed()!.withPactSlotUsed()!;

      expect(used.withPactSlotUsed(), isNull); // só 2 espaços no 3º nível
      expect(used.afterShortRest()!.pactSlotsUsed, 0);
    });
  });
}
