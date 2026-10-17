part of 'session_notes_bloc.dart';

/// Base selada para todos os eventos do [SessionNotesBloc].
sealed class SessionNotesEvent {
  const SessionNotesEvent();
}

/// Carrega as notas do personagem [characterId].
final class LoadSessionNotesEvent extends SessionNotesEvent {
  final String characterId;

  const LoadSessionNotesEvent(this.characterId);
}

/// Persiste [note] e recarrega a lista.
final class AddSessionNoteEvent extends SessionNotesEvent {
  final SessionNote note;

  const AddSessionNoteEvent(this.note);
}

/// Esconde [note] da lista visível, sem excluir do banco ainda — primeira
/// etapa do fluxo de exclusão com "Desfazer".
final class HideSessionNoteEvent extends SessionNotesEvent {
  final SessionNote note;

  const HideSessionNoteEvent(this.note);
}

/// Devolve [note], escondida por [HideSessionNoteEvent], à posição original.
final class UndoHideSessionNoteEvent extends SessionNotesEvent {
  final SessionNote note;

  const UndoHideSessionNoteEvent(this.note);
}

/// Exclui do banco a [note] escondida por [HideSessionNoteEvent].
final class ConfirmDeleteSessionNoteEvent extends SessionNotesEvent {
  final SessionNote note;

  const ConfirmDeleteSessionNoteEvent(this.note);
}
