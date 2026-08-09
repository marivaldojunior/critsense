part of 'compendium_bloc.dart';

/// Fase atual do carregamento da listagem de magias.
enum CompendiumStatus {
  /// Estado inicial antes de qualquer requisição.
  initial,

  /// Requisição (carga inicial, busca ou filtro) em andamento.
  loading,

  /// Última operação concluída com sucesso.
  success,

  /// Última operação resultou em falha.
  failure,
}

/// Estado único e imutável do [CompendiumBloc], atualizado via [copyWith].
///
/// Substitui a antiga hierarquia `sealed` de estados: [searchQuery] e
/// [activeFilters] precisam sobreviver às transições Initial → Loading →
/// Loaded/Error para que a `SearchBar`/`FilterChip`s da tela continuem
/// refletindo o que o usuário digitou/selecionou mesmo enquanto uma nova
/// busca está em andamento — algo que variantes seladas separadas (cada
/// uma só carregando seus próprios campos) não expressam sem duplicar
/// esses dois campos em todas elas.
class CompendiumState {
  /// Fase atual do carregamento.
  final CompendiumStatus status;

  /// Lista de magias retornada pela última busca bem-sucedida.
  final List<SpellSummary> spells;

  /// Texto de busca atualmente aplicado (vazio = sem busca).
  final String searchQuery;

  /// Filtros rápidos ativos, chaveados por tipo (ex: `{'level': 3}`).
  final Map<String, dynamic> activeFilters;

  /// Mensagem de erro da última falha; `null` fora do estado [failure].
  final String? errorMessage;

  const CompendiumState({
    this.status = CompendiumStatus.initial,
    this.spells = const [],
    this.searchQuery = '',
    this.activeFilters = const {},
    this.errorMessage,
  });

  /// Retorna uma cópia deste estado substituindo os campos fornecidos.
  ///
  /// [errorMessage] é passado direto, sem cair no operador `??` — se
  /// coalescesse com `this.errorMessage`, um erro antigo nunca conseguiria
  /// ser limpo por uma emissão de sucesso subsequente, já que `null` (não
  /// informado) e `null` (limpeza intencional) seriam indistinguíveis.
  CompendiumState copyWith({
    CompendiumStatus? status,
    List<SpellSummary>? spells,
    String? searchQuery,
    Map<String, dynamic>? activeFilters,
    String? errorMessage,
  }) {
    return CompendiumState(
      status: status ?? this.status,
      spells: spells ?? this.spells,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      errorMessage: errorMessage,
    );
  }
}
