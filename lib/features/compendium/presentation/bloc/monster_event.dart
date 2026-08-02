part of 'monster_bloc.dart';

/// Base selada para todos os eventos do [MonsterBloc].
sealed class MonsterEvent {
  const MonsterEvent();
}

/// Solicita ao BLoC que busque a próxima página de monstros.
///
/// Pode ser disparado na inicialização da tela ou ao atingir o fim da lista
/// no scroll infinito.
final class FetchMonstersEvent extends MonsterEvent {
  const FetchMonstersEvent();
}
