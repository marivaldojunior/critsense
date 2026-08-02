import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/monster_summary.dart';
import '../../domain/usecases/get_monsters_usecase.dart';

part 'monster_event.dart';
part 'monster_state.dart';

/// BLoC responsável pelo scroll infinito do bestiário.
///
/// Cada [FetchMonstersEvent] anexa uma nova página à lista existente,
/// acumulando o estado em vez de substituí-lo — padrão fundamental para
/// scroll infinito com `flutter_bloc`.
class MonsterBloc extends Bloc<MonsterEvent, MonsterState> {
  final GetMonstersUseCase _getMonsters;

  /// Tamanho fixo de cada página carregada.
  static const _pageSize = 20;

  /// Injeta [getMonsters] e registra o handler de [FetchMonstersEvent].
  MonsterBloc(GetMonstersUseCase getMonsters)
    : _getMonsters = getMonsters,
      super(const MonsterState()) {
    on<FetchMonstersEvent>(_onFetchMonsters);
  }

  /// Busca a próxima página de monstros ao receber [FetchMonstersEvent].
  ///
  /// Usa `state.monsters.length` como `offset` para que cada chamada
  /// continue de onde a anterior parou — sem necessidade de gerenciar
  /// um contador de página separado.
  Future<void> _onFetchMonsters(
    FetchMonstersEvent event,
    Emitter<MonsterState> emit,
  ) async {
    // Evita requisição desnecessária quando o fim da lista já foi atingido.
    if (state.hasReachedMax) return;

    try {
      final newMonsters = await _getMonsters(
        offset: state.monsters.length,
        limit: _pageSize,
      );

      if (newMonsters.isEmpty) {
        // Nenhum item retornado: sinaliza que todas as páginas foram consumidas.
        emit(state.copyWith(hasReachedMax: true));
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
      emit(state.copyWith(status: MonsterStatus.failure));
    }
  }
}
