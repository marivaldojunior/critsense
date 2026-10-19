import 'package:flutter/services.dart';

import '../../domain/services/on_device_ai.dart';

/// [OnDeviceAi] com o canal `OnDeviceAiChannel.kt` (ML Kit GenAI Prompt API).
/// Fora do Android, o canal não existe e o modelo fica indisponível.
class MethodChannelOnDeviceAi implements OnDeviceAi {
  const MethodChannelOnDeviceAi([
    this._channel = const MethodChannel('com.marivaldojunior.critsense/genai'),
  ]);

  final MethodChannel _channel;

  @override
  Future<OnDeviceAiStatus> status() async {
    try {
      final name = await _channel.invokeMethod<String>('status');
      return OnDeviceAiStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => OnDeviceAiStatus.unavailable,
      );
    } on MissingPluginException {
      return OnDeviceAiStatus.unavailable;
    } on PlatformException {
      return OnDeviceAiStatus.unavailable;
    }
  }

  @override
  Future<bool> download() async {
    try {
      return await _channel.invokeMethod<bool>('download') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<String?> generate(
    String prompt, {
    double temperature = 0.1,
    int maxOutputTokens = 256,
  }) async {
    try {
      return await _channel.invokeMethod<String>('generate', {
        'prompt': prompt,
        'temperature': temperature,
        'maxOutputTokens': maxOutputTokens,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
