part of 'monster_detail_bloc.dart';

/// Base selada para todos os estados emitidos pelo [MonsterDetailBloc].
sealed class MonsterDetailState {
  const MonsterDetailState();
}

/// Estado inicial antes de qualquer interação.
final class MonsterDetailInitial extends MonsterDetailState {
  const MonsterDetailInitial();
}

/// Emitido enquanto a requisição à API está em andamento.
final class MonsterDetailLoading extends MonsterDetailState {
  const MonsterDetailLoading();
}

/// Emitido quando os detalhes foram carregados com sucesso.
final class MonsterDetailLoaded extends MonsterDetailState {
  /// Detalhes completos do monstro retornados pela API.
  final MonsterDetail monster;

  const MonsterDetailLoaded(this.monster);
}

/// Emitido quando ocorre falha na requisição.
final class MonsterDetailError extends MonsterDetailState {
  /// Mensagem descritiva do erro para exibição na UI.
  final String message;

  const MonsterDetailError(this.message);
}
