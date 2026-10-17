/// Resumo de uma magia retornado pela listagem da API do D&D 5e.
class SpellSummary {
  /// Identificador único da magia na API (ex: "acid-arrow").
  final String index;

  /// Nome legível da magia (ex: "Acid Arrow").
  final String name;

  /// Caminho relativo do endpoint de detalhes (ex: "/api/spells/acid-arrow").
  final String url;

  const SpellSummary({
    required this.index,
    required this.name,
    required this.url,
  });
}
