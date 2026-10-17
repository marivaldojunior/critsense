part of 'spell_detail_bloc.dart';

/// Base selada para todos os eventos do [SpellDetailBloc].
sealed class SpellDetailEvent {
  const SpellDetailEvent();
}

/// Solicita ao BLoC que busque os detalhes da magia identificada por [index].
final class LoadSpellDetailEvent extends SpellDetailEvent {
  /// Índice da magia na API (ex: "acid-arrow").
  final String index;

  const LoadSpellDetailEvent(this.index);
}
