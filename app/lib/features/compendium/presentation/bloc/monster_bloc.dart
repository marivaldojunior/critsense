import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/utils/bloc_event_transformers.dart';

import '../../domain/entities/monster_summary.dart';
import '../../domain/usecases/get_monsters_usecase.dart';

part 'monster_event.dart';
part 'monster_state.dart';

/// BLoC responsável pelo scroll infinito do bestiário, incluindo busca por
/// texto e filtro rápido de CR (Classe de Desafio).
///
/// Cada [FetchMonstersEvent] anexa uma nova página à lista existente,
/// acumulando o estado em vez de substituí-lo — padrão fundamental para
/// scroll infinito com `flutter_bloc`. Já [SearchQueryChanged] e
/// [FilterToggled] zeram a paginação: uma busca/filtro novo invalida as
/// páginas já carregadas sob os critérios anteriores.
class MonsterBloc extends Bloc<MonsterEvent, MonsterState> {
  final GetMonstersUseCase _getMonsters;

  /// Tamanho fixo de cada página carregada.
  static const _pageSize = 20;

  /// Contador incrementado a cada busca disparada; usado para descartar a
  /// resposta de uma requisição obsoleta — ver o comentário equivalente em
  /// `CompendiumBloc._requestId`. Cobre inclusive a paginação por scroll:
  /// uma página tardia não deve ser anexada depois que uma busca/filtro já
  /// zerou a lista.
  int _requestId = 0;

  /// Injeta [getMonsters] e registra os handlers de eventos.
  MonsterBloc(GetMonstersUseCase getMonsters)
    : _getMonsters = getMonsters,
      super(const MonsterState()) {
    on<FetchMonstersEvent>(_onFetchMonsters);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounceRestartable(const Duration(milliseconds: 500)),
    );
    on<FilterToggled>(_onFilterToggled, transformer: restartable());
  }

  /// Busca a próxima página de monstros ao receber [FetchMonstersEvent].
  ///
  /// Usa `state.monsters.length` como `offset` para que cada chamada
  /// continue de onde a anterior parou — sem necessidade de gerenciar
  /// um contador de página separado. Repassa a busca/filtros correntes
  /// para que cada página respeite o mesmo critério da primeira.
  Future<void> _onFetchMonsters(
    FetchMonstersEvent event,
    Emitter<MonsterState> emit,
  ) async {
    // Evita requisição desnecessária quando o fim da lista já foi atingido.
    if (state.hasReachedMax) return;

    final requestId = ++_requestId;
    try {
      final newMonsters = await _getMonsters(
        offset: state.monsters.length,
        limit: _pageSize,
        name: state.searchQuery.isEmpty ? null : state.searchQuery,
        challengeRating: state.activeFilters['challengeRating'] as num?,
      );
      if (requestId != _requestId) return;

      if (newMonsters.isEmpty) {
        // Nenhum item retornado: sinaliza que todas as páginas foram
        // consumidas. Também marca status como success mesmo quando a
        // lista continua vazia (primeira página sem resultados), senão a
        // tela ficaria presa no esqueleto de carregamento indefinidamente.
        emit(
          state.copyWith(status: MonsterStatus.success, hasReachedMax: true),
        );
      } else {
        emit(
          state.copyWith(
            status: MonsterStatus.success,
            // Concatena a lista anterior com a nova página, preservando imutabilidade.
            monsters: [...state.monsters, ...newMonsters],
          ),
        );
      }
    } catch (_) {
      if (requestId != _requestId) return;
      emit(state.copyWith(status: MonsterStatus.failure));
    }
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<MonsterState> emit,
  ) {
    return _resetAndFetch(
      emit,
      searchQuery: event.query,
      activeFilters: state.activeFilters,
    );
  }

  Future<void> _onFilterToggled(
    FilterToggled event,
    Emitter<MonsterState> emit,
  ) {
    final filters = Map<String, dynamic>.from(state.activeFilters);
    if (filters[event.filterType] == event.value) {
      filters.remove(event.filterType);
    } else {
      filters[event.filterType] = event.value;
    }
    return _resetAndFetch(
      emit,
      searchQuery: state.searchQuery,
      activeFilters: filters,
    );
  }

  /// Zera a paginação corrente (lista, `hasReachedMax`) e busca a primeira
  /// página sob [searchQuery]/[activeFilters], emitindo `loading` antes da
  /// requisição para a tela mostrar o esqueleto de carregamento.
  Future<void> _resetAndFetch(
    Emitter<MonsterState> emit, {
    required String searchQuery,
    required Map<String, dynamic> activeFilters,
  }) async {
    final requestId = ++_requestId;
    emit(
      state.copyWith(
        status: MonsterStatus.loading,
        monsters: const [],
        hasReachedMax: false,
        searchQuery: searchQuery,
        activeFilters: activeFilters,
      ),
    );

    try {
      final monsters = await _getMonsters(
        offset: 0,
        limit: _pageSize,
        name: searchQuery.isEmpty ? null : searchQuery,
        challengeRating: activeFilters['challengeRating'] as num?,
      );
      if (requestId != _requestId) return;
      emit(
        state.copyWith(
          status: MonsterStatus.success,
          monsters: monsters,
          hasReachedMax: monsters.isEmpty,
        ),
      );
    } catch (_) {
      if (requestId != _requestId) return;
      emit(state.copyWith(status: MonsterStatus.failure));
    }
  }
}
