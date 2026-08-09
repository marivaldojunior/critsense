import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/utils/bloc_event_transformers.dart';

import '../../domain/entities/spell_summary.dart';
import '../../domain/usecases/get_spells_usecase.dart';

part 'compendium_event.dart';
part 'compendium_state.dart';

/// BLoC responsável pelo estado da listagem de magias do compêndio,
/// incluindo busca por texto e filtros rápidos (nível/escola).
class CompendiumBloc extends Bloc<CompendiumEvent, CompendiumState> {
  final GetSpellsUseCase _getSpells;

  /// Contador incrementado a cada busca disparada; usado para descartar a
  /// resposta de uma requisição obsoleta que só resolve depois de uma mais
  /// recente já ter emitido seu resultado (ex: uma busca com debounce lento
  /// respondendo depois de um filtro rápido) — o `switchMap` dos
  /// transformers só cobre corridas *dentro* do mesmo tipo de evento, não
  /// entre `SearchQueryChanged`, `FilterToggled` e `LoadSpellsEvent`.
  int _requestId = 0;

  /// Injeta [getSpells] e registra os handlers de eventos.
  CompendiumBloc(GetSpellsUseCase getSpells)
    : _getSpells = getSpells,
      super(const CompendiumState()) {
    on<LoadSpellsEvent>(_onLoadSpells);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounceRestartable(const Duration(milliseconds: 500)),
    );
    on<FilterToggled>(_onFilterToggled, transformer: restartable());
  }

  Future<void> _onLoadSpells(
    LoadSpellsEvent event,
    Emitter<CompendiumState> emit,
  ) {
    return _fetch(
      emit,
      searchQuery: state.searchQuery,
      activeFilters: state.activeFilters,
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<CompendiumState> emit,
  ) {
    return _fetch(
      emit,
      searchQuery: event.query,
      activeFilters: state.activeFilters,
    );
  }

  Future<void> _onFilterToggled(
    FilterToggled event,
    Emitter<CompendiumState> emit,
  ) {
    final filters = Map<String, dynamic>.from(state.activeFilters);
    if (filters[event.filterType] == event.value) {
      filters.remove(event.filterType);
    } else {
      filters[event.filterType] = event.value;
    }
    return _fetch(emit, searchQuery: state.searchQuery, activeFilters: filters);
  }

  /// Busca as magias que casam com [searchQuery]/[activeFilters]: emite
  /// `loading` (com a busca/filtros já atualizados, para a UI refletir a
  /// interação do usuário mesmo antes da resposta chegar) e então `success`
  /// ou `failure`, descartando a resposta se [_requestId] já tiver avançado
  /// enquanto a requisição estava em andamento.
  Future<void> _fetch(
    Emitter<CompendiumState> emit, {
    required String searchQuery,
    required Map<String, dynamic> activeFilters,
  }) async {
    final requestId = ++_requestId;
    emit(
      state.copyWith(
        status: CompendiumStatus.loading,
        searchQuery: searchQuery,
        activeFilters: activeFilters,
      ),
    );

    try {
      final spells = await _getSpells(
        name: searchQuery.isEmpty ? null : searchQuery,
        level: activeFilters['level'] as int?,
        school: activeFilters['school'] as String?,
      );
      if (requestId != _requestId) return;
      emit(state.copyWith(status: CompendiumStatus.success, spells: spells));
    } catch (e) {
      if (requestId != _requestId) return;
      emit(
        state.copyWith(
          status: CompendiumStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
