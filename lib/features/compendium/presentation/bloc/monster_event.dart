part of 'monster_bloc.dart';

/// Base selada para todos os eventos do [MonsterBloc].
sealed class MonsterEvent {
  const MonsterEvent();
}

/// Solicita ao BLoC que busque a próxima página de monstros.
///
/// Pode ser disparado na inicialização da tela ou ao atingir o fim da lista
/// no scroll infinito. Sempre respeita a [MonsterState.searchQuery]/
/// [MonsterState.activeFilters] correntes.
final class FetchMonstersEvent extends MonsterEvent {
  const FetchMonstersEvent();
}

/// Disparado a cada mudança no texto da busca; o [MonsterBloc] aplica um
/// debounce de 500ms antes de efetivamente buscar na API (ver
/// `debounceRestartable` em `bloc_event_transformers.dart`), zerando a
/// paginação corrente.
final class SearchQueryChanged extends MonsterEvent {
  final String query;

  const SearchQueryChanged(this.query);
}

/// Alterna (toggle) o filtro [filterType] para [value], zerando a
/// paginação corrente: se já é o filtro ativo daquele tipo, remove; senão,
/// substitui o valor anterior.
///
/// Ex: `FilterToggled('challengeRating', 5)`.
final class FilterToggled extends MonsterEvent {
  final String filterType;
  final dynamic value;

  const FilterToggled(this.filterType, this.value);
}
