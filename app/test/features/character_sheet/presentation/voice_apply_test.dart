import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/session_note.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/add_session_note_usecase.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/voice/apply_voice_command.dart';
import 'package:crit_sense/features/voice_commands/domain/services/command_interpreter.dart';
import 'package:crit_sense/features/voice_commands/presentation/cubit/voice_command_cubit.dart';

import '../../../helpers/character_test_helpers.dart';
import '../../../helpers/fake_speech_input.dart';

class _MockAddNote extends Mock implements AddSessionNoteUseCase {}

/// Testa os comandos por voz aplicados na ficha.
void main() {
  late FakeSpeechInput speech;
  late _MockAddNote addNote;

  setUpAll(
    () => registerFallbackValue(
      SessionNote(
        id: 'x',
        characterId: 'c1',
        title: '',
        content: '',
        createdAt: DateTime(2026),
      ),
    ),
  );

  setUp(() {
    speech = FakeSpeechInput();
    addNote = _MockAddNote();
    when(() => addNote(any())).thenAnswer((_) async {});
    sl
      ..registerSingleton<AddSessionNoteUseCase>(addNote)
      ..registerFactoryParam<VoiceCommandCubit, VoiceScope, void>(
        (scope, _) => VoiceCommandCubit(
          speech,
          const RuleBasedInterpreter(),
          scope: scope,
        ),
      );
  });

  tearDown(() => sl.reset());

  Future<CharacterBloc> pumpButton(WidgetTester tester) async {
    final (:bloc, saveCharacter: _) =
        await tester.runAsync(
          () => loadedCharacterBloc([buildTestCharacter()]),
        ) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => listenForCharacterCommand(context, 'c1'),
                  child: const Text('falar'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return bloc;
  }

  Future<void> sayAndApply(WidgetTester tester, String text) async {
    await tester.tap(find.text('falar'));
    await tester.pumpAndSettle();
    speech.say(text);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
  }

  Future<void> waitFor(
    WidgetTester tester,
    CharacterBloc bloc,
    bool Function(CharacterState) test,
  ) async {
    await tester.runAsync(
      () => bloc.stream.firstWhere(test).timeout(const Duration(seconds: 5)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dano e cura falados mudam os PV da ficha', (tester) async {
    final bloc = await pumpButton(tester);

    await sayAndApply(tester, 'levei doze de dano');
    await waitFor(
      tester,
      bloc,
      (s) => s.findCharacter('c1')!.currentHitPoints == 18,
    );
    expect(find.text('Dano de 12 aplicado.'), findsOneWidget);

    await sayAndApply(tester, 'curar cinco');
    await waitFor(
      tester,
      bloc,
      (s) => s.findCharacter('c1')!.currentHitPoints == 23,
    );
  });

  testWidgets('a nota falada vai para o diário', (tester) async {
    await pumpButton(tester);

    await sayAndApply(tester, 'anotar a ponte caiu');

    final note =
        verify(() => addNote(captureAny())).captured.single as SessionNote;
    expect(note.content, 'A ponte caiu');
    expect(note.characterId, 'c1');
  });

  testWidgets('a concentração falada aparece na ficha', (tester) async {
    final bloc = await pumpButton(tester);

    await sayAndApply(tester, 'concentrar em bless');
    await waitFor(
      tester,
      bloc,
      (s) => s.findCharacter('c1')!.concentrationSpell == 'Bless',
    );
  });
}
