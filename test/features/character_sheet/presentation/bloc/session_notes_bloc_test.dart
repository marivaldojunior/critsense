import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/session_note.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/add_session_note_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_session_note_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_session_notes_usecase.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/session_notes_bloc.dart';

class _MockGetSessionNotesUseCase extends Mock
    implements GetSessionNotesUseCase {}

class _MockAddSessionNoteUseCase extends Mock
    implements AddSessionNoteUseCase {}

class _MockDeleteSessionNoteUseCase extends Mock
    implements DeleteSessionNoteUseCase {}

/// Testa o fluxo do Diário de Campanha no [SessionNotesBloc], em especial a
/// exclusão em duas etapas com "Desfazer".
void main() {
  late _MockGetSessionNotesUseCase getNotes;
  late _MockAddSessionNoteUseCase addNote;
  late _MockDeleteSessionNoteUseCase deleteNote;
  late SessionNotesBloc bloc;

  const characterId = 'char-1';

  SessionNote buildNote(String id) => SessionNote(
    id: id,
    characterId: characterId,
    title: 'Nota $id',
    content: 'Conteúdo $id',
    createdAt: DateTime(2026, 1, 1),
  );

  final noteA = buildNote('a');
  final noteB = buildNote('b');
  final noteC = buildNote('c');

  setUpAll(() => registerFallbackValue(buildNote('fallback')));

  setUp(() {
    getNotes = _MockGetSessionNotesUseCase();
    addNote = _MockAddSessionNoteUseCase();
    deleteNote = _MockDeleteSessionNoteUseCase();
    bloc = SessionNotesBloc(getNotes, addNote, deleteNote);

    when(
      () => getNotes(characterId),
    ).thenAnswer((_) async => [noteA, noteB, noteC]);
    when(() => deleteNote(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    if (!bloc.isClosed) await bloc.close();
  });

  /// Carrega as notas e espera o estado de sucesso.
  Future<void> load() async {
    bloc.add(const LoadSessionNotesEvent(characterId));
    await bloc.stream.firstWhere((s) => s.status == SessionNotesStatus.success);
  }

  /// Espera o bloc processar os eventos já enfileirados.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('LoadSessionNotesEvent carrega as notas do personagem', () async {
    await load();

    expect(bloc.state.notes, [noteA, noteB, noteC]);
  });

  test('falha na carga emite o status failure', () async {
    when(() => getNotes(characterId)).thenThrow(Exception('db'));

    bloc.add(const LoadSessionNotesEvent(characterId));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == SessionNotesStatus.failure,
    );

    expect(state.errorMessage, isNotNull);
  });

  test('HideSessionNoteEvent esconde a nota sem excluir do banco', () async {
    await load();

    bloc.add(HideSessionNoteEvent(noteB));
    await settle();

    expect(bloc.state.notes, [noteA, noteC]);
    verifyNever(() => deleteNote(any()));
  });

  test('UndoHideSessionNoteEvent devolve a nota à posição original', () async {
    await load();

    bloc.add(HideSessionNoteEvent(noteB));
    bloc.add(UndoHideSessionNoteEvent(noteB));
    await settle();

    expect(bloc.state.notes, [noteA, noteB, noteC]);
    verifyNever(() => deleteNote(any()));
  });

  test('ConfirmDeleteSessionNoteEvent exclui a nota do banco', () async {
    await load();

    bloc.add(HideSessionNoteEvent(noteB));
    bloc.add(ConfirmDeleteSessionNoteEvent(noteB));
    await settle();

    expect(bloc.state.notes, [noteA, noteC]);
    verify(() => deleteNote('b')).called(1);
  });

  test('falha na exclusão devolve a nota e informa o erro', () async {
    when(() => deleteNote('b')).thenThrow(Exception('db'));
    await load();

    bloc.add(HideSessionNoteEvent(noteB));
    bloc.add(ConfirmDeleteSessionNoteEvent(noteB));
    await settle();

    expect(bloc.state.notes, [noteA, noteB, noteC]);
    expect(bloc.state.errorMessage, isNotNull);
  });

  test('close conclui as exclusões ainda pendentes', () async {
    await load();

    bloc.add(HideSessionNoteEvent(noteA));
    await settle();
    await bloc.close();

    verify(() => deleteNote('a')).called(1);
  });

  test('AddSessionNoteEvent salva a nota e recarrega a lista', () async {
    final newNote = buildNote('d');
    when(() => addNote(newNote)).thenAnswer((_) async {});
    await load();
    when(
      () => getNotes(characterId),
    ).thenAnswer((_) async => [newNote, noteA, noteB, noteC]);

    bloc.add(AddSessionNoteEvent(newNote));
    await bloc.stream.firstWhere((s) => s.notes.length == 4);

    verify(() => addNote(newNote)).called(1);
    expect(bloc.state.notes.first, newNote);
  });
}
