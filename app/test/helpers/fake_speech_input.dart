import 'package:crit_sense/features/voice_commands/domain/services/speech_input.dart';

/// Microfone falso: os testes mandam o texto com [say].
class FakeSpeechInput implements SpeechInput {
  FakeSpeechInput({this.available = true});

  final bool available;
  void Function(String text, bool isFinal)? _onText;
  int listens = 0;

  void say(String text, {bool isFinal = true}) => _onText?.call(text, isFinal);

  @override
  Future<bool> initialize() async => available;

  @override
  Future<void> listen({
    required void Function(String text, bool isFinal) onText,
    required void Function(String message) onError,
  }) async {
    listens++;
    _onText = onText;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> cancel() async {}
}
