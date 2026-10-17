part of 'inventory_bloc.dart';

/// Fase atual do carregamento do inventário.
enum InventoryStatus {
  /// Estado inicial antes de qualquer carga.
  initial,

  /// Carga do inventário em andamento.
  loading,

  /// Inventário carregado com sucesso.
  success,

  /// A carga do inventário falhou.
  failure,
}

/// Estado único e imutável do [InventoryBloc], atualizado via [copyWith].
///
/// Mesmo formato do `SessionNotesState`: uma falha ao remover um item mantém
/// [items] na tela e só preenche [errorMessage].
class InventoryState extends Equatable {
  /// Fase atual do carregamento.
  final InventoryStatus status;

  /// Itens do inventário do personagem.
  final List<InventoryItem> items;

  /// Mensagem da última falha; `null` quando a última operação deu certo.
  final String? errorMessage;

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  /// Copia o estado trocando só os campos informados. [errorMessage] não é
  /// herdado: toda nova emissão limpa o erro anterior.
  InventoryState copyWith({
    InventoryStatus? status,
    List<InventoryItem>? items,
    String? errorMessage,
  }) {
    return InventoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
