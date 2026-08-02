/// Referência genérica a um recurso listável da API do D&D 5e.
///
/// Utilizada para endpoints que retornam coleções resumidas (ex: `/api/classes`,
/// `/api/races`), onde cada item contém apenas `index` e `name`.
class ApiReference {
  /// Identificador único do recurso na API (ex: "barbarian", "elf").
  final String index;

  /// Nome legível para exibição ao usuário (ex: "Barbarian", "Elf").
  final String name;

  const ApiReference({required this.index, required this.name});
}
