import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/voice_command.dart';
import '../../domain/services/command_interpreter.dart';
import '../../domain/services/on_device_ai.dart';
import '../../domain/services/speech_input.dart';

enum VoiceStatus {
  idle,
  listening,
  interpreting,
  understood,
  notUnderstood,
  unavailable,
  error,
}

/// Onde a escuta foi aberta. Cada lugar aceita comandos diferentes.
enum VoiceScope {
  /// Ficha: dano, cura, rolagens, descansos, concentração e notas.
  character,

  /// Rastreador de iniciativa: dano e cura nas criaturas e os turnos.
  combat,

  /// Diário de Campanha: toda a fala vira uma nota, sem comandos.
  dictation,
}

class VoiceCommandState extends Equatable {
  final VoiceStatus status;

  /// O que o jogador falou (parcial enquanto ele fala).
  final String transcript;

  /// O comando entendido, para a confirmação.
  final VoiceCommand? command;

  /// Mensagem de erro ou de aviso.
  final String? message;

  /// Estado do modelo no aparelho; `null` enquanto o app não perguntou.
  final OnDeviceAiStatus? aiStatus;

  const VoiceCommandState({
    this.status = VoiceStatus.idle,
    this.transcript = '',
    this.command,
    this.message,
    this.aiStatus,
  });

  VoiceCommandState copyWith({String? message, OnDeviceAiStatus? aiStatus}) =>
      VoiceCommandState(
        status: status,
        transcript: transcript,
        command: command,
        message: message ?? this.message,
        aiStatus: aiStatus ?? this.aiStatus,
      );

  @override
  List<Object?> get props => [status, transcript, command, message, aiStatus];
}

/// Escuta a fala, converte num [VoiceCommand] e espera a confirmação.
///
/// O cubit nunca aplica o comando: a folha devolve o comando confirmado
/// para a tela que abriu a escuta.
class VoiceCommandCubit extends Cubit<VoiceCommandState> {
  VoiceCommandCubit(
    this._speech,
    this._interpreter, {
    required this.scope,
    this._ai,
  }) : super(const VoiceCommandState());

  final SpeechInput _speech;
  final CommandInterpreter _interpreter;
  final OnDeviceAi? _ai;
  final VoiceScope scope;

  bool _ready = false;
  OnDeviceAiStatus? _aiStatus;

  /// Todo estado novo leva o estado do modelo no aparelho.
  @override
  void emit(VoiceCommandState state) =>
      super.emit(state.copyWith(aiStatus: _aiStatus));

  Future<void> _refreshAi() async {
    final ai = _ai;
    if (ai == null || scope == VoiceScope.dictation) return;
    _aiStatus = await ai.status();
    if (!isClosed) emit(state);
  }

  /// Baixa o Gemini Nano. O Android pode levar alguns minutos.
  Future<void> downloadAi() async {
    final ai = _ai;
    if (ai == null) return;
    _aiStatus = OnDeviceAiStatus.downloading;
    emit(state);
    final ok = await ai.download();
    _aiStatus = await ai.status();
    if (isClosed) return;
    emit(
      state.copyWith(
        message: ok
            ? 'A IA do aparelho está pronta. Fale o comando de novo.'
            : 'Não foi possível baixar a IA do aparelho.',
      ),
    );
  }

  /// Começa a ouvir. Na primeira vez, prepara o microfone.
  Future<void> listen() async {
    if (_aiStatus == null) unawaited(_refreshAi());
    if (!_ready) {
      _ready = await _speech.initialize();
      if (!_ready) {
        emit(
          const VoiceCommandState(
            status: VoiceStatus.unavailable,
            message:
                'O reconhecimento de voz não está disponível. Confira a '
                'permissão do microfone ou digite o comando.',
          ),
        );
        return;
      }
    }
    emit(const VoiceCommandState(status: VoiceStatus.listening));
    await _speech.listen(
      onText: (text, isFinal) {
        if (isClosed) return;
        if (isFinal) {
          submit(text);
        } else {
          emit(
            VoiceCommandState(status: VoiceStatus.listening, transcript: text),
          );
        }
      },
      onError: (message) {
        if (isClosed || state.status != VoiceStatus.listening) return;
        emit(VoiceCommandState(status: VoiceStatus.error, message: message));
      },
    );
  }

  /// Para de ouvir; o último texto vira o resultado final.
  Future<void> stop() => _speech.stop();

  /// Interpreta um texto falado ou digitado.
  Future<void> submit(String text) async {
    final transcript = text.trim();
    if (transcript.isEmpty) {
      emit(
        const VoiceCommandState(
          status: VoiceStatus.error,
          message: 'Não ouvi nada. Toque no microfone e fale de novo.',
        ),
      );
      return;
    }
    if (scope == VoiceScope.dictation) {
      emit(
        VoiceCommandState(
          status: VoiceStatus.understood,
          transcript: transcript,
          command: NoteCommand(transcript),
        ),
      );
      return;
    }
    emit(
      VoiceCommandState(
        status: VoiceStatus.interpreting,
        transcript: transcript,
      ),
    );
    VoiceCommand? command;
    try {
      command = await _interpreter.interpret(transcript);
    } catch (_) {
      command = null;
    }
    if (isClosed) return;
    if (command != null && !_accepts(command)) command = null;
    emit(
      VoiceCommandState(
        status: command == null
            ? VoiceStatus.notUnderstood
            : VoiceStatus.understood,
        transcript: transcript,
        command: command,
        message: command == null
            ? 'Não entendi o comando. Fale de novo ou digite.'
            : null,
      ),
    );
  }

  /// O rastreador só aceita dano, cura e turnos.
  bool _accepts(VoiceCommand command) => switch (scope) {
    VoiceScope.combat =>
      command is DamageCommand ||
          command is HealCommand ||
          command is NextTurnCommand ||
          command is PreviousTurnCommand,
    VoiceScope.character =>
      command is! NextTurnCommand && command is! PreviousTurnCommand,
    VoiceScope.dictation => command is NoteCommand,
  };

  @override
  Future<void> close() async {
    try {
      await _speech.cancel();
    } catch (_) {
      // A escuta já parou ou nunca começou.
    }
    return super.close();
  }
}
