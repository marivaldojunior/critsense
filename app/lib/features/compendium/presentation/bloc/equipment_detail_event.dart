part of 'equipment_detail_bloc.dart';

/// Base selada para todos os eventos do [EquipmentDetailBloc].
sealed class EquipmentDetailEvent {
  const EquipmentDetailEvent();
}

/// Solicita ao BLoC que busque os detalhes do equipamento identificado por [index].
final class LoadEquipmentDetailEvent extends EquipmentDetailEvent {
  /// Índice do equipamento na API (ex: "longsword").
  final String index;

  const LoadEquipmentDetailEvent(this.index);
}
