import '../../domain/entities/spell_summary.dart';

/// Modelo de dados que representa a resposta da API para uma magia resumida.
///
/// Estende [SpellSummary] para herdar os campos do domínio e adiciona
/// o construtor de desserialização [fromJson].
///
/// No .NET, `System.Text.Json` ou `Newtonsoft.Json` usam reflexão em tempo
/// de execução para mapear propriedades automaticamente pelo nome. No Dart/Flutter
/// evitamos reflexão pesada (mirrors) porque ela impede o tree-shaking do
/// compilador AOT, aumentando o tamanho do binário e reduzindo performance
/// em dispositivos móveis. Por isso mapeamos os nós do JSON manualmente,
/// mantendo controle total sobre a transformação e sem custo em runtime.
class SpellSummaryModel extends SpellSummary {
  const SpellSummaryModel({
    required super.index,
    required super.name,
    required super.url,
  });

  /// Cria um [SpellSummaryModel] a partir de um nó JSON da API.
  ///
  /// Exemplo de payload esperado:
  /// ```json
  /// { "index": "acid-arrow", "name": "Acid Arrow", "url": "/api/spells/acid-arrow" }
  /// ```
  factory SpellSummaryModel.fromJson(Map<String, dynamic> json) {
    return SpellSummaryModel(
      index: json['index'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
