import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/utils/bloc_event_transformers.dart';

import '../../domain/entities/equipment_summary.dart';
import '../../domain/usecases/get_equipments_usecase.dart';

part 'equipment_event.dart';
part 'equipment_state.dart';

/// BLoC responsável pelo estado da listagem de equipamentos do compêndio,
/// incluindo busca por texto e filtro rápido de categoria.
class EquipmentBloc extends Bloc<EquipmentEvent, EquipmentState> {
  final GetEquipmentsUseCase _getEquipments;

  /// Contador incrementado a cada busca disparada; usado para descartar a
  /// resposta de uma requisição obsoleta — ver o comentário equivalente em
  /// `CompendiumBloc._requestId`.
  int _requestId = 0;

  /// Injeta [getEquipments] e registra os handlers de eventos.
  EquipmentBloc(GetEquipmentsUseCase getEquipments)
    : _getEquipments = getEquipments,
      super(const EquipmentState()) {
    on<LoadEquipmentsEvent>(_onLoadEquipments);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounceRestartable(const Duration(milliseconds: 500)),
    );
    on<FilterToggled>(_onFilterToggled, transformer: restartable());
  }

  Future<void> _onLoadEquipments(
    LoadEquipmentsEvent event,
    Emitter<EquipmentState> emit,
  ) {
    return _fetch(
      emit,
      searchQuery: state.searchQuery,
      activeFilters: state.activeFilters,
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<EquipmentState> emit,
  ) {
    return _fetch(
      emit,
      searchQuery: event.query,
      activeFilters: state.activeFilters,
    );
  }

  Future<void> _onFilterToggled(
    FilterToggled event,
    Emitter<EquipmentState> emit,
  ) {
    final filters = Map<String, dynamic>.from(state.activeFilters);
    if (filters[event.filterType] == event.value) {
      filters.remove(event.filterType);
    } else {
      filters[event.filterType] = event.value;
    }
    return _fetch(emit, searchQuery: state.searchQuery, activeFilters: filters);
  }

  /// Busca os equipamentos que casam com [searchQuery]/[activeFilters] —
  /// ver o comentário equivalente em `CompendiumBloc._fetch`.
  Future<void> _fetch(
    Emitter<EquipmentState> emit, {
    required String searchQuery,
    required Map<String, dynamic> activeFilters,
  }) async {
    final requestId = ++_requestId;
    emit(
      state.copyWith(
        status: EquipmentStatus.loading,
        searchQuery: searchQuery,
        activeFilters: activeFilters,
      ),
    );

    try {
      final equipments = await _getEquipments(
        name: searchQuery.isEmpty ? null : searchQuery,
        equipmentCategory: activeFilters['equipmentCategory'] as String?,
      );
      if (requestId != _requestId) return;
      emit(
        state.copyWith(status: EquipmentStatus.success, equipments: equipments),
      );
    } catch (e) {
      if (requestId != _requestId) return;
      emit(
        state.copyWith(
          status: EquipmentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
