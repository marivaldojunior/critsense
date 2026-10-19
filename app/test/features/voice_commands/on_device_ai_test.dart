import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/voice_commands/data/services/method_channel_on_device_ai.dart';
import 'package:crit_sense/features/voice_commands/domain/entities/voice_command.dart';
import 'package:crit_sense/features/voice_commands/domain/services/command_interpreter.dart';
import 'package:crit_sense/features/voice_commands/domain/services/llm_command_parser.dart';
import 'package:crit_sense/features/voice_commands/domain/services/on_device_ai.dart';
import 'package:crit_sense/features/voice_commands/presentation/cubit/voice_command_cubit.dart';

import '../../helpers/fake_on_device_ai.dart';
import '../../helpers/fake_speech_input.dart';

/// Testa a IA no aparelho: o JSON do modelo, o intérprete híbrido e o
/// canal com o Android.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const llm = LlmCommandParser();

  group('resposta do modelo', () {
    test('converte o JSON em comando', () {
      expect(
        llm.parse('{"action":"damage","amount":7,"target":null}'),
        const DamageCommand(7),
      );
      expect(
        llm.parse('Claro! {"action":"heal","amount":"4","target":"lobo"}'),
        const HealCommand(4, target: 'lobo'),
      );
      expect(
        llm.parse('```json\n{"action":"roll","notation":"3d8 + 2"}\n```'),
        const RollCommand('3d8+2'),
      );
      expect(
        llm.parse('{"action":"concentration","spell":null}'),
        const ConcentrationCommand(null),
      );
      expect(
        llm.parse('{"action":"note","text":"O ferreiro é um espião"}'),
        const NoteCommand('O ferreiro é um espião'),
      );
    });

    test('recusa respostas fora do formato ou impossíveis', () {
      expect(llm.parse(null), isNull);
      expect(llm.parse('não sei'), isNull);
      expect(llm.parse('{"action":"none"}'), isNull);
      expect(llm.parse('{"action":"damage","amount":-3}'), isNull);
      expect(llm.parse('{"action":"damage","amount":5000}'), isNull);
      expect(llm.parse('{"action":"roll","notation":"1d7"}'), isNull);
      expect(llm.parse('{"action":"delete_character"}'), isNull);
      expect(llm.parse('{"action":'), isNull);
    });

    test('o prompt leva a frase sem aspas duplas', () {
      final prompt = llm.buildPrompt('o "orc" me acertou');
      expect(prompt, contains("Frase: \"o 'orc' me acertou\""));
      expect(prompt.trimRight(), endsWith('JSON:'));
    });
  });

  group('intérprete híbrido', () {
    test('as regras respondem sem chamar o modelo', () async {
      final ai = FakeOnDeviceAi(reply: '{"action":"long_rest"}');
      final command = await HybridInterpreter(ai).interpret('dano 5');

      expect(command, const DamageCommand(5));
      expect(ai.generations, 0);
    });

    test('frase livre vai para o modelo', () async {
      final ai = FakeOnDeviceAi(
        reply: '{"action":"damage","amount":7,"target":null}',
      );
      final command = await HybridInterpreter(
        ai,
      ).interpret('aquele orc maldito arrancou sete pontos meus');

      expect(command, const DamageCommand(7));
      expect(ai.lastPrompt, contains('aquele orc maldito'));
    });

    test('sem o modelo pronto, a frase livre fica sem comando', () async {
      final ai = FakeOnDeviceAi(
        current: OnDeviceAiStatus.downloadable,
        reply: '{"action":"long_rest"}',
      );
      expect(
        await HybridInterpreter(ai).interpret('acho que o mago sabe de algo'),
        isNull,
      );
      expect(ai.generations, 0);
    });
  });

  test('o cubit mostra o estado do modelo e baixa quando pedido', () async {
    final ai = FakeOnDeviceAi(current: OnDeviceAiStatus.downloadable);
    final cubit = VoiceCommandCubit(
      FakeSpeechInput(),
      HybridInterpreter(ai),
      scope: VoiceScope.character,
      ai: ai,
    );
    addTearDown(cubit.close);

    await cubit.listen();
    await pumpEventQueue();
    expect(cubit.state.aiStatus, OnDeviceAiStatus.downloadable);

    await cubit.downloadAi();
    expect(cubit.state.aiStatus, OnDeviceAiStatus.available);
    expect(cubit.state.message, contains('pronta'));
  });

  group('canal com o Android', () {
    const channel = MethodChannel('com.marivaldojunior.critsense/genai');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('lê o estado e o texto gerado', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return switch (call.method) {
          'status' => 'downloadable',
          'generate' => '{"action":"long_rest"} ${call.arguments['prompt']}',
          _ => null,
        };
      });
      const ai = MethodChannelOnDeviceAi();

      expect(await ai.status(), OnDeviceAiStatus.downloadable);
      expect(await ai.generate('oi'), '{"action":"long_rest"} oi');
    });

    test('sem o canal nativo, o modelo fica indisponível', () async {
      const ai = MethodChannelOnDeviceAi();

      expect(await ai.status(), OnDeviceAiStatus.unavailable);
      expect(await ai.generate('oi'), isNull);
      expect(await ai.download(), isFalse);
    });

    test('um erro do Android vira indisponível', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => throw PlatformException(code: 'generate_failed'),
      );
      const ai = MethodChannelOnDeviceAi();

      expect(await ai.status(), OnDeviceAiStatus.unavailable);
      expect(await ai.generate('oi'), isNull);
    });
  });
}
