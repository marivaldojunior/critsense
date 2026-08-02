import '../../domain/entities/equipment_summary.dart';

/// Modelo de dados que representa a resposta da API para um equipamento resumido.
///
/// Equivale a um DTO leve no ecossistema .NET: assim como um
/// `EquipmentListItemDto` seria usado para popular um `ListView` sem expor
/// todas as propriedades da entidade de domínio, este modelo carrega apenas
/// os três campos necessários para renderizar a lista. Propriedades pesadas
/// (dano, propriedades, custo) ficam reservadas para um modelo de detalhes,
/// evitando alocar objetos grandes em memória ao carregar centenas de itens.
class EquipmentSummaryModel extends EquipmentSummary {
  const EquipmentSummaryModel({
    required super.index,
    required super.name,
    required super.url,
  });

  /// Cria um [EquipmentSummaryModel] a partir de um nó JSON da API.
  ///
  /// Exemplo de payload esperado:
  /// ```json
  /// { "index": "longsword", "name": "Longsword", "url": "/api/equipment/longsword" }
  /// ```
  factory EquipmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return EquipmentSummaryModel(
      index: json['index'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
