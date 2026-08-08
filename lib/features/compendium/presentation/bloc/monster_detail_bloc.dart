import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/monster_detail.dart';
import '../../domain/usecases/get_monster_detail_usecase.dart';

part 'monster_detail_event.dart';
part 'monster_detail_state.dart';

/// BLoC responsável pelo estado da tela de detalhes de um monstro.
class MonsterDetailBloc extends Bloc<MonsterDetailEvent, MonsterDetailState> {
  final GetMonsterDetailUseCase _getMonsterDetail;

  /// Injeta [getMonsterDetail] e registra os handlers de eventos.
  MonsterDetailBloc(GetMonsterDetailUseCase getMonsterDetail)
    : _getMonsterDetail = getMonsterDetail,
      super(const MonsterDetailInitial()) {
    on<LoadMonsterDetailEvent>(_onLoadMonsterDetail);
  }

  /// Busca os detalhes do monstro ao receber [LoadMonsterDetailEvent].
  Future<void> _onLoadMonsterDetail(
    LoadMonsterDetailEvent event,
    Emitter<MonsterDetailState> emit,
  ) async {
    emit(const MonsterDetailLoading());
    try {
      final monster = await _getMonsterDetail(event.index);
      emit(MonsterDetailLoaded(monster));
    } catch (e) {
      emit(MonsterDetailError(e.toString()));
    }
  }
}
