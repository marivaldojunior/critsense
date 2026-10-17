import 'package:crit_sense/features/compendium/domain/entities/equipment_detail.dart';

import '../entities/inventory_item.dart';

/// Converte um equipamento do compêndio num item de inventário, com o peso e
/// os dados de armadura e de arma.
InventoryItem inventoryItemFromEquipment(
  EquipmentDetail equipment, {
  required String id,
  required String characterId,
}) {
  return withEquipmentDetails(
    InventoryItem(
      id: id,
      characterId: characterId,
      itemIndex: equipment.index,
      name: equipment.name,
      equipmentCategory: equipment.equipmentCategory,
    ),
    equipment,
  );
}

/// Completa [item] com os dados de [equipment] (usado nos itens antigos, que
/// só tinham nome e categoria). Mantém quantidade, equipado e sintonia.
InventoryItem withEquipmentDetails(
  InventoryItem item,
  EquipmentDetail equipment,
) {
  return item.copyWith(
    equipmentCategory: equipment.equipmentCategory,
    weight: equipment.weight,
    detailsLoaded: true,
    armorCategory: equipment.armorCategory,
    armorBase: equipment.armorClass,
    armorDexBonus: equipment.armorDexBonus,
    armorMaxDexBonus: equipment.armorMaxDexBonus,
    weaponCategory: equipment.weaponCategory,
    weaponRange: equipment.weaponRange,
    damageDice: equipment.damage?.dice,
    damageType: equipment.damage?.damageTypeName,
    versatileDamageDice: equipment.twoHandedDamage?.dice,
    weaponProperties: equipment.properties,
  );
}
