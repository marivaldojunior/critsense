import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/core/database/app_database.dart';
import 'package:crit_sense/core/files/backup_file_gateway.dart';
import 'package:crit_sense/features/character_sheet/data/backup/character_backup_codec.dart';
import 'package:crit_sense/features/character_sheet/data/repositories/character_repository_impl.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character_spell.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/coins.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/condition.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/inventory_item.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/proficiency.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/session_note.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/character_backup_usecases.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_backup_cubit.dart';

class _FakeFiles implements BackupFileGateway {
  String? sharedName;
  String? sharedJson;
  String? toPick;

  @override
  Future<void> shareJson(String fileName, String json) async {
    sharedName = fileName;
    sharedJson = json;
  }

  @override
  Future<String?> pickJson() async => toPick;
}

class _MockExport extends Mock implements ExportCharacterUseCase {}

class _MockImport extends Mock implements ImportCharacterUseCase {}

/// Testa o backup de personagem: o formato JSON, a ida e volta no banco e o
/// cubit da tela.
void main() {
  final character = Character(
    id: 'c1',
    name: 'Thorin Escudo-de-Carvalho',
    race: 'Dwarf',
    characterClass: 'Fighter',
    level: 5,
    speed: 25,
    armorClassBonus: 1,
    maxHitPoints: 44,
    currentHitPoints: 30,
    temporaryHitPoints: 5,
    hitDiceUsed: 2,
    conditions: const [Condition.poisoned],
    exhaustionLevel: 1,
    inspiration: true,
    attributes: const Attribute(strength: 16, constitution: 16),
    alignment: 'Leal e Bom',
    background: 'Soldado',
    personalityTraits: 'Teimoso',
    ideals: 'Honra',
    bonds: 'Clã',
    flaws: 'Orgulho',
    experiencePoints: 6500,
    proficiencies: const [SavingThrowProficiency(AttributeType.strength)],
    otherProficiencies: const ['Armaduras pesadas'],
    languages: const ['Comum', 'Anão'],
    spellSlotsUsed: const [1, 0, 0, 0, 0, 0, 0, 0, 0],
    resourcesUsed: const {'action-surge': 1},
    coins: const Coins().withAmount(Coin.gold, 42),
    avatarPath: '/storage/thorin.png',
    defeatedBosses: const ['Goblin Boss'],
  );

  group('ida e volta no banco', () {
    late AppDatabase db;
    late CharacterRepositoryImpl repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = CharacterRepositoryImpl(db);
      await repository.saveCharacter(character);
      await repository.addInventoryItem(
        const InventoryItem(
          id: 'i1',
          characterId: 'c1',
          itemIndex: 'longsword',
          name: 'Longsword',
          equipmentCategory: 'Weapon',
          equipped: true,
          damageDice: '1d8',
          weaponProperties: ['versatile'],
        ),
      );
      await repository.addInventoryItem(
        const InventoryItem(
          id: 'i2',
          characterId: 'c1',
          itemIndex: 'custom:i2',
          name: 'Amuleto da avó',
          equipmentCategory: 'Personalizado',
          requiresAttunement: true,
        ),
      );
      await repository.saveCharacterSpell(
        const CharacterSpell(
          id: 's1',
          characterId: 'c1',
          spellIndex: 'shield',
          name: 'Shield',
          level: 1,
          prepared: true,
        ),
      );
      await repository.addSessionNote(
        SessionNote(
          id: 'n1',
          characterId: 'c1',
          title: 'Sessão 1',
          content: 'A mina',
          createdAt: DateTime(2026, 3, 1, 20),
        ),
      );
    });

    tearDown(() => db.close());

    test(
      'importar o backup cria um personagem novo igual ao original',
      () async {
        final json = await repository.exportCharacter('c1');
        final imported = await repository.importCharacter(json);

        final all = await repository.getAllCharacters();
        expect(all, hasLength(2));
        expect(imported.id, isNot('c1'));

        final copy = all.firstWhere((c) => c.id == imported.id);
        expect(copy.name, character.name);
        expect(copy.level, 5);
        expect(copy.currentHitPoints, 30);
        expect(copy.temporaryHitPoints, 5);
        expect(copy.hitDiceUsed, 2);
        expect(copy.conditions, [Condition.poisoned]);
        expect(copy.exhaustionLevel, 1);
        expect(copy.inspiration, isTrue);
        expect(copy.attributes.strength, 16);
        expect(copy.experiencePoints, 6500);
        expect(copy.proficiencies, const [
          SavingThrowProficiency(AttributeType.strength),
        ]);
        expect(copy.otherProficiencies, ['Armaduras pesadas']);
        expect(copy.languages, ['Comum', 'Anão']);
        expect(copy.spellSlotsUsed.first, 1);
        expect(copy.resourcesUsed, {'action-surge': 1});
        expect(copy.coins.of(Coin.gold), 42);
        expect(copy.armorClassBonus, 1);
        expect(copy.defeatedBosses, ['Goblin Boss']);
        // O avatar é um caminho do aparelho de origem: não vai no backup.
        expect(copy.avatarPath, isNull);

        final items = await repository.getCharacterInventory(imported.id);
        expect(items.map((i) => i.name), ['Amuleto da avó', 'Longsword']);
        expect(items.every((i) => i.id != 'i1' && i.id != 'i2'), isTrue);
        final sword = items.firstWhere((i) => i.name == 'Longsword');
        expect(sword.equipped, isTrue);
        expect(sword.damageDice, '1d8');
        expect(sword.weaponProperties, ['versatile']);
        final amulet = items.firstWhere((i) => i.isCustom);
        expect(amulet.itemIndex, 'custom:${amulet.id}');
        expect(amulet.requiresAttunement, isTrue);

        final spells = await repository.getCharacterSpells(imported.id);
        expect(spells.single.spellIndex, 'shield');
        expect(spells.single.prepared, isTrue);

        final notes = await repository.getSessionNotes(imported.id);
        expect(notes.single.title, 'Sessão 1');
        expect(notes.single.createdAt, DateTime(2026, 3, 1, 20));

        // O original continua intacto.
        expect(await repository.getCharacterInventory('c1'), hasLength(2));
      },
    );

    test('importar o mesmo arquivo duas vezes cria dois personagens', () async {
      final json = await repository.exportCharacter('c1');
      await repository.importCharacter(json);
      await repository.importCharacter(json);

      expect(await repository.getAllCharacters(), hasLength(3));
    });
  });

  group('formato', () {
    const codec = CharacterBackupCodec();
    var counter = 0;
    String newId() => 'id-${counter++}';

    test('o arquivo tem o formato e a versão', () {
      final json =
          jsonDecode(codec.encode(CharacterBackup(character: character)))
              as Map<String, dynamic>;

      expect(json['format'], 'critsense-character');
      expect(json['version'], 1);
      expect((json['character'] as Map)['avatarPath'], isNull);
    });

    test('recusa JSON inválido, outro formato e versão mais nova', () {
      expect(
        () => codec.decode('{nao', newId: newId),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => codec.decode('{"format": "outro"}', newId: newId),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('CritSense'),
          ),
        ),
      );
      expect(
        () => codec.decode(
          '{"format": "critsense-character", "version": 99, "character": {}}',
          newId: newId,
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('versão mais nova'),
          ),
        ),
      );
    });

    test('campos que faltam usam os valores padrão', () {
      final backup = codec.decode(
        '{"format": "critsense-character", "version": 1, '
        '"character": {"name": "Mínimo"}}',
        newId: newId,
      );

      expect(backup.character.name, 'Mínimo');
      expect(backup.character.level, 1);
      expect(backup.character.speed, 30);
      expect(backup.inventory, isEmpty);
    });
  });

  group('CharacterBackupCubit', () {
    late _MockExport export;
    late _MockImport import;
    late _FakeFiles files;
    late CharacterBackupCubit cubit;

    setUp(() {
      export = _MockExport();
      import = _MockImport();
      files = _FakeFiles();
      cubit = CharacterBackupCubit(export, import, files);
    });

    tearDown(() => cubit.close());

    test('exportar compartilha o arquivo com o nome do personagem', () async {
      when(() => export('c1')).thenAnswer((_) async => '{"ok": true}');

      await cubit.export(character);

      expect(files.sharedName, 'thorin-escudo-de-carvalho.critsense.json');
      expect(files.sharedJson, '{"ok": true}');
      expect(cubit.state.status, BackupStatus.success);
    });

    test('importar devolve o personagem novo', () async {
      files.toPick = '{}';
      when(() => import('{}')).thenAnswer((_) async => character);

      await cubit.import();

      expect(cubit.state.imported, same(character));
      expect(cubit.state.message, contains('importado'));
    });

    test('cancelar a escolha do arquivo não mostra mensagem', () async {
      await cubit.import();

      expect(cubit.state.status, BackupStatus.idle);
      expect(cubit.state.message, isNull);
      verifyNever(() => import(any()));
    });

    test('arquivo inválido mostra a mensagem do formato', () async {
      files.toPick = 'x';
      when(
        () => import('x'),
      ).thenThrow(const FormatException('O arquivo não é um JSON válido.'));

      await cubit.import();

      expect(cubit.state.status, BackupStatus.failure);
      expect(cubit.state.message, 'O arquivo não é um JSON válido.');
    });

    test('nome de arquivo sem acentos nem espaços', () {
      expect(
        CharacterBackupCubit.fileNameFor(character.copyWith(name: 'Ângela Çé')),
        'angela-ce.critsense.json',
      );
    });
  });
}
