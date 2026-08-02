part of 'spell_detail_bloc.dart';

/// Base selada para todos os estados emitidos pelo [SpellDetailBloc].
sealed class SpellDetailState {
  const SpellDetailState();
}

/// Estado inicial antes de qualquer interação.
final class SpellDetailInitial extends SpellDetailState {
  const SpellDetailInitial();
}

/// Emitido enquanto a requisição à API está em andamento.
final class SpellDetailLoading extends SpellDetailState {
  const SpellDetailLoading();
}

/// Emitido quando os detalhes foram carregados com sucesso.
final class SpellDetailLoaded extends SpellDetailState {
  /// Detalhes completos da magia retornados pela API.
  final SpellDetail spell;

  const SpellDetailLoaded(this.spell);
}

/// Emitido quando ocorre falha na requisição.
final class SpellDetailError extends SpellDetailState {
  /// Mensagem descritiva do erro para exibição na UI.
  final String message;

  const SpellDetailError(this.message);
}
