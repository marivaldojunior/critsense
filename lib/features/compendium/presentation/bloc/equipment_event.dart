part of 'equipment_bloc.dart';

/// Base selada para todos os eventos do [EquipmentBloc].
sealed class EquipmentEvent {
  const EquipmentEvent();
}

/// Solicita ao BLoC que busque a lista de equipamentos da API.
final class LoadEquipmentsEvent extends EquipmentEvent {
  const LoadEquipmentsEvent();
}

/// Disparado a cada mudança no texto da busca; o [EquipmentBloc] aplica um
/// debounce de 500ms antes de efetivamente buscar na API (ver
/// `debounceRestartable` em `bloc_event_transformers.dart`), para não
/// disparar uma requisição a cada letra digitada.
final class SearchQueryChanged extends EquipmentEvent {
  final String query;

  const SearchQueryChanged(this.query);
}

/// Alterna (toggle) o filtro [filterType] para [value]: se já é o filtro
/// ativo daquele tipo, remove; senão, substitui o valor anterior.
///
/// Ex: `FilterToggled('equipmentCategory', 'weapon')`.
final class FilterToggled extends EquipmentEvent {
  final String filterType;
  final dynamic value;

  const FilterToggled(this.filterType, this.value);
}
