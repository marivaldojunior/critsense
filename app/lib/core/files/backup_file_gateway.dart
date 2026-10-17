import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Entrada e saída dos arquivos de backup. Fica atrás desta interface para
/// os testes não abrirem a folha de compartilhamento nem o seletor de
/// arquivos do sistema.
abstract interface class BackupFileGateway {
  /// Salva [json] num arquivo temporário [fileName] e abre a folha de
  /// compartilhamento do sistema (salvar em arquivos, Drive, e-mail...).
  Future<void> shareJson(String fileName, String json);

  /// Deixa o usuário escolher um arquivo `.json` e devolve o conteúdo, ou
  /// `null` se ele cancelar.
  Future<String?> pickJson();
}

/// [BackupFileGateway] com `share_plus` e `file_picker`.
class PlatformBackupFileGateway implements BackupFileGateway {
  const PlatformBackupFileGateway();

  @override
  Future<void> shareJson(String fileName, String json) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(json, encoding: utf8);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: fileName,
      ),
    );
  }

  @override
  Future<String?> pickJson() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    return utf8.decode(await file.readAsBytes());
  }
}
