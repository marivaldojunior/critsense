part of 'compendium_bloc.dart';

/// Base selada para todos os eventos do [CompendiumBloc].
sealed class CompendiumEvent {
  const CompendiumEvent();
}

/// Solicita ao BLoC que busque a lista de magias da API.
final class LoadSpellsEvent extends CompendiumEvent {
  const LoadSpellsEvent();
}
