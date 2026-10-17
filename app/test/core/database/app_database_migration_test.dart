import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/core/database/app_database.dart';
import 'package:crit_sense/features/character_sheet/data/repositories/character_repository_impl.dart';

/// Testa as migrações do [AppDatabase] a partir de bancos criados à mão no
/// schema de versões antigas — o mesmo caso de um usuário que atualiza o app
/// com dados já salvos.
void main() {
  // Tabelas que não mudaram desde a versão 3.
  const attributesTable =
      'CREATE TABLE "attributes" ("character_id" TEXT NOT NULL REFERENCES '
      'characters (id) ON DELETE CASCADE, "forca" INTEGER NOT NULL DEFAULT 8, '
      '"destreza" INTEGER NOT NULL DEFAULT 8, "constituicao" INTEGER NOT NULL '
      'DEFAULT 8, "inteligencia" INTEGER NOT NULL DEFAULT 8, "sabedoria" '
      'INTEGER NOT NULL DEFAULT 8, "carisma" INTEGER NOT NULL DEFAULT 8, '
      'PRIMARY KEY ("character_id"))';
  const inventoryTable =
      'CREATE TABLE "inventory_items" ("id" TEXT NOT NULL, "character_id" TEXT '
      'NOT NULL REFERENCES characters (id) ON DELETE CASCADE, "item_index" TEXT '
      'NOT NULL, "name" TEXT NOT NULL, "equipment_category" TEXT NOT NULL, '
      'PRIMARY KEY ("id"))';
  const sessionNotesTable =
      'CREATE TABLE "session_notes" ("id" TEXT NOT NULL, "character_id" TEXT '
      'NOT NULL REFERENCES characters (id) ON DELETE CASCADE, "title" TEXT NOT '
      'NULL, "content" TEXT NOT NULL, "created_at" INTEGER NOT NULL, PRIMARY '
      'KEY ("id"))';

  // Versão 4: PV ainda em `hp_maximo`/`hp_atual`, sem Status de Combate.
  const charactersV4 =
      'CREATE TABLE "characters" ("id" TEXT NOT NULL, "nome" TEXT NOT NULL, '
      '"raca" TEXT NOT NULL, "classe" TEXT NOT NULL, "nivel" INTEGER NOT NULL, '
      '"hp_maximo" INTEGER NOT NULL, "hp_atual" INTEGER NOT NULL, '
      '"avatar_path" TEXT NULL, "alignment" TEXT NULL, "background" TEXT NULL, '
      'PRIMARY KEY ("id"))';

  // Versão 5: igual à atual, sem `spells` e `defeated_bosses`.
  const charactersV5 =
      'CREATE TABLE "characters" ("id" TEXT NOT NULL, "nome" TEXT NOT NULL, '
      '"raca" TEXT NOT NULL, "classe" TEXT NOT NULL, "nivel" INTEGER NOT NULL, '
      '"armor_class" INTEGER NOT NULL DEFAULT 10, "initiative" INTEGER NOT '
      'NULL DEFAULT 0, "speed" INTEGER NOT NULL DEFAULT 30, "max_hit_points" '
      'INTEGER NOT NULL, "current_hit_points" INTEGER NOT NULL, '
      '"temporary_hit_points" INTEGER NOT NULL DEFAULT 0, "avatar_path" TEXT '
      'NULL, "alignment" TEXT NULL, "background" TEXT NULL, '
      '"personality_traits" TEXT NULL, "ideals" TEXT NULL, "bonds" TEXT NULL, '
      '"flaws" TEXT NULL, "experience_points" INTEGER NOT NULL DEFAULT 0, '
      '"proficiency_bonus" INTEGER NOT NULL DEFAULT 2, PRIMARY KEY ("id"))';

  // Versão 6: igual à atual, sem `proficiencies`.
  const charactersV6 =
      'CREATE TABLE "characters" ("id" TEXT NOT NULL, "nome" TEXT NOT NULL, '
      '"raca" TEXT NOT NULL, "classe" TEXT NOT NULL, "nivel" INTEGER NOT NULL, '
      '"armor_class" INTEGER NOT NULL DEFAULT 10, "initiative" INTEGER NOT '
      'NULL DEFAULT 0, "speed" INTEGER NOT NULL DEFAULT 30, "max_hit_points" '
      'INTEGER NOT NULL, "current_hit_points" INTEGER NOT NULL, '
      '"temporary_hit_points" INTEGER NOT NULL DEFAULT 0, "avatar_path" TEXT '
      'NULL, "alignment" TEXT NULL, "background" TEXT NULL, '
      '"personality_traits" TEXT NULL, "ideals" TEXT NULL, "bonds" TEXT NULL, '
      '"flaws" TEXT NULL, "experience_points" INTEGER NOT NULL DEFAULT 0, '
      '"proficiency_bonus" INTEGER NOT NULL DEFAULT 2, "spells" TEXT NOT NULL '
      "DEFAULT '[]', \"defeated_bosses\" TEXT NOT NULL DEFAULT '[]', "
      'PRIMARY KEY ("id"))';

  /// Abre um [AppDatabase] sobre um banco em memória que começa na
  /// [version] informada, com as tabelas de [statements] e uma linha de
  /// personagem inserida por [insertCharacter].
  AppDatabase openLegacyDatabase({
    required int version,
    required List<String> statements,
    required String insertCharacter,
  }) {
    return AppDatabase(
      NativeDatabase.memory(
        setup: (rawDb) {
          // O `setup` roda a cada abertura; só cria o schema antigo uma vez.
          final userVersion =
              rawDb.select('PRAGMA user_version').first.values.first as int;
          if (userVersion != 0) return;

          for (final statement in statements) {
            rawDb.execute(statement);
          }
          rawDb.execute(insertCharacter);
          rawDb.execute(
            "INSERT INTO attributes (character_id, forca) VALUES ('c1', 15)",
          );
          rawDb.execute(
            "INSERT INTO session_notes VALUES ('n1', 'c1', 'T', 'C', 0)",
          );
          rawDb.execute('PRAGMA user_version = $version');
        },
      ),
    );
  }

  test('da versão 4 para a atual: renomeia os PV e cria as colunas novas '
      'com os valores padrão', () async {
    final db = openLegacyDatabase(
      version: 4,
      statements: [
        charactersV4,
        attributesTable,
        inventoryTable,
        sessionNotesTable,
      ],
      insertCharacter:
          "INSERT INTO characters (id, nome, raca, classe, nivel, hp_maximo, "
          "hp_atual, alignment) VALUES ('c1', 'Thorin', 'Anão', 'Guerreiro', "
          "3, 30, 12, 'Leal e Bom')",
    );
    addTearDown(db.close);

    final character = (await CharacterRepositoryImpl(
      db,
    ).getAllCharacters()).single;

    expect(character.name, 'Thorin');
    expect(character.maxHitPoints, 30);
    expect(character.currentHitPoints, 12);
    expect(character.alignment, 'Leal e Bom');
    expect(character.armorClass, 10);
    expect(character.initiative, 0);
    expect(character.speed, 30);
    expect(character.temporaryHitPoints, 0);
    expect(character.experiencePoints, 0);
    expect(character.proficiencyBonus, 2);
    expect(character.personalityTraits, '');
    expect(character.spells, isEmpty);
    expect(character.defeatedBosses, isEmpty);
    expect(character.attributes.strength, 15);
  });

  test('da versão 5 para a atual: cria magias e abates como listas '
      'vazias', () async {
    final db = openLegacyDatabase(
      version: 5,
      statements: [
        charactersV5,
        attributesTable,
        inventoryTable,
        sessionNotesTable,
      ],
      insertCharacter:
          "INSERT INTO characters (id, nome, raca, classe, nivel, "
          "max_hit_points, current_hit_points, armor_class) VALUES ('c1', "
          "'Thorin', 'Anão', 'Guerreiro', 3, 30, 12, 16)",
    );
    addTearDown(db.close);

    final character = (await CharacterRepositoryImpl(
      db,
    ).getAllCharacters()).single;

    expect(character.armorClass, 16);
    expect(character.spells, isEmpty);
    expect(character.defeatedBosses, isEmpty);
  });

  test('da versão 6 para a atual: cria as proficiências como lista vazia e '
      'mantém as magias', () async {
    final db = openLegacyDatabase(
      version: 6,
      statements: [
        charactersV6,
        attributesTable,
        inventoryTable,
        sessionNotesTable,
      ],
      insertCharacter:
          "INSERT INTO characters (id, nome, raca, classe, nivel, "
          "max_hit_points, current_hit_points, spells) VALUES ('c1', "
          "'Thorin', 'Anão', 'Guerreiro', 3, 30, 12, '[\"Shield\"]')",
    );
    addTearDown(db.close);

    final character = (await CharacterRepositoryImpl(
      db,
    ).getAllCharacters()).single;

    expect(character.proficiencies, isEmpty);
    expect(character.spells, ['Shield']);
  });

  test('a migração mantém as notas de sessão já salvas', () async {
    final db = openLegacyDatabase(
      version: 5,
      statements: [
        charactersV5,
        attributesTable,
        inventoryTable,
        sessionNotesTable,
      ],
      insertCharacter:
          "INSERT INTO characters (id, nome, raca, classe, nivel, "
          "max_hit_points, current_hit_points) VALUES ('c1', 'Thorin', "
          "'Anão', 'Guerreiro', 3, 30, 12)",
    );
    addTearDown(db.close);

    final notes = await CharacterRepositoryImpl(db).getSessionNotes('c1');

    expect(notes.map((n) => n.id), ['n1']);
  });

  test('um banco novo é criado direto na versão atual', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final version = await db
        .customSelect('PRAGMA user_version')
        .map((row) => row.data.values.first as int)
        .getSingle();

    expect(version, db.schemaVersion);
  });
}
