/// Detalhes completos de uma magia retornados pelo endpoint individual da API.
class SpellDetail {
  /// Identificador único da magia na API (ex: "acid-arrow").
  final String index;

  /// Nome legível da magia.
  final String name;

  /// Parágrafos de descrição da magia.
  final List<String> desc;

  /// Descrição do efeito em níveis superiores (opcional na API).
  final List<String>? higherLevel;

  /// Alcance da magia (ex: "Self", "60 feet").
  final String range;

  /// Componentes necessários para lançar a magia (ex: ["V", "S", "M"]).
  final List<String> components;

  /// Duração do efeito (ex: "Instantaneous", "1 minute").
  final String duration;

  /// Tempo de conjuração (ex: "1 action", "1 bonus action").
  final String castingTime;

  /// Nível da magia (0 para truques, 1–9 para magias comuns).
  final int level;

  const SpellDetail({
    required this.index,
    required this.name,
    required this.desc,
    this.higherLevel,
    required this.range,
    required this.components,
    required this.duration,
    required this.castingTime,
    required this.level,
  });
}
