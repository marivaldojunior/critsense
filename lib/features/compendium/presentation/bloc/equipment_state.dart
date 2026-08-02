part of 'equipment_bloc.dart';

/// Base selada para todos os estados emitidos pelo [EquipmentBloc].
sealed class EquipmentState {
  const EquipmentState();
}

/// Estado inicial antes de qualquer interação.
final class EquipmentInitial extends EquipmentState {
  const EquipmentInitial();
}

/// Emitido enquanto a requisição à API está em andamento.
final class EquipmentLoading extends EquipmentState {
  const EquipmentLoading();
}

/// Emitido quando a lista de equipamentos foi carregada com sucesso.
final class EquipmentLoaded extends EquipmentState {
  /// Lista de equipamentos retornada pela API.
  final List<EquipmentSummary> equipments;

  const EquipmentLoaded(this.equipments);
}

/// Emitido quando ocorre falha na requisição.
final class EquipmentError extends EquipmentState {
  /// Mensagem descritiva do erro para exibição na UI.
  final String message;

  const EquipmentError(this.message);
}
