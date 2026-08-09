part of 'compendium_bloc.dart';

/// Base selada para todos os eventos do [CompendiumBloc].
sealed class CompendiumEvent {
  const CompendiumEvent();
}

/// Solicita ao BLoC que busque a lista de magias da API.
final class LoadSpellsEvent extends CompendiumEvent {
  const LoadSpellsEvent();
}

/// Disparado a cada mudança no texto da busca; o [CompendiumBloc] aplica um
/// debounce de 500ms antes de efetivamente buscar na API (ver
/// `debounceRestartable` em `bloc_event_transformers.dart`), para não
/// disparar uma requisição a cada letra digitada.
final class SearchQueryChanged extends CompendiumEvent {
  final String query;

  const SearchQueryChanged(this.query);
}

/// Alterna (toggle) o filtro [filterType] para [value]: se já é o filtro
/// ativo daquele tipo, remove; senão, substitui o valor anterior.
///
/// Ex: `FilterToggled('level', 3)` — filtro rápido de magias de Nível 3.
final class FilterToggled extends CompendiumEvent {
  final String filterType;
  final dynamic value;

  const FilterToggled(this.filterType, this.value);
}
