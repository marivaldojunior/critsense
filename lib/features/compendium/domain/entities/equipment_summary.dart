/// Resumo de um equipamento retornado pela listagem da API do D&D 5e.
class EquipmentSummary {
  /// Identificador único do equipamento na API (ex: "longsword").
  final String index;

  /// Nome legível do equipamento (ex: "Longsword").
  final String name;

  /// Caminho relativo do endpoint de detalhes (ex: "/api/equipment/longsword").
  final String url;

  const EquipmentSummary({
    required this.index,
    required this.name,
    required this.url,
  });
}
