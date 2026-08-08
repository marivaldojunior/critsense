import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

// Arquivo gerado pelo build_runner. Execute:
// dart run build_runner build --delete-conflicting-outputs
part 'app_database.g.dart';

/// Ponto central de acesso ao banco de dados SQLite da aplicação via Drift.
///
/// O Drift gera, a partir das anotações e das [Tables], toda a infraestrutura
/// de queries type-safe em [app_database.g.dart]. Nunca edite o arquivo `.g.dart`.
@DriftDatabase(tables: [Characters, Attributes, InventoryItems, SessionNotes])
class AppDatabase extends _$AppDatabase {
  /// Cria a instância recebendo o executor de queries.
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  /// Aplica migrações incrementais quando o banco existente é mais antigo que
  /// [schemaVersion]. Equivale ao `Update-Database` do EF Core, que aplica
  /// apenas as migrations pendentes sem recriar o banco.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(sessionNotes);
      }
      if (from < 4) {
        await m.addColumn(characters, characters.alignment);
        await m.addColumn(characters, characters.background);
      }
    },
  );

  /// Cria a conexão lazy com o arquivo `critsense.sqlite` no diretório de documentos.
  ///
  /// [LazyDatabase] adia a abertura do arquivo até a primeira query, garantindo
  /// que [getApplicationDocumentsDirectory] seja chamado apenas após a inicialização
  /// completa do Flutter Engine — seguro para uso em `main.dart`.
  ///
  /// [NativeDatabase.createInBackground] abre o banco em um isolate dedicado,
  /// evitando bloqueio da thread principal durante leituras e escritas pesadas.
  static QueryExecutor openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'critsense.sqlite'));

      return NativeDatabase.createInBackground(
        file,
        setup: (rawDb) {
          // O SQLite desativa foreign keys por padrão; este PRAGMA as habilita
          // para que a cascade delete em [Attributes] funcione corretamente.
          rawDb.execute('PRAGMA foreign_keys = ON;');
        },
      );
    });
  }
}
