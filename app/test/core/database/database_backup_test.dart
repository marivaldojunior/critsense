import 'dart:io';

import 'package:drift/drift.dart'
    show OpeningDetails, QueryExecutor, QueryExecutorUser;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:crit_sense/core/database/database_backup.dart';

/// Testa a cópia do banco antes das migrações.
void main() {
  late Directory dir;
  late File dbFile;

  Future<void> createDatabase(int version) async {
    final executor = NativeDatabase(dbFile);
    await executor.ensureOpen(_NoUser());
    await executor.runCustom('CREATE TABLE t (id INTEGER)');
    await executor.runCustom('PRAGMA user_version = $version');
    await executor.close();
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('critsense_backup_');
    dbFile = File(p.join(dir.path, 'critsense.sqlite'));
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('lê a versão do schema no cabeçalho do arquivo', () async {
    await createDatabase(9);

    expect(DatabaseBackup.readUserVersion(dbFile), 9);
  });

  test('arquivo que não existe ou não é SQLite não tem versão', () {
    expect(DatabaseBackup.readUserVersion(dbFile), isNull);

    dbFile.writeAsStringSync('não é um banco');
    expect(DatabaseBackup.readUserVersion(dbFile), isNull);
  });

  test('copia o banco quando a versão é mais antiga', () async {
    await createDatabase(9);

    final copy = DatabaseBackup.backupBeforeMigration(
      dbFile,
      targetVersion: 12,
      now: DateTime(2026, 10, 17, 9, 30, 5),
    );

    expect(copy, isNotNull);
    expect(p.basename(copy!.path), 'critsense.v9.20261017093005.bak.sqlite');
    expect(copy.readAsBytesSync(), dbFile.readAsBytesSync());
  });

  test('não copia um banco já atualizado nem um banco novo', () async {
    expect(
      DatabaseBackup.backupBeforeMigration(dbFile, targetVersion: 12),
      isNull,
    );

    await createDatabase(12);
    expect(
      DatabaseBackup.backupBeforeMigration(dbFile, targetVersion: 12),
      isNull,
    );
    expect(DatabaseBackup.backupsOf(dbFile), isEmpty);
  });

  test('guarda só as cópias mais novas', () async {
    await createDatabase(9);

    for (var minute = 0; minute < 5; minute++) {
      DatabaseBackup.backupBeforeMigration(
        dbFile,
        targetVersion: 12,
        now: DateTime(2026, 10, 17, 9, minute),
      );
    }

    final names = DatabaseBackup.backupsOf(
      dbFile,
    ).map((f) => p.basename(f.path));
    expect(names, [
      'critsense.v9.20261017090400.bak.sqlite',
      'critsense.v9.20261017090300.bak.sqlite',
      'critsense.v9.20261017090200.bak.sqlite',
    ]);
  });
}

class _NoUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
