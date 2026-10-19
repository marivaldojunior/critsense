import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/voice_commands/domain/entities/voice_command.dart';
import 'package:crit_sense/features/voice_commands/domain/services/command_interpreter.dart';
import 'package:crit_sense/features/voice_commands/presentation/cubit/voice_command_cubit.dart';
import 'package:crit_sense/features/voice_commands/presentation/widgets/voice_command_sheet.dart';

import '../../helpers/fake_speech_input.dart';

/// Testa a escuta, a interpretação e a confirmação dos comandos.
void main() {
  VoiceCommandCubit newCubit(FakeSpeechInput speech, VoiceScope scope) =>
      VoiceCommandCubit(speech, const RuleBasedInterpreter(), scope: scope);

  test('o texto parcial aparece e o final vira um comando', () async {
    final speech = FakeSpeechInput();
    final cubit = newCubit(speech, VoiceScope.character);
    addTearDown(cubit.close);

    await cubit.listen();
    speech.say('levei oito', isFinal: false);
    expect(cubit.state.status, VoiceStatus.listening);
    expect(cubit.state.transcript, 'levei oito');

    speech.say('levei oito de dano');
    await pumpEventQueue();
    expect(cubit.state.status, VoiceStatus.understood);
    expect(cubit.state.command, const DamageCommand(8));
  });

  test('sem microfone, avisa e aceita o texto digitado', () async {
    final cubit = newCubit(
      FakeSpeechInput(available: false),
      VoiceScope.character,
    );
    addTearDown(cubit.close);

    await cubit.listen();
    expect(cubit.state.status, VoiceStatus.unavailable);

    await cubit.submit('curar 5');
    expect(cubit.state.command, const HealCommand(5));
  });

  test('frase sem comando pede para falar de novo', () async {
    final cubit = newCubit(FakeSpeechInput(), VoiceScope.character);
    addTearDown(cubit.close);

    await cubit.submit('o mestre está atrasado');
    expect(cubit.state.status, VoiceStatus.notUnderstood);
    expect(cubit.state.command, isNull);
  });

  test('cada lugar aceita só os seus comandos', () async {
    final combat = newCubit(FakeSpeechInput(), VoiceScope.combat);
    final character = newCubit(FakeSpeechInput(), VoiceScope.character);
    addTearDown(combat.close);
    addTearDown(character.close);

    await combat.submit('descanso longo');
    expect(combat.state.status, VoiceStatus.notUnderstood);
    await combat.submit('próximo turno');
    expect(combat.state.command, const NextTurnCommand());

    await character.submit('próximo turno');
    expect(character.state.status, VoiceStatus.notUnderstood);
  });

  test('no ditado, toda a fala vira uma nota', () async {
    final cubit = newCubit(FakeSpeechInput(), VoiceScope.dictation);
    addTearDown(cubit.close);

    await cubit.submit('levei 8 de dano do dragão');
    expect(cubit.state.command, const NoteCommand('levei 8 de dano do dragão'));
  });

  testWidgets('a folha mostra o comando e devolve ao tocar em Aplicar', (
    tester,
  ) async {
    final speech = FakeSpeechInput();
    sl.registerFactoryParam<VoiceCommandCubit, VoiceScope, void>(
      (scope, _) => newCubit(speech, scope),
    );
    addTearDown(sl.reset);
    VoiceCommand? applied;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async => applied = await showVoiceCommandSheet(
                  context,
                  scope: VoiceScope.character,
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Ouvindo...'), findsOneWidget);

    speech.say('rolar dois d seis mais três');
    await tester.pumpAndSettle();
    expect(find.text('Rolar 2d6+3'), findsOneWidget);

    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
    expect(applied, const RollCommand('2d6+3'));
  });
}
