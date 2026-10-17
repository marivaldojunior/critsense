import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/equipment_detail.dart';
import '../../domain/usecases/get_equipment_detail_usecase.dart';

part 'equipment_detail_event.dart';
part 'equipment_detail_state.dart';

/// BLoC responsável pelo estado da tela de detalhes de um equipamento.
class EquipmentDetailBloc
    extends Bloc<EquipmentDetailEvent, EquipmentDetailState> {
  final GetEquipmentDetailUseCase _getEquipmentDetail;

  /// Injeta [getEquipmentDetail] e registra os handlers de eventos.
  EquipmentDetailBloc(GetEquipmentDetailUseCase getEquipmentDetail)
    : _getEquipmentDetail = getEquipmentDetail,
      super(const EquipmentDetailInitial()) {
    on<LoadEquipmentDetailEvent>(_onLoadEquipmentDetail);
  }

  /// Busca os detalhes do equipamento ao receber [LoadEquipmentDetailEvent].
  Future<void> _onLoadEquipmentDetail(
    LoadEquipmentDetailEvent event,
    Emitter<EquipmentDetailState> emit,
  ) async {
    emit(const EquipmentDetailLoading());
    try {
      final equipment = await _getEquipmentDetail(event.index);
      emit(EquipmentDetailLoaded(equipment));
    } catch (e) {
      emit(EquipmentDetailError(e.toString()));
    }
  }
}
