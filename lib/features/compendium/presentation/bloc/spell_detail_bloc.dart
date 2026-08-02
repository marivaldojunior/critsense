import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/spell_detail.dart';
import '../../domain/usecases/get_spell_detail_usecase.dart';

part 'spell_detail_event.dart';
part 'spell_detail_state.dart';

/// BLoC responsável pelo estado da tela de detalhes de uma magia.
class SpellDetailBloc extends Bloc<SpellDetailEvent, SpellDetailState> {
  final GetSpellDetailUseCase _getSpellDetail;

  /// Injeta [getSpellDetail] e registra os handlers de eventos.
  SpellDetailBloc(GetSpellDetailUseCase getSpellDetail)
    : _getSpellDetail = getSpellDetail,
      super(const SpellDetailInitial()) {
    on<LoadSpellDetailEvent>(_onLoadSpellDetail);
  }

  /// Busca os detalhes da magia ao receber [LoadSpellDetailEvent].
  Future<void> _onLoadSpellDetail(
    LoadSpellDetailEvent event,
    Emitter<SpellDetailState> emit,
  ) async {
    emit(const SpellDetailLoading());
    try {
      final spell = await _getSpellDetail(event.index);
      emit(SpellDetailLoaded(spell));
    } catch (e) {
      emit(SpellDetailError(e.toString()));
    }
  }
}
