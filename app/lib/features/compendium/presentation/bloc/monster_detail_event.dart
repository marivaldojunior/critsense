part of 'monster_detail_bloc.dart';

/// Base selada para todos os eventos do [MonsterDetailBloc].
sealed class MonsterDetailEvent {
  const MonsterDetailEvent();
}

/// Solicita ao BLoC que busque os detalhes do monstro identificado por [index].
final class LoadMonsterDetailEvent extends MonsterDetailEvent {
  /// Índice do monstro na API (ex: "adult-red-dragon").
  final String index;

  const LoadMonsterDetailEvent(this.index);
}
