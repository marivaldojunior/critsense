part of 'equipment_bloc.dart';

/// Base selada para todos os eventos do [EquipmentBloc].
sealed class EquipmentEvent {
  const EquipmentEvent();
}

/// Solicita ao BLoC que busque a lista de equipamentos da API.
final class LoadEquipmentsEvent extends EquipmentEvent {
  const LoadEquipmentsEvent();
}
