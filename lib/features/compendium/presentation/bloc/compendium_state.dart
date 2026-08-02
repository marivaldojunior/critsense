part of 'compendium_bloc.dart';

/// Base selada para todos os estados emitidos pelo [CompendiumBloc].
sealed class CompendiumState {
  const CompendiumState();
}

/// Estado inicial antes de qualquer interação.
final class CompendiumInitial extends CompendiumState {
  const CompendiumInitial();
}

/// Emitido enquanto a requisição à API está em andamento.
final class CompendiumLoading extends CompendiumState {
  const CompendiumLoading();
}

/// Emitido quando a lista de magias foi carregada com sucesso.
final class CompendiumLoaded extends CompendiumState {
  /// Lista de magias retornada pela API.
  final List<SpellSummary> spells;

  const CompendiumLoaded(this.spells);
}

/// Emitido quando ocorre falha na requisição.
final class CompendiumError extends CompendiumState {
  /// Mensagem descritiva do erro para exibição na UI.
  final String message;

  const CompendiumError(this.message);
}
