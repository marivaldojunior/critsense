/// Resumo de um monstro retornado pela listagem da API do D&D 5e.
class MonsterSummary {
  /// Identificador único do monstro na API (ex: "aboleth").
  final String index;

  /// Nome legível do monstro (ex: "Aboleth").
  final String name;

  /// Caminho relativo do endpoint de detalhes (ex: "/api/monsters/aboleth").
  final String url;

  const MonsterSummary({
    required this.index,
    required this.name,
    required this.url,
  });
}
