import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../domain/services/speech_input.dart';

/// [SpeechInput] com o reconhecimento de voz do Android (`speech_to_text`).
///
/// O Android usa o pacote de idioma pt-BR do aparelho quando ele está
/// instalado; sem ele, o reconhecimento pode usar a internet.
class DeviceSpeechInput implements SpeechInput {
  DeviceSpeechInput([SpeechToText? speech])
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  void Function(String message)? _onError;

  static const _localeId = 'pt_BR';

  @override
  Future<bool> initialize() async {
    try {
      return await _speech.initialize(onError: _handleError);
    } catch (_) {
      return false;
    }
  }

  void _handleError(SpeechRecognitionError error) {
    _onError?.call(_messageFor(error.errorMsg));
  }

  /// Converte os códigos de erro do Android numa frase para o jogador.
  static String _messageFor(String code) => switch (code) {
    'error_no_match' || 'error_speech_timeout' =>
      'Não entendi. Fale de novo, mais perto do microfone.',
    'error_network' || 'error_network_timeout' || 'error_server' =>
      'O reconhecimento de voz precisa de internet neste aparelho. Instale '
          'o pacote de voz pt-BR para usar sem internet.',
    'error_audio' => 'O microfone não respondeu.',
    'error_permission' || 'error_insufficient_permissions' =>
      'O app não tem permissão para usar o microfone.',
    'error_busy' => 'O reconhecimento de voz está ocupado. Tente de novo.',
    _ => 'A escuta falhou ($code).',
  };

  @override
  Future<void> listen({
    required void Function(String text, bool isFinal) onText,
    required void Function(String message) onError,
  }) async {
    _onError = onError;
    await _speech.listen(
      onResult: (result) => onText(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        partialResults: true,
        listenMode: ListenMode.dictation,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      ),
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();
}
