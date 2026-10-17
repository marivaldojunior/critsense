import '../../domain/entities/spell_detail.dart';

/// Modelo de dados mapeado do JSON de detalhes de uma magia da API.
///
/// No C#, um DTO anotado com `[JsonPropertyName("casting_time")]` instrui o
/// `System.Text.Json` a mapear snake_case → PascalCase automaticamente via
/// reflexão em runtime. No Dart com compilação AOT, o `dart:mirrors` é
/// desabilitado pelo compilador para viabilizar tree-shaking: código não
/// referenciado estaticamente é eliminado do binário. Por isso mapeamos
/// cada campo manualmente no `fromJson`, trocando o custo de reflexão em
/// runtime por código explícito analisável em tempo de compilação.
class SpellDetailModel extends SpellDetail {
  const SpellDetailModel({
    required super.index,
    required super.name,
    required super.desc,
    super.higherLevel,
    required super.range,
    required super.components,
    required super.duration,
    required super.castingTime,
    required super.level,
  });

  /// Constrói um [SpellDetailModel] a partir do payload JSON da API.
  ///
  /// Listas dinâmicas (`List<dynamic>`) exigem cast explícito: o compilador AOT
  /// não pode inferir o tipo dos elementos em tempo de execução como o C# faria
  /// com `JsonSerializer.Deserialize<List<string>>()` via reflexão. O padrão
  /// `(json['campo'] as List).map((e) => e.toString()).toList()` é a alternativa
  /// segura e sem custo em runtime.
  factory SpellDetailModel.fromJson(Map<String, dynamic> json) {
    final higherLevelRaw = json['higher_level'] as List?;

    return SpellDetailModel(
      index: json['index'] as String,
      name: json['name'] as String,
      desc: (json['desc'] as List).map((e) => e.toString()).toList(),
      higherLevel: higherLevelRaw?.map((e) => e.toString()).toList(),
      range: json['range'] as String,
      components: (json['components'] as List)
          .map((e) => e.toString())
          .toList(),
      duration: json['duration'] as String,
      // A API usa snake_case; mapeamos para camelCase da entidade de domínio.
      castingTime: json['casting_time'] as String,
      level: json['level'] as int,
    );
  }
}
