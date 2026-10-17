import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/core/database/app_database.dart';
import 'package:crit_sense/features/character_sheet/data/repositories/character_repository_impl.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
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
    spells: const ['Shield'],
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
      expect(loaded.spells, ['Shield']);
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
