import '../../domain/entities/monster_summary.dart';

/// Modelo de dados que representa a resposta da API para um monstro resumido.
///
/// Estende [MonsterSummary] para herdar os campos do domínio e adiciona
/// o construtor de desserialização [fromJson].
///
/// No .NET, `System.Text.Json` usa reflexão em runtime para mapear
/// propriedades automaticamente. No Dart com AOT, `dart:mirrors` é desabilitado
/// para viabilizar tree-shaking; por isso mapeamos cada campo manualmente,
/// eliminando o custo de reflexão em troca de código explícito e tipado.
class MonsterSummaryModel extends MonsterSummary {
  const MonsterSummaryModel({
    required super.index,
    required super.name,
    required super.url,
  });

  /// Cria um [MonsterSummaryModel] a partir de um nó JSON da API.
  ///
  /// Exemplo de payload esperado:
  /// ```json
  /// { "index": "aboleth", "name": "Aboleth", "url": "/api/monsters/aboleth" }
  /// ```
  factory MonsterSummaryModel.fromJson(Map<String, dynamic> json) {
    return MonsterSummaryModel(
      index: json['index'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
