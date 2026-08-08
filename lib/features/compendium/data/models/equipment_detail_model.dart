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
  });

  /// Constrói um [EquipmentDetailModel] a partir do payload JSON da API.
  factory EquipmentDetailModel.fromJson(Map<String, dynamic> json) {
    final costJson = json['cost'] as Map<String, dynamic>;
    final damageJson = json['damage'] as Map<String, dynamic>?;
    final rangeJson = json['range'] as Map<String, dynamic>?;
    final armorClassJson = json['armor_class'] as Map<String, dynamic>?;
    final descRaw = json['desc'] as List?;

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
      damage: damageJson != null
          ? EquipmentDamage(
              dice: damageJson['damage_dice'] as String,
              damageTypeIndex:
                  (damageJson['damage_type'] as Map<String, dynamic>)['index']
                      as String,
              damageTypeName:
                  (damageJson['damage_type'] as Map<String, dynamic>)['name']
                      as String,
            )
          : null,
      range: rangeJson != null
          ? EquipmentRange(
              normal: rangeJson['normal'] as int,
              long: rangeJson['long'] as int?,
            )
          : null,
      armorClass: armorClassJson?['base'] as int?,
    );
  }
}
