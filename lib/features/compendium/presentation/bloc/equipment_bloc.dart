import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/equipment_summary.dart';
import '../../domain/usecases/get_equipments_usecase.dart';

part 'equipment_event.dart';
part 'equipment_state.dart';

/// BLoC responsável pelo estado da listagem de equipamentos do compêndio.
class EquipmentBloc extends Bloc<EquipmentEvent, EquipmentState> {
  final GetEquipmentsUseCase _getEquipments;

  /// Injeta [getEquipments] e registra os handlers de eventos.
  EquipmentBloc(GetEquipmentsUseCase getEquipments)
    : _getEquipments = getEquipments,
      super(const EquipmentInitial()) {
    on<LoadEquipmentsEvent>(_onLoadEquipments);
  }

  /// Busca os equipamentos na API ao receber [LoadEquipmentsEvent].
  Future<void> _onLoadEquipments(
    LoadEquipmentsEvent event,
    Emitter<EquipmentState> emit,
  ) async {
    emit(const EquipmentLoading());
    try {
      final equipments = await _getEquipments();
      emit(EquipmentLoaded(equipments));
    } catch (e) {
      emit(EquipmentError(e.toString()));
    }
  }
}
