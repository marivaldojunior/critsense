part of 'equipment_bloc.dart';

/// Fase atual do carregamento da listagem de equipamentos.
enum EquipmentStatus {
  /// Estado inicial antes de qualquer requisição.
  initial,

  /// Requisição (carga inicial, busca ou filtro) em andamento.
  loading,

  /// Última operação concluída com sucesso.
  success,

  /// Última operação resultou em falha.
  failure,
}

/// Estado único e imutável do [EquipmentBloc], atualizado via [copyWith].
///
/// Substitui a antiga hierarquia `sealed` de estados pelo mesmo motivo do
/// `CompendiumState` de Magias: [searchQuery]/[activeFilters] precisam
/// sobreviver às transições Initial → Loading → Loaded/Error para a
/// `SearchBar`/`FilterChip`s continuarem refletindo a interação do usuário.
class EquipmentState {
  /// Fase atual do carregamento.
  final EquipmentStatus status;

  /// Lista de equipamentos retornada pela última busca bem-sucedida.
  final List<EquipmentSummary> equipments;

  /// Texto de busca atualmente aplicado (vazio = sem busca).
  final String searchQuery;

  /// Filtros rápidos ativos, chaveados por tipo (ex: `{'equipmentCategory': 'weapon'}`).
  final Map<String, dynamic> activeFilters;

  /// Mensagem de erro da última falha; `null` fora do estado [failure].
  final String? errorMessage;

  const EquipmentState({
    this.status = EquipmentStatus.initial,
    this.equipments = const [],
    this.searchQuery = '',
    this.activeFilters = const {},
    this.errorMessage,
  });

  /// Retorna uma cópia deste estado substituindo os campos fornecidos.
  ///
  /// [errorMessage] é passado direto, sem cair no operador `??` — ver o
  /// comentário equivalente em `CompendiumState.copyWith`.
  EquipmentState copyWith({
    EquipmentStatus? status,
    List<EquipmentSummary>? equipments,
    String? searchQuery,
    Map<String, dynamic>? activeFilters,
    String? errorMessage,
  }) {
    return EquipmentState(
      status: status ?? this.status,
      equipments: equipments ?? this.equipments,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      errorMessage: errorMessage,
    );
  }
}
