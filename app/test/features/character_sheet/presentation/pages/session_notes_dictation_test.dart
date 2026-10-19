import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/session_note.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/add_session_note_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_session_note_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_session_notes_usecase.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/session_notes_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/pages/session_notes_screen.dart';
import 'package:crit_sense/features/voice_commands/domain/entities/voice_command.dart';
import 'package:crit_sense/features/voice_commands/domain/services/command_interpreter.dart';
import 'package:crit_sense/features/voice_commands/presentation/cubit/voice_command_cubit.dart';

import '../../../../helpers/fake_speech_input.dart';

class _MockGetNotes extends Mock implements GetSessionNotesUseCase {}

class _MockAddNote extends Mock implements AddSessionNoteUseCase {}

class _MockDeleteNote extends Mock implements DeleteSessionNoteUseCase {}

/// Testa o ditado de notas no Diário de Campanha.
void main() {
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

  test('o título da nota ditada usa as primeiras palavras', () {
    expect(noteTitleFrom('A taverna pegou fogo'), 'A taverna pegou fogo');
    expect(
      noteTitleFrom('O rei mentiu sobre o dragão vermelho da montanha'),
      'O rei mentiu sobre o dragão...',
    );
  });

  testWidgets('a nota ditada abre o formulário preenchido e é salva', (
    tester,
  ) async {
    final getNotes = _MockGetNotes();
    final addNote = _MockAddNote();
    when(() => getNotes('c1')).thenAnswer((_) async => const []);
    when(() => addNote(any())).thenAnswer((_) async {});
    final speech = FakeSpeechInput();
    sl
      ..registerFactory<SessionNotesBloc>(
        () => SessionNotesBloc(getNotes, addNote, _MockDeleteNote()),
      )
      ..registerFactoryParam<VoiceCommandCubit, VoiceScope, void>(
        (scope, _) => VoiceCommandCubit(
          speech,
          const RuleBasedInterpreter(),
          scope: scope,
        ),
      );
    addTearDown(sl.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: SessionNotesScreen(characterId: 'c1', characterName: 'Thorin'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ditar nota'));
    await tester.pumpAndSettle();
    speech.say('o ferreiro deve 50 peças de ouro');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Anotação'), findsOneWidget);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final saved =
        verify(() => addNote(captureAny())).captured.single as SessionNote;
    expect(saved.content, 'o ferreiro deve 50 peças de ouro');
    expect(saved.title, 'o ferreiro deve 50 peças de...');
  });
}
