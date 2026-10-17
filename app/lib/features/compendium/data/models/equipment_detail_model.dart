import '../../domain/entities/equipment_detail.dart';

/// Modelo de dados mapeado do JSON de detalhes de um equipamento da API.
///
/// A API retorna campos opcionais distintos conforme a categoria do item:
/// armas trazem `damage`/`range`, armaduras trazem `armor_class`, e itens de
/// aventura trazem nenhum dos dois. O `fromJson` trata cada bloco como
/// nulo-seguro, refletindo essa variação no `EquipmentDetail` do domínio.
class EquipmentDetailModel extends EquipmentDetail {
  const EquipmentDetailModel({
    required super.index,
    required super.name,
    required super.equipmentCategory,
    required super.cost,
    required super.weight,
    required super.desc,
    super.damage,
    super.range,
    super.armorClass,
    super.armorCategory,
    super.armorDexBonus,
    super.armorMaxDexBonus,
    super.weaponCategory,
    super.weaponRange,
    super.properties,
    super.twoHandedDamage,
  });

  /// Constrói um [EquipmentDetailModel] a partir do payload JSON da API.
  factory EquipmentDetailModel.fromJson(Map<String, dynamic> json) {
    final costJson = json['cost'] as Map<String, dynamic>;
    final damageJson = json['damage'] as Map<String, dynamic>?;
    final rangeJson = json['range'] as Map<String, dynamic>?;
    final armorClassJson = json['armor_class'] as Map<String, dynamic>?;
    final descRaw = json['desc'] as List?;
    final twoHandedJson = json['two_handed_damage'] as Map<String, dynamic>?;
    final propertiesRaw = json['properties'] as List?;

    return EquipmentDetailModel(
      index: json['index'] as String,
      name: json['name'] as String,
      equipmentCategory:
          (json['equipment_category'] as Map<String, dynamic>)['name']
              as String,
      cost: EquipmentCost(
        quantity: costJson['quantity'] as int,
        unit: costJson['unit'] as String,
      ),
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      desc: descRaw?.map((e) => e.toString()).toList() ?? const [],
      damage: _damageFromJson(damageJson),
      twoHandedDamage: _damageFromJson(twoHandedJson),
      range: rangeJson != null
          ? EquipmentRange(
              normal: rangeJson['normal'] as int,
              long: rangeJson['long'] as int?,
            )
          : null,
      armorClass: armorClassJson?['base'] as int?,
      armorCategory: json['armor_category'] as String?,
      armorDexBonus: armorClassJson?['dex_bonus'] as bool? ?? false,
      armorMaxDexBonus: armorClassJson?['max_bonus'] as int?,
      weaponCategory: json['weapon_category'] as String?,
      weaponRange: json['weapon_range'] as String?,
      properties:
          propertiesRaw
              ?.map((p) => (p as Map<String, dynamic>)['index'] as String)
              .toList() ??
          const [],
    );
  }

  static EquipmentDamage? _damageFromJson(Map<String, dynamic>? json) {
    // Algumas armas (ex: rede) vêm sem dados de dano.
    final dice = json?['damage_dice'] as String?;
    if (json == null || dice == null) return null;
    final type = json['damage_type'] as Map<String, dynamic>?;
    return EquipmentDamage(
      dice: dice,
      damageTypeIndex: type?['index'] as String? ?? '',
      damageTypeName: type?['name'] as String? ?? '',
    );
  }
}
