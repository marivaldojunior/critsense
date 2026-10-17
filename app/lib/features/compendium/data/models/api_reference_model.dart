import '../../domain/entities/api_reference.dart';

/// Modelo de desserialização para uma referência genérica da API do D&D 5e.
///
/// Estende [ApiReference] para herdar os campos do domínio e adiciona
/// o construtor de fábrica [fromJson] responsável pelo mapeamento manual
/// do JSON — evitando reflexão em tempo de execução, que impede o tree-shaking
/// do compilador AOT e aumenta o tamanho do binário em apps Flutter.
class ApiReferenceModel extends ApiReference {
  const ApiReferenceModel({required super.index, required super.name});

  /// Cria um [ApiReferenceModel] a partir de um nó JSON da API.
  ///
  /// Exemplo de payload esperado:
  /// ```json
  /// { "index": "barbarian", "name": "Barbarian" }
  /// ```
  factory ApiReferenceModel.fromJson(Map<String, dynamic> json) {
    return ApiReferenceModel(
      index: json['index'] as String,
      name: json['name'] as String,
    );
  }
}
