import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/files/backup_file_gateway.dart';

import '../../domain/entities/character.dart';
import '../../domain/usecases/character_backup_usecases.dart';

enum BackupStatus { idle, working, success, failure }

class CharacterBackupState extends Equatable {
  final BackupStatus status;

  /// Mensagem para o SnackBar (sucesso ou erro).
  final String? message;

  /// Personagem criado pela última importação.
  final Character? imported;

  const CharacterBackupState({
    this.status = BackupStatus.idle,
    this.message,
    this.imported,
  });

  @override
  List<Object?> get props => [status, message, imported?.id];
}

/// Exporta um personagem para um arquivo JSON e importa um arquivo como um
/// personagem novo.
class CharacterBackupCubit extends Cubit<CharacterBackupState> {
  CharacterBackupCubit(this._export, this._import, this._files)
    : super(const CharacterBackupState());

  final ExportCharacterUseCase _export;
  final ImportCharacterUseCase _import;
  final BackupFileGateway _files;

  Future<void> export(Character character) async {
    emit(const CharacterBackupState(status: BackupStatus.working));
    try {
      final json = await _export(character.id);
      await _files.shareJson(fileNameFor(character), json);
      emit(
        CharacterBackupState(
          status: BackupStatus.success,
          message: '${character.name} exportado.',
        ),
      );
    } catch (_) {
      emit(
        const CharacterBackupState(
          status: BackupStatus.failure,
          message: 'Não foi possível exportar o personagem.',
        ),
      );
    }
  }

  Future<void> import() async {
    emit(const CharacterBackupState(status: BackupStatus.working));
    final String? json;
    try {
      json = await _files.pickJson();
    } catch (_) {
      emit(
        const CharacterBackupState(
          status: BackupStatus.failure,
          message: 'Não foi possível abrir o arquivo.',
        ),
      );
      return;
    }
    if (json == null) {
      emit(const CharacterBackupState());
      return;
    }
    try {
      final character = await _import(json);
      emit(
        CharacterBackupState(
          status: BackupStatus.success,
          message: '${character.name} importado.',
          imported: character,
        ),
      );
    } on FormatException catch (e) {
      emit(
        CharacterBackupState(status: BackupStatus.failure, message: e.message),
      );
    } catch (_) {
      emit(
        const CharacterBackupState(
          status: BackupStatus.failure,
          message: 'Não foi possível importar o personagem.',
        ),
      );
    }
  }

  /// Nome do arquivo: o nome do personagem sem acentos nem espaços, ex:
  /// `thorin-escudo-de-carvalho.critsense.json`.
  static String fileNameFor(Character character) {
    const accents = {
      'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'é': 'e', 'ê': 'e', 'í': 'i', //
      'ó': 'o', 'ô': 'o', 'õ': 'o', 'ú': 'u', 'ü': 'u', 'ç': 'c',
    };
    final lower = character.name.toLowerCase().split('').map((ch) {
      return accents[ch] ?? ch;
    }).join();
    final slug = lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return '${slug.isEmpty ? 'personagem' : slug}.critsense.json';
  }
}
