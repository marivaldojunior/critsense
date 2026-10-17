import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/session_note.dart';
import '../../domain/usecases/add_session_note_usecase.dart';
import '../../domain/usecases/delete_session_note_usecase.dart';
import '../../domain/usecases/get_session_notes_usecase.dart';

part 'session_notes_event.dart';
part 'session_notes_state.dart';

/// BLoC do Diário de Campanha: carrega, cria e exclui as notas de sessão de
/// um personagem.
///
/// A exclusão tem duas etapas para suportar "Desfazer": [HideSessionNoteEvent]
/// só tira a nota da lista visível, e [ConfirmDeleteSessionNoteEvent] (ou
/// [close]) é que remove a nota do banco.
class SessionNotesBloc extends Bloc<SessionNotesEvent, SessionNotesState> {
  final GetSessionNotesUseCase _getNotes;
  final AddSessionNoteUseCase _addNote;
  final DeleteSessionNoteUseCase _deleteNote;

  /// Personagem dono das notas, definido pelo último [LoadSessionNotesEvent].
  String? _characterId;

  /// Notas escondidas à espera de confirmação, com a posição que tinham na
  /// lista — usada por [UndoHideSessionNoteEvent] para devolvê-las ao mesmo
  /// lugar.
  final Map<String, ({SessionNote note, int index})> _pendingDeletions = {};

  /// Injeta os use cases e registra os handlers de eventos.
  SessionNotesBloc(
    GetSessionNotesUseCase getNotes,
    AddSessionNoteUseCase addNote,
    DeleteSessionNoteUseCase deleteNote,
  ) : _getNotes = getNotes,
      _addNote = addNote,
      _deleteNote = deleteNote,
      super(const SessionNotesState()) {
    on<LoadSessionNotesEvent>(_onLoad);
    on<AddSessionNoteEvent>(_onAdd);
    on<HideSessionNoteEvent>(_onHide);
    on<UndoHideSessionNoteEvent>(_onUndoHide);
    on<ConfirmDeleteSessionNoteEvent>(_onConfirmDelete);
  }

  Future<void> _onLoad(
    LoadSessionNotesEvent event,
    Emitter<SessionNotesState> emit,
  ) async {
    _characterId = event.characterId;
    emit(state.copyWith(status: SessionNotesStatus.loading));
    await _reload(emit);
  }

  /// Persiste a nota e recarrega a lista do banco, que já devolve a ordem
  /// correta (mais recente primeiro).
  Future<void> _onAdd(
    AddSessionNoteEvent event,
    Emitter<SessionNotesState> emit,
  ) async {
    try {
      await _addNote(event.note);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Não foi possível salvar a nota.'));
      return;
    }
    await _reload(emit);
  }

  void _onHide(HideSessionNoteEvent event, Emitter<SessionNotesState> emit) {
    final index = state.notes.indexWhere((n) => n.id == event.note.id);
    if (index == -1) return;

    _pendingDeletions[event.note.id] = (note: event.note, index: index);
    emit(state.copyWith(notes: state.notes.toList()..removeAt(index)));
  }

  void _onUndoHide(
    UndoHideSessionNoteEvent event,
    Emitter<SessionNotesState> emit,
  ) {
    final pending = _pendingDeletions.remove(event.note.id);
    if (pending == null) return;

    emit(state.copyWith(notes: _reinsert(pending)));
  }

  /// Exclui a nota do banco. Se a exclusão falhar, a nota volta para a
  /// lista, para a UI não mostrar um estado diferente do banco.
  Future<void> _onConfirmDelete(
    ConfirmDeleteSessionNoteEvent event,
    Emitter<SessionNotesState> emit,
  ) async {
    final pending = _pendingDeletions.remove(event.note.id);
    if (pending == null) return;

    try {
      await _deleteNote(event.note.id);
    } catch (e) {
      emit(
        state.copyWith(
          notes: _reinsert(pending),
          errorMessage: 'Não foi possível excluir a nota.',
        ),
      );
    }
  }

  /// Devolve [pending] à lista visível na posição original (limitada ao
  /// tamanho atual, caso outras notas tenham sido escondidas depois).
  List<SessionNote> _reinsert(({SessionNote note, int index}) pending) {
    return state.notes.toList()
      ..insert(pending.index.clamp(0, state.notes.length), pending.note);
  }

  Future<void> _reload(Emitter<SessionNotesState> emit) async {
    final characterId = _characterId;
    if (characterId == null) return;

    try {
      final notes = await _getNotes(characterId);
      emit(
        state.copyWith(
          status: SessionNotesStatus.success,
          notes: notes
              .where((n) => !_pendingDeletions.containsKey(n.id))
              .toList(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SessionNotesStatus.failure,
          errorMessage: 'Não foi possível carregar as notas.',
        ),
      );
    }
  }

  /// Ao sair da tela com um SnackBar de "Desfazer" ainda aberto, a nota já
  /// sumiu da lista para o usuário — então a exclusão é concluída aqui, em
  /// vez de a nota reaparecer na próxima abertura do diário.
  @override
  Future<void> close() async {
    final pending = _pendingDeletions.keys.toList();
    _pendingDeletions.clear();
    for (final noteId in pending) {
      try {
        await _deleteNote(noteId);
      } catch (_) {
        // A tela já fechou e não há onde mostrar o erro. A nota continua no
        // banco e reaparece na próxima abertura do diário.
      }
    }
    return super.close();
  }
}
