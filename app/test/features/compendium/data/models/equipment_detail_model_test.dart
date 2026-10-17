import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/compendium/data/models/equipment_detail_model.dart';

/// Testa a leitura do JSON da API 5e-bits (formato de `/api/2014/equipment`).
void main() {
  test('arma: categoria, alcance, propriedades e dano a duas mãos', () {
    final longsword = EquipmentDetailModel.fromJson({
      'index': 'longsword',
      'name': 'Longsword',
      'equipment_category': {'index': 'weapon', 'name': 'Weapon'},
      'weapon_category': 'Martial',
      'weapon_range': 'Melee',
      'cost': {'quantity': 15, 'unit': 'gp'},
      'damage': {
        'damage_dice': '1d8',
        'damage_type': {'index': 'slashing', 'name': 'Slashing'},
      },
      'range': {'normal': 5},
      'weight': 3,
      'properties': [
        {'index': 'versatile', 'name': 'Versatile'},
      ],
      'two_handed_damage': {
        'damage_dice': '1d10',
        'damage_type': {'index': 'slashing', 'name': 'Slashing'},
      },
    });

    expect(longsword.weaponCategory, 'Martial');
    expect(longsword.weaponRange, 'Melee');
    expect(longsword.properties, ['versatile']);
    expect(longsword.damage!.dice, '1d8');
    expect(longsword.twoHandedDamage!.dice, '1d10');
    expect(longsword.weight, 3);
    expect(longsword.armorCategory, isNull);
  });

  test('armadura média: base, bônus de DES e máximo', () {
    final chainShirt = EquipmentDetailModel.fromJson({
      'index': 'chain-shirt',
      'name': 'Chain Shirt',
      'equipment_category': {'index': 'armor', 'name': 'Armor'},
      'armor_category': 'Medium',
      'armor_class': {'base': 13, 'dex_bonus': true, 'max_bonus': 2},
      'weight': 20,
      'cost': {'quantity': 50, 'unit': 'gp'},
      'properties': <dynamic>[],
    });

    expect(chainShirt.armorCategory, 'Medium');
    expect(chainShirt.armorClass, 13);
    expect(chainShirt.armorDexBonus, isTrue);
    expect(chainShirt.armorMaxDexBonus, 2);
    expect(chainShirt.damage, isNull);
  });

  test('escudo: bônus de +2 sem DES', () {
    final shield = EquipmentDetailModel.fromJson({
      'index': 'shield',
      'name': 'Shield',
      'equipment_category': {'index': 'armor', 'name': 'Armor'},
      'armor_category': 'Shield',
      'armor_class': {'base': 2, 'dex_bonus': false},
      'weight': 6,
      'cost': {'quantity': 10, 'unit': 'gp'},
    });

    expect(shield.armorCategory, 'Shield');
    expect(shield.armorClass, 2);
    expect(shield.armorDexBonus, isFalse);
    expect(shield.properties, isEmpty);
  });
}
