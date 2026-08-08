import '../../domain/entities/monster_detail.dart';

/// Traduz as chaves de deslocamento da API ("walk", "fly"...) para o nome
/// do arquivo correspondente em `assets/icons/movement/` ("walking", "flying"...).
///
/// Chaves sem ícone dedicado (nenhuma até o momento) caem no valor original,
/// para nunca perder dado por falta de mapeamento.
const _movementIconKeys = {
  'walk': 'walking',
  'climb': 'climbing',
  'fly': 'flying',
  'swim': 'swimming',
  'burrow': 'burrowing',
};

/// Modelo de dados mapeado do JSON de detalhes de um monstro da API.
///
/// A API retorna `armor_class` como uma lista de fontes (armadura natural,
/// equipamento vestido, etc) em vez de um único número — extraímos o `value`
/// da primeira entrada, que é sempre a CA efetiva do monstro em combate.
class MonsterDetailModel extends MonsterDetail {
  const MonsterDetailModel({
    required super.index,
    required super.name,
    required super.size,
    required super.type,
    required super.alignment,
    required super.armorClass,
    required super.hitPoints,
    required super.speed,
    required super.actions,
  });

  /// Constrói um [MonsterDetailModel] a partir do payload JSON da API.
  factory MonsterDetailModel.fromJson(Map<String, dynamic> json) {
    final armorClassList = json['armor_class'] as List<dynamic>;
    final firstArmorClass = armorClassList.first as Map<String, dynamic>;

    final speedJson = json['speed'] as Map<String, dynamic>;
    final speed = <String, String>{
      for (final entry in speedJson.entries)
        (_movementIconKeys[entry.key] ?? entry.key): entry.value.toString(),
    };

    final actionsRaw = (json['actions'] as List?) ?? const [];
    final actions = actionsRaw
        .cast<Map<String, dynamic>>()
        .map(
          (action) => MonsterAction(
            name: action['name'] as String,
            desc: action['desc'] as String,
          ),
        )
        .toList();

    return MonsterDetailModel(
      index: json['index'] as String,
      name: json['name'] as String,
      size: json['size'] as String,
      type: json['type'] as String,
      alignment: json['alignment'] as String,
      armorClass: firstArmorClass['value'] as int,
      hitPoints: json['hit_points'] as int,
      speed: speed,
      actions: actions,
    );
  }
}
