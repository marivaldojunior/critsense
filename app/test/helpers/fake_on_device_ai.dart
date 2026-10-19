import 'package:crit_sense/features/voice_commands/domain/services/on_device_ai.dart';

/// Modelo falso: devolve [reply] e conta as chamadas.
class FakeOnDeviceAi implements OnDeviceAi {
  FakeOnDeviceAi({this.current = OnDeviceAiStatus.available, this.reply});

  OnDeviceAiStatus current;
  String? reply;
  String? lastPrompt;
  int generations = 0;

  @override
  Future<OnDeviceAiStatus> status() async => current;

  @override
  Future<bool> download() async {
    current = OnDeviceAiStatus.available;
    return true;
  }

  @override
  Future<String?> generate(
    String prompt, {
    double temperature = 0.1,
    int maxOutputTokens = 256,
  }) async {
    generations++;
    lastPrompt = prompt;
    return reply;
  }
}
