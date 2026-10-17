import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Copia o arquivo do banco antes de uma migração de versão.
///
/// Se a migração falhar no aparelho, a cópia guarda os dados da versão
/// anterior. O app mantém só as [keep] cópias mais novas.
class DatabaseBackup {
  const DatabaseBackup._();

  /// Quantidade de cópias guardadas.
  static const keep = 3;

  /// Lê a versão do schema (`PRAGMA user_version`) direto do cabeçalho do
  /// arquivo SQLite: são os bytes 60 a 63, em big-endian. Devolve `null` se o
  /// arquivo não existe ou não é um banco SQLite.
  static int? readUserVersion(File file) {
    if (!file.existsSync()) return null;
    final RandomAccessFile raf;
    try {
      raf = file.openSync();
    } on FileSystemException {
      return null;
    }
    try {
      final header = raf.readSync(100);
      if (header.length < 100) return null;
      final magic = String.fromCharCodes(header.sublist(0, 15));
      if (magic != 'SQLite format 3') return null;
      return ByteData.sublistView(header).getUint32(60);
    } finally {
      raf.closeSync();
    }
  }

  /// Copia [database] quando a versão dele é menor que [targetVersion].
  ///
  /// A cópia fica na mesma pasta, com o nome
  /// `critsense.v<versão>.<data>.bak.sqlite`. Devolve a cópia, ou `null` se
  /// não há migração a fazer. Um erro na cópia não impede o app de abrir.
  static File? backupBeforeMigration(
    File database, {
    required int targetVersion,
    DateTime? now,
  }) {
    final version = readUserVersion(database);
    // Versão 0 é um banco vazio, que ainda não tem dados para proteger.
    if (version == null || version == 0 || version >= targetVersion) {
      return null;
    }
    try {
      final stamp = (now ?? DateTime.now())
          .toIso8601String()
          .replaceAll(RegExp(r'[^0-9]'), '')
          .substring(0, 14);
      final name = '${_baseName(database)}.v$version.$stamp.bak.sqlite';
      final copy = database.copySync(p.join(database.parent.path, name));
      _deleteOldBackups(database);
      return copy;
    } on FileSystemException {
      return null;
    }
  }

  /// Cópias de [database], da mais nova para a mais antiga.
  static List<File> backupsOf(File database) {
    final prefix = '${_baseName(database)}.v';
    final files =
        database.parent.listSync().whereType<File>().where((f) {
            final name = p.basename(f.path);
            return name.startsWith(prefix) && name.endsWith('.bak.sqlite');
          }).toList()
          ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    return files;
  }

  static void _deleteOldBackups(File database) {
    for (final old in backupsOf(database).skip(keep)) {
      old.deleteSync();
    }
  }

  static String _baseName(File database) =>
      p.basenameWithoutExtension(database.path);
}
