part of 'form_options_bloc.dart';

/// Estado base do [FormOptionsBloc].
abstract class FormOptionsState {}

/// Estado emitido enquanto as listas de classes e raças estão sendo carregadas.
class FormOptionsLoading extends FormOptionsState {}

/// Estado emitido após o carregamento bem-sucedido das opções do formulário.
class FormOptionsLoaded extends FormOptionsState {
  /// Lista de classes jogáveis disponíveis na API do D&D 5e.
  final List<ApiReference> classes;

  /// Lista de raças jogáveis disponíveis na API do D&D 5e.
  final List<ApiReference> races;

  FormOptionsLoaded({required this.classes, required this.races});
}

/// Estado emitido quando ocorre um erro ao carregar as opções do formulário.
class FormOptionsError extends FormOptionsState {
  /// Mensagem descritiva do erro ocorrido.
  final String message;

  FormOptionsError(this.message);
}
