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
import 'package:crit_sense/features/voice_commands/domain/services/on_device_ai.dart';
import 'package:crit_sense/features/voice_commands/domain/services/session_summarizer.dart';

import '../../helpers/fake_on_device_ai.dart';

class _MockGetNotes extends Mock implements GetSessionNotesUseCase {}

class _MockAddNote extends Mock implements AddSessionNoteUseCase {}

class _MockDeleteNote extends Mock implements DeleteSessionNoteUseCase {}

/// Testa o resumo da sessão com a IA do aparelho.
void main() {
  SessionNote note(String id, DateTime at, {String content = 'texto'}) =>
      SessionNote(
        id: id,
        characterId: 'c1',
        title: 'Nota $id',
        content: content,
        createdAt: at,
      );

  final notes = [
    note('a', DateTime(2026, 10, 10, 20)),
    note('c', DateTime(2026, 10, 17, 22), content: 'O rei mentiu'),
    note('b', DateTime(2026, 10, 17, 20), content: 'A ponte caiu'),
  ];

  setUpAll(() => registerFallbackValue(notes.first));

  test('pega só as notas do último dia, em ordem', () {
    final last = SessionSummarizer.notesOfLastSession(notes);

    expect(last.map((n) => n.id), ['b', 'c']);
    expect(SessionSummarizer.notesOfLastSession(const []), isEmpty);
  });

  test('o prompt leva as notas e respeita o limite de tamanho', () {
    final summarizer = SessionSummarizer(FakeOnDeviceAi());
    final prompt = summarizer.buildPrompt(
      SessionSummarizer.notesOfLastSession(notes),
    );
    expect(prompt, contains('- Nota b: A ponte caiu'));
    expect(prompt, contains('não invente'));

    final huge = [
      for (var i = 0; i < 50; i++)
        note('$i', DateTime(2026), content: 'x' * 500),
    ];
    expect(
      summarizer.buildPrompt(huge).length,
      lessThan(SessionSummarizer.maxNotesChars + 1000),
    );
  });

  test('resposta vazia do modelo vira null', () async {
    final ai = FakeOnDeviceAi(reply: '   ');

    expect(await SessionSummarizer(ai).summarize(notes), isNull);
    expect(await SessionSummarizer(ai).summarize(const []), isNull);
  });

  group('tela do diário', () {
    late _MockAddNote addNote;

    Future<void> pumpScreen(WidgetTester tester, FakeOnDeviceAi ai) async {
      final getNotes = _MockGetNotes();
      addNote = _MockAddNote();
      when(() => getNotes('c1')).thenAnswer((_) async => notes);
      when(() => addNote(any())).thenAnswer((_) async {});
      sl
        ..registerFactory<SessionNotesBloc>(
          () => SessionNotesBloc(getNotes, addNote, _MockDeleteNote()),
        )
        ..registerSingleton<OnDeviceAi>(ai);
      addTearDown(sl.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionNotesScreen(characterId: 'c1', characterName: 'Thorin'),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('o resumo aparece e pode virar uma nota', (tester) async {
      await pumpScreen(
        tester,
        FakeOnDeviceAi(reply: '- A ponte caiu.\n- O rei mentiu.'),
      );

      await tester.tap(find.byTooltip('Resumir sessão'));
      await tester.pumpAndSettle();
      expect(find.text('Resumo da sessão de 17/10/2026'), findsOneWidget);
      expect(find.text('- A ponte caiu.\n- O rei mentiu.'), findsOneWidget);

      await tester.tap(find.text('Salvar no diário'));
      await tester.pumpAndSettle();
      final saved =
          verify(() => addNote(captureAny())).captured.single as SessionNote;
      expect(saved.title, 'Resumo da sessão de 17/10/2026');
      expect(saved.content, contains('O rei mentiu'));
    });

    testWidgets('sem suporte no aparelho, só avisa', (tester) async {
      final ai = FakeOnDeviceAi(current: OnDeviceAiStatus.unavailable);
      await pumpScreen(tester, ai);

      await tester.tap(find.byTooltip('Resumir sessão'));
      await tester.pumpAndSettle();

      expect(find.textContaining('não está disponível'), findsOneWidget);
      expect(ai.generations, 0);
    });
  });
}
