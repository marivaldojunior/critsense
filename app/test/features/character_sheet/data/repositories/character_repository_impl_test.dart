import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/core/database/app_database.dart';
import 'package:crit_sense/features/character_sheet/data/repositories/character_repository_impl.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character_spell.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/coins.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/inventory_item.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/proficiency.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/session_note.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/skill.dart';

/// Testa o [CharacterRepositoryImpl] contra um banco Drift real em memória,
/// com o mesmo schema e as mesmas foreign keys do app.
void main() {
  late AppDatabase db;
  late CharacterRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = CharacterRepositoryImpl(db);
  });

  tearDown(() => db.close());

  Character buildCharacter({
    String id = 'char-1',
    String name = 'Thorin',
    int currentHitPoints = 12,
  }) => Character(
    id: id,
    name: name,
    race: 'Anão',
    characterClass: 'Guerreiro',
    level: 3,
    armorClassBonus: 1,
    speed: 25,
    maxHitPoints: 30,
    currentHitPoints: currentHitPoints,
    temporaryHitPoints: 4,
    attributes: const Attribute(strength: 15, constitution: 14),
    alignment: 'Leal e Bom',
    background: 'Soldado',
    personalityTraits: 'Teimoso',
    ideals: 'Honra',
    bonds: 'Clã',
    flaws: 'Orgulho',
    experiencePoints: 900,
    avatarPath: '/tmp/thorin.png',
    defeatedBosses: const ['Goblin Boss'],
  );

  InventoryItem buildItem(String id, {String characterId = 'char-1'}) =>
      InventoryItem(
        id: id,
        characterId: characterId,
        itemIndex: id,
        name: 'Item $id',
        equipmentCategory: 'Weapon',
      );

  SessionNote buildNote(String id, DateTime createdAt) => SessionNote(
    id: id,
    characterId: 'char-1',
    title: 'Sessão $id',
    content: 'Conteúdo $id',
    createdAt: createdAt,
  );

  group('personagens', () {
    test('saveCharacter grava e getAllCharacters lê todos os campos', () async {
      await repository.saveCharacter(buildCharacter());

      final loaded = (await repository.getAllCharacters()).single;

      expect(loaded.id, 'char-1');
      expect(loaded.name, 'Thorin');
      expect(loaded.race, 'Anão');
      expect(loaded.characterClass, 'Guerreiro');
      expect(loaded.level, 3);
      expect(loaded.armorClassBonus, 1);
      expect(loaded.speed, 25);
      expect(loaded.maxHitPoints, 30);
      expect(loaded.currentHitPoints, 12);
      expect(loaded.temporaryHitPoints, 4);
      expect(loaded.attributes.strength, 15);
      expect(loaded.attributes.constitution, 14);
      expect(loaded.attributes.dexterity, 8);
      expect(loaded.alignment, 'Leal e Bom');
      expect(loaded.background, 'Soldado');
      expect(loaded.personalityTraits, 'Teimoso');
      expect(loaded.ideals, 'Honra');
      expect(loaded.bonds, 'Clã');
      expect(loaded.flaws, 'Orgulho');
      expect(loaded.experiencePoints, 900);
      expect(loaded.proficiencyBonus, 2);
      expect(loaded.avatarPath, '/tmp/thorin.png');
      expect(loaded.defeatedBosses, ['Goblin Boss']);
    });

    test('saveCharacter grava as proficiências de perícia e de teste de '
        'resistência', () async {
      await repository.saveCharacter(
        buildCharacter().copyWith(
          proficiencies: const [
            SkillProficiency(Skill.stealth),
            SkillProficiency(Skill.perception),
            SavingThrowProficiency(AttributeType.dexterity),
          ],
        ),
      );

      final loaded = (await repository.getAllCharacters()).single;

      expect(loaded.proficiencies, const [
        SkillProficiency(Skill.stealth),
        SkillProficiency(Skill.perception),
        SavingThrowProficiency(AttributeType.dexterity),
      ]);
    });

    test(
      'uma chave de proficiência desconhecida é ignorada na carga',
      () async {
        await repository.saveCharacter(buildCharacter());
        await db.customStatement(
          'UPDATE characters SET proficiencies = ? WHERE id = ?',
          ['["skill:stealth","skill:removida","outro"]', 'char-1'],
        );

        final loaded = (await repository.getAllCharacters()).single;

        expect(loaded.proficiencies, const [SkillProficiency(Skill.stealth)]);
      },
    );

    test('saveCharacter com o mesmo id atualiza em vez de duplicar', () async {
      await repository.saveCharacter(buildCharacter(currentHitPoints: 30));
      await repository.saveCharacter(
        buildCharacter(
          currentHitPoints: 5,
        ).copyWith(attributes: const Attribute(strength: 10)),
      );

      final all = await repository.getAllCharacters();

      expect(all, hasLength(1));
      expect(all.single.currentHitPoints, 5);
      expect(all.single.attributes.strength, 10);
    });

    test(
      'atualizar o personagem não apaga o inventário nem as notas',
      () async {
        await repository.saveCharacter(buildCharacter());
        await repository.addInventoryItem(buildItem('sword'));
        await repository.addSessionNote(buildNote('n1', DateTime(2026, 1, 1)));

        await repository.saveCharacter(buildCharacter(currentHitPoints: 1));

        expect(await repository.getCharacterInventory('char-1'), hasLength(1));
        expect(await repository.getSessionNotes('char-1'), hasLength(1));
      },
    );

    test('deleteCharacter apaga em cascata atributos, itens e notas', () async {
      await repository.saveCharacter(buildCharacter());
      await repository.addInventoryItem(buildItem('sword'));
      await repository.addSessionNote(buildNote('n1', DateTime(2026, 1, 1)));

      await repository.deleteCharacter('char-1');

      expect(await repository.getAllCharacters(), isEmpty);
      expect(await db.select(db.attributes).get(), isEmpty);
      expect(await db.select(db.inventoryItems).get(), isEmpty);
      expect(await db.select(db.sessionNotes).get(), isEmpty);
    });
  });

  group('inventário', () {
    setUp(() async {
      await repository.saveCharacter(buildCharacter());
      await repository.saveCharacter(buildCharacter(id: 'char-2'));
    });

    test('lista só os itens do personagem pedido', () async {
      await repository.addInventoryItem(buildItem('sword'));
      await repository.addInventoryItem(
        buildItem('bow', characterId: 'char-2'),
      );

      final items = await repository.getCharacterInventory('char-1');

      expect(items.map((i) => i.id), ['sword']);
    });

    test('deleteInventoryItem remove só o item pedido', () async {
      await repository.addInventoryItem(buildItem('sword'));
      await repository.addInventoryItem(buildItem('shield'));

      await repository.deleteInventoryItem('sword');

      final items = await repository.getCharacterInventory('char-1');
      expect(items.map((i) => i.id), ['shield']);
    });

    test('um item de um personagem que não existe é recusado', () async {
      expect(
        () => repository.addInventoryItem(buildItem('x', characterId: 'nope')),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('inventário completo e moedas', () {
    setUp(() => repository.saveCharacter(buildCharacter()));

    test(
      'guarda quantidade, peso, equipado, sintonia e dados de combate',
      () async {
        await repository.addInventoryItem(
          buildItem('longsword').copyWith(
            quantity: 2,
            weight: 3,
            equipped: true,
            requiresAttunement: true,
            attuned: true,
            weaponCategory: 'Martial',
            weaponRange: 'Melee',
            damageDice: '1d8',
            damageType: 'Slashing',
            versatileDamageDice: '1d10',
            weaponProperties: const ['versatile'],
            armorCategory: 'Shield',
            armorBase: 2,
            armorDexBonus: true,
            armorMaxDexBonus: 2,
          ),
        );

        final item = (await repository.getCharacterInventory('char-1')).single;

        expect(item.quantity, 2);
        expect(item.weight, 3);
        expect(item.equipped, isTrue);
        expect(item.requiresAttunement, isTrue);
        expect(item.attuned, isTrue);
        expect(item.detailsLoaded, isTrue);
        expect(item.weaponCategory, 'Martial');
        expect(item.weaponRange, 'Melee');
        expect(item.damageDice, '1d8');
        expect(item.damageType, 'Slashing');
        expect(item.versatileDamageDice, '1d10');
        expect(item.weaponProperties, ['versatile']);
        expect(item.armorCategory, 'Shield');
        expect(item.armorBase, 2);
        expect(item.armorDexBonus, isTrue);
        expect(item.armorMaxDexBonus, 2);
      },
    );

    test('guarda as moedas', () async {
      await repository.saveCharacter(
        buildCharacter().copyWith(
          coins: const Coins()
              .withAmount(Coin.gold, 15)
              .withAmount(Coin.copper, 7)
              .withAmount(Coin.platinum, 1),
        ),
      );

      final coins = (await repository.getAllCharacters()).single.coins;

      expect(coins.of(Coin.gold), 15);
      expect(coins.of(Coin.copper), 7);
      expect(coins.of(Coin.platinum), 1);
      expect(coins.of(Coin.silver), 0);
    });
  });

  group('grimório', () {
    setUp(() => repository.saveCharacter(buildCharacter()));

    CharacterSpell spell(String id, String index, int? level) => CharacterSpell(
      id: id,
      characterId: 'char-1',
      spellIndex: index,
      name: index,
      level: level,
    );

    test('lista as magias por nível, com as sem nível no fim', () async {
      await repository.saveCharacterSpell(spell('s1', 'fireball', 3));
      await repository.saveCharacterSpell(spell('s2', 'light', 0));
      await repository.saveCharacterSpell(spell('s3', 'mystery', null));
      await repository.saveCharacterSpell(spell('s4', 'shield', 1));

      final spells = await repository.getCharacterSpells('char-1');

      expect(spells.map((s) => s.spellIndex), [
        'light',
        'shield',
        'fireball',
        'mystery',
      ]);
    });

    test('a mesma magia duas vezes atualiza em vez de duplicar', () async {
      await repository.saveCharacterSpell(spell('s1', 'shield', 1));
      await repository.saveCharacterSpell(
        spell('s2', 'shield', null).copyWith(prepared: true),
      );

      final spells = await repository.getCharacterSpells('char-1');

      expect(spells, hasLength(1));
      expect(spells.single.id, 's1');
      expect(spells.single.prepared, isTrue);
      // O nível conhecido não se perde quando a atualização não o traz.
      expect(spells.single.level, 1);
    });

    test('remove a magia e apaga o grimório junto com o personagem', () async {
      await repository.saveCharacterSpell(spell('s1', 'shield', 1));
      await repository.saveCharacterSpell(spell('s2', 'light', 0));

      await repository.deleteCharacterSpell('s1');
      expect((await repository.getCharacterSpells('char-1')).map((s) => s.id), [
        's2',
      ]);

      await repository.deleteCharacter('char-1');
      expect(await db.select(db.characterSpells).get(), isEmpty);
    });

    test('guarda os espaços de magia gastos', () async {
      await repository.saveCharacter(
        buildCharacter().copyWith(
          spellSlotsUsed: [2, 1, 0, 0, 0, 0, 0, 0, 0],
          pactSlotsUsed: 1,
        ),
      );

      final loaded = (await repository.getAllCharacters()).single;

      expect(loaded.spellSlotsUsed, [2, 1, 0, 0, 0, 0, 0, 0, 0]);
      expect(loaded.pactSlotsUsed, 1);
    });
  });

  group('notas de sessão', () {
    setUp(() => repository.saveCharacter(buildCharacter()));

    test('lista as notas da mais recente para a mais antiga', () async {
      await repository.addSessionNote(buildNote('old', DateTime(2026, 1, 1)));
      await repository.addSessionNote(buildNote('new', DateTime(2026, 3, 1)));
      await repository.addSessionNote(buildNote('mid', DateTime(2026, 2, 1)));

      final notes = await repository.getSessionNotes('char-1');

      expect(notes.map((n) => n.id), ['new', 'mid', 'old']);
      expect(notes.first.title, 'Sessão new');
      expect(notes.first.createdAt, DateTime(2026, 3, 1));
    });

    test('deleteSessionNote remove só a nota pedida', () async {
      await repository.addSessionNote(buildNote('a', DateTime(2026, 1, 1)));
      await repository.addSessionNote(buildNote('b', DateTime(2026, 1, 2)));

      await repository.deleteSessionNote('a');

      final notes = await repository.getSessionNotes('char-1');
      expect(notes.map((n) => n.id), ['b']);
    });
  });
}
