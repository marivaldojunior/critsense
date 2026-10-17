part of 'session_notes_bloc.dart';

/// Fase atual do carregamento das notas de sessão.
enum SessionNotesStatus {
  /// Estado inicial antes de qualquer carga.
  initial,

  /// Carga das notas em andamento.
  loading,

  /// Notas carregadas com sucesso.
  success,

  /// A carga das notas falhou.
  failure,
}

/// Estado único e imutável do [SessionNotesBloc], atualizado via [copyWith].
///
/// Um estado único (em vez de uma hierarquia `sealed`) mantém [notes]
/// visível quando uma operação de escrita falha: a UI só mostra
/// [errorMessage] num SnackBar, sem trocar a lista por uma tela de erro.
class SessionNotesState extends Equatable {
  /// Fase atual do carregamento.
  final SessionNotesStatus status;

  /// Notas visíveis, da mais recente para a mais antiga. Não inclui as notas
  /// escondidas à espera da confirmação de exclusão.
  final List<SessionNote> notes;

  /// Mensagem da última falha; `null` quando a última operação deu certo.
  final String? errorMessage;

  const SessionNotesState({
    this.status = SessionNotesStatus.initial,
    this.notes = const [],
    this.errorMessage,
  });

  /// Copia o estado trocando só os campos informados. [errorMessage] não é
  /// herdado: toda nova emissão limpa o erro anterior, a menos que um novo
  /// seja passado.
  SessionNotesState copyWith({
    SessionNotesStatus? status,
    List<SessionNote>? notes,
    String? errorMessage,
  }) {
    return SessionNotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage];
}
