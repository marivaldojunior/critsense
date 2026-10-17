/// Uma ação de combate de um monstro (ataque, habilidade especial de ação, etc).
class MonsterAction {
  /// Nome da ação (ex: "Bite", "Multiattack").
  final String name;

  /// Descrição textual completa da ação, incluindo bônus de ataque e dano.
  final String desc;

  const MonsterAction({required this.name, required this.desc});
}

/// Detalhes completos de um monstro retornados pelo endpoint individual da API.
class MonsterDetail {
  /// Identificador único do monstro na API (ex: "adult-red-dragon").
  final String index;

  /// Nome legível do monstro.
  final String name;

  /// Categoria de tamanho (ex: "Huge", "Small").
  final String size;

  /// Tipo de criatura (ex: "dragon", "humanoid"), usado para localizar o
  /// ícone correspondente em `assets/icons/monster/`.
  final String type;

  /// Tendência do monstro (ex: "chaotic evil").
  final String alignment;

  /// Classe de Armadura. A API retorna uma lista de fontes de CA (armadura
  /// natural, equipamento, etc); usamos o valor da primeira entrada, que é
  /// sempre a CA efetiva do monstro.
  final int armorClass;

  /// Total de pontos de vida.
  final int hitPoints;

  /// Mapa de formas de deslocamento para o valor correspondente
  /// (ex: {"walk": "40 ft.", "fly": "80 ft."}), com as chaves já normalizadas
  /// para bater com os arquivos de `assets/icons/movement/` (walking, flying...).
  final Map<String, String> speed;

  /// Ações de combate disponíveis (ataques e habilidades ativas).
  final List<MonsterAction> actions;

  const MonsterDetail({
    required this.index,
    required this.name,
    required this.size,
    required this.type,
    required this.alignment,
    required this.armorClass,
    required this.hitPoints,
    required this.speed,
    required this.actions,
  });
}
