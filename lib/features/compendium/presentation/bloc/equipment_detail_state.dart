part of 'equipment_detail_bloc.dart';

/// Base selada para todos os estados emitidos pelo [EquipmentDetailBloc].
sealed class EquipmentDetailState {
  const EquipmentDetailState();
}

/// Estado inicial antes de qualquer interação.
final class EquipmentDetailInitial extends EquipmentDetailState {
  const EquipmentDetailInitial();
}

/// Emitido enquanto a requisição à API está em andamento.
final class EquipmentDetailLoading extends EquipmentDetailState {
  const EquipmentDetailLoading();
}

/// Emitido quando os detalhes foram carregados com sucesso.
final class EquipmentDetailLoaded extends EquipmentDetailState {
  /// Detalhes completos do equipamento retornados pela API.
  final EquipmentDetail equipment;

  const EquipmentDetailLoaded(this.equipment);
}

/// Emitido quando ocorre falha na requisição.
final class EquipmentDetailError extends EquipmentDetailState {
  /// Mensagem descritiva do erro para exibição na UI.
  final String message;

  const EquipmentDetailError(this.message);
}
